// Worker Isolate - Executes HTTP requests in background
//
// CRITICAL ARCHITECTURE NOTE:
// This worker does NOT represent a single virtual user.
// Instead, ONE worker isolate simulates MULTIPLE virtual users concurrently.
//
// Example: To simulate 100,000 users with 8 workers:
// - Each worker simulates 12,500 virtual users
// - Each worker uses async/await to run multiple requests concurrently
// - This prevents spawning 100,000 isolates which would crash the system
//
// Communication:
// - Receives work batches via SendPort
// - Sends individual request results back to coordinator
// - Can be gracefully stopped via control messages

import 'dart:isolate';
import 'dart:convert';
import 'package:dio/dio.dart';

import '../../domain/entities/api_request.dart';
import '../../domain/entities/api_response.dart';
import '../../domain/entities/flow.dart';
import '../flow_engine/variable_injector.dart';
import '../flow_engine/json_extractor.dart';

/// Message types for isolate communication
class WorkerMessage {
  final WorkerMessageType type;
  final dynamic data;

  WorkerMessage(this.type, this.data);
}

enum WorkerMessageType { startWork, stop, result, error, status }

/// Work package sent to worker
class WorkPackage {
  final String workerId;
  final ApiRequest? request;
  final Flow? flow;
  final int iterations; // Number of times to execute this request/flow
  final int concurrency; // How many concurrent virtual users
  final int delayMs; // Delay between iterations

  WorkPackage({
    required this.workerId,
    this.request,
    this.flow,
    required this.iterations,
    required this.concurrency,
    required this.delayMs,
  }) : assert(
         request != null || flow != null,
         'Either request or flow must be provided',
       );
}

/// Worker isolate entry point
/// This is spawned in a background isolate
Future<void> workerIsolateEntryPoint(SendPort sendPort) async {
  // Create receive port for this worker
  final receivePort = ReceivePort();

  // Send our receive port back to coordinator
  sendPort.send(receivePort.sendPort);

  // Create HTTP client for this worker
  final dio = Dio(
    BaseOptions(
      validateStatus: (status) => true, // Accept all status codes
      followRedirects: true,
      maxRedirects: 5,
    ),
  );

  bool shouldStop = false;

  // Listen for work packages
  await for (final message in receivePort) {
    if (message is! WorkerMessage) continue;

    switch (message.type) {
      case WorkerMessageType.startWork:
        final package = message.data as WorkPackage;

        // Execute work package without blocking
        _executeWorkPackage(
          dio: dio,
          package: package,
          sendPort: sendPort,
          shouldStopCallback: () => shouldStop,
        );
        break;

      case WorkerMessageType.stop:
        shouldStop = true;
        dio.close();
        receivePort.close();
        return;

      default:
        break;
    }
  }
}

/// Execute a work package
/// This simulates multiple virtual users by running requests concurrently
void _executeWorkPackage({
  required Dio dio,
  required WorkPackage package,
  required SendPort sendPort,
  required bool Function() shouldStopCallback,
}) {
  // Run work asynchronously without blocking the isolate
  Future(() async {
    int completedIterations = 0;

    try {
      // BATCHING STRATEGY:
      // Instead of running all iterations at once, we batch them
      // to control concurrency and prevent memory issues

      while (completedIterations < package.iterations &&
          !shouldStopCallback()) {
        // Calculate how many requests to run in this batch
        final remaining = package.iterations - completedIterations;
        final batchSize = remaining < package.concurrency
            ? remaining
            : package.concurrency;

        // Create a batch of concurrent requests/flows
        final futures = List.generate(batchSize, (_) {
          if (package.flow != null) {
            return _executeFlow(dio, package.flow!, sendPort);
          } else {
            return _executeRequest(dio, package.request!).then((result) {
              sendPort.send(WorkerMessage(WorkerMessageType.result, result));
              return result;
            });
          }
        });

        // Wait for batch to complete
        await Future.wait(futures);

        completedIterations += batchSize;

        // Apply delay between batches if specified
        if (package.delayMs > 0 && completedIterations < package.iterations) {
          await Future.delayed(Duration(milliseconds: package.delayMs));
        }
      }

      // Send completion status
      sendPort.send(
        WorkerMessage(
          WorkerMessageType.status,
          'Completed $completedIterations iterations',
        ),
      );
    } catch (e) {
      sendPort.send(WorkerMessage(WorkerMessageType.error, e.toString()));
    }
  });
}

