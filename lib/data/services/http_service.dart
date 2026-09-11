// HTTP Service - Execute API Requests
//
// PURPOSE:
// - Wrapper around Dio for executing HTTP requests
// - Handles all HTTP methods
// - Auth header injection
// - Error handling
// - Request/response timing
//
// USAGE:
// final service = HttpService();
// final response = await service.execute(apiRequest);

import 'package:dio/dio.dart';
import 'dart:convert';

import '../../domain/entities/api_request.dart';
import '../../domain/entities/api_response.dart' as domain;

class HttpService {
  late final Dio _dio;

  HttpService() {
    _dio = Dio(
      BaseOptions(
        validateStatus: (status) => true, // Accept all status codes
        followRedirects: true,
        maxRedirects: 5,
      ),
    );
  }

  /// Execute an API request
  Future<domain.ApiResponse> execute(ApiRequest request) async {
    final startTime = DateTime.now();

    try {
      // Build options
      final options = Options(
        method: request.method.toString().split('.').last.toUpperCase(),
        headers: _buildHeaders(request),
        sendTimeout: Duration(milliseconds: request.timeoutMs),
        receiveTimeout: Duration(milliseconds: request.timeoutMs),
      );

      // Normalize URL
      var rawUrl = request.url.trim();
      if (!rawUrl.startsWith('http://') && !rawUrl.startsWith('https://')) {
        rawUrl = 'https://$rawUrl';
      }
      final uri = Uri.parse(rawUrl);

      // Combine query parameters without adding unnecessary trailing ?
      final allQueryParams = {...uri.queryParameters, ...request.queryParams};
      final finalUri = allQueryParams.isNotEmpty
          ? uri.replace(queryParameters: allQueryParams)
          : uri;

      // Execute request
      final response = await _dio.request(
        finalUri.toString(),
        data: request.body,
        options: options,
      );

      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      final formattedBody = _formatBody(response.data);

      // Convert to domain response
      return domain.ApiResponse(
        statusCode: response.statusCode ?? 0,
        statusMessage: response.statusMessage ?? 'OK',
        headers: _convertHeaders(response.headers.map),
        body: formattedBody,
        responseTimeMs: responseTime,
        sizeBytes: formattedBody.length,
        timestamp: endTime,
      );
    } catch (e) {
      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      // If Dio error contains an HTTP response, preserve status, headers, and body
      if (e is DioException && e.response != null) {
        final resp = e.response!;
        final formattedBody = _formatBody(resp.data);
        return domain.ApiResponse(
          statusCode: resp.statusCode ?? 0,
          statusMessage: resp.statusMessage ?? (e.message ?? 'Error'),
          headers: _convertHeaders(resp.headers.map),
          body: formattedBody,
          responseTimeMs: responseTime,
          sizeBytes: formattedBody.length,
          timestamp: endTime,
          error: e.message ?? e.toString(),
        );
      }

      String errorMessage = e.toString();
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            errorMessage = 'Connection timeout (${request.timeoutMs}ms)';
            break;
          case DioExceptionType.sendTimeout:
            errorMessage = 'Send timeout (${request.timeoutMs}ms)';
            break;
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Receive timeout (${request.timeoutMs}ms)';
            break;
          case DioExceptionType.badCertificate:
            errorMessage = 'Bad SSL certificate';
            break;
          case DioExceptionType.connectionError:
            errorMessage = 'Connection failed: ${e.error ?? e.message ?? "Server unreachable"}';
            break;
          default:
            if (e.message != null && e.message!.isNotEmpty) {
              errorMessage = e.message!;
            }
            break;
        }
      }

      return domain.ApiResponse(
        statusCode: 0,
        statusMessage: 'Connection Error',
        headers: {},
        body: '',
        responseTimeMs: responseTime,
        sizeBytes: 0,
        timestamp: endTime,
        error: errorMessage,
      );
    }
  }

  /// Build headers including auth and auto content-type
  Map<String, dynamic> _buildHeaders(ApiRequest request) {
    final headers = <String, dynamic>{...request.headers};

    // Auto-detect JSON Content-Type if not explicitly set
    final hasContentType = headers.keys.any(
      (k) => k.toLowerCase() == 'content-type',
    );
    if (!hasContentType && request.body != null && request.body!.trim().isNotEmpty) {
      final trimmed = request.body!.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        headers['Content-Type'] = 'application/json';
      }
    }

    // Add authentication
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

  /// Format response body
  String _formatBody(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;

    try {
      // Try to format as JSON
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  /// Dispose
  void dispose() {
    _dio.close();
  }
}
