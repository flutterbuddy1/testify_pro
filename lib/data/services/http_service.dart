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

      // Build URL with query params
      final uri = Uri.parse(request.url);
      final finalUri = uri.replace(
        queryParameters: {...uri.queryParameters, ...request.queryParams},
      );

      // Execute request
      final response = await _dio.request(
        finalUri.toString(),
        data: request.body,
        options: options,
      );

      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      // Convert to domain response
      return domain.ApiResponse(
        statusCode: response.statusCode ?? 0,
        statusMessage: response.statusMessage ?? '',
        headers: _convertHeaders(response.headers.map),
        body: _formatBody(response.data),
        responseTimeMs: responseTime,
        sizeBytes: _formatBody(response.data).length,
        timestamp: endTime,
      );
    } catch (e) {
      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      return domain.ApiResponse(
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