/// Execute a complete flow
/// Handles variable extraction and injection between steps
Future<void> _executeFlow(Dio dio, Flow flow, SendPort sendPort) async {
  final variables = <String, String>{...flow.variables};
  final jsonExtractor = JsonExtractor();

  for (final step in flow.steps) {
    if (!step.enabled) continue;

    final injector = VariableInjector(variables);
    final injectedRequest = _injectVariablesIntoRequest(step.request, injector);

    final result = await _executeRequest(dio, injectedRequest);

    // Send individual step result to coordinator for metrics
    sendPort.send(WorkerMessage(WorkerMessageType.result, result));

    // Extract variables for next steps
    if (result.error == null && result.body.isNotEmpty) {
      final extracted = jsonExtractor.extractMultiple(
        result.body,
        step.extractors,
      );
      variables.addAll(extracted);
    }

    // Stop flow if step failed and stopOnFailure is true
    if (result.hasError && step.stopOnFailure) {
      break;
    }

    // Apply think time if any
    if (step.thinkTimeMs > 0) {
      await Future.delayed(Duration(milliseconds: step.thinkTimeMs));
    }
  }
}

/// Helper to inject variables into request (Isolate version)
ApiRequest _injectVariablesIntoRequest(
  ApiRequest request,
  VariableInjector injector,
) {
  return request.copyWith(
    url: injector.inject(request.url),
    headers: request.headers.map(
      (k, v) => MapEntry(injector.inject(k), injector.inject(v.toString())),
    ),
    queryParams: request.queryParams.map(
      (k, v) => MapEntry(injector.inject(k), injector.inject(v.toString())),
    ),
    body: request.body != null ? injector.inject(request.body!) : null,
  );
}

/// Execute a single HTTP request
/// Returns ApiResponse with timing and status information
Future<ApiResponse> _executeRequest(Dio dio, ApiRequest request) async {
  final startTime = DateTime.now();

  try {
    // Build request options
    final options = Options(
      method: request.method.name.toUpperCase(),
      headers: _buildHeaders(request),
      sendTimeout: Duration(milliseconds: request.timeoutMs),
      receiveTimeout: Duration(milliseconds: request.timeoutMs),
    );

    // Build URL with query params
    var rawUrl = request.url.trim();
    if (!rawUrl.startsWith('http://') && !rawUrl.startsWith('https://')) {
      rawUrl = 'https://$rawUrl';
    }
    final uri = Uri.parse(rawUrl);
    final allQueryParams = {...uri.queryParameters, ...request.queryParams};
    final finalUri = allQueryParams.isNotEmpty
        ? uri.replace(queryParameters: allQueryParams)
        : uri;

    // Execute request
    final response = await dio.request(
      finalUri.toString(),
      data: request.body,
      options: options,
    );

    final endTime = DateTime.now();
    final responseTime = endTime.difference(startTime).inMilliseconds;

    // Convert response to domain entity
    return ApiResponse(
      statusCode: response.statusCode ?? 0,
      statusMessage: response.statusMessage ?? 'OK',
      headers: _convertHeaders(response.headers.map),
      body: response.data?.toString() ?? '',
      responseTimeMs: responseTime,
      sizeBytes: response.data?.toString().length ?? 0,
      timestamp: endTime,
    );
  } catch (e) {
    final endTime = DateTime.now();
    final responseTime = endTime.difference(startTime).inMilliseconds;

    if (e is DioException && e.response != null) {
      final resp = e.response!;
      return ApiResponse(
        statusCode: resp.statusCode ?? 0,
        statusMessage: resp.statusMessage ?? (e.message ?? 'Error'),
        headers: _convertHeaders(resp.headers.map),
        body: resp.data?.toString() ?? '',
        responseTimeMs: responseTime,
        sizeBytes: resp.data?.toString().length ?? 0,
        timestamp: endTime,
        error: e.message ?? e.toString(),
      );
    }

    return ApiResponse(
      statusCode: 0,
      statusMessage: 'Error',
      headers: {},
      body: '',
      responseTimeMs: responseTime,
      sizeBytes: 0,
      timestamp: endTime,
      error: e.toString(),
    );
  }
}

/// Build headers including auth
Map<String, dynamic> _buildHeaders(ApiRequest request) {
  final headers = <String, dynamic>{...request.headers};

  // Add authentication headers
  if (request.auth != null) {
    request.auth!.when(
      bearer: (token) {
        headers['Authorization'] = 'Bearer $token';
      },
      basic: (username, password) {
        final credentials = base64Encode('$username:$password'.codeUnits);
        headers['Authorization'] = 'Basic $credentials';
      },
      apiKey: (key, value, location) {
        if (location == ApiKeyLocation.header) {
          headers[key] = value;
        }
      },
    );
  }

  return headers;
}

/// Convert Dio headers to Map
Map<String, dynamic> _convertHeaders(Map<String, List<String>> headers) {
  return headers.map((key, value) => MapEntry(key, value.join(', ')));
}
