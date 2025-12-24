// Domain Entity: API Response
// Represents the response received from an HTTP API request
// Includes timing, status, headers, and body information

import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@freezed
class ApiResponse with _$ApiResponse {
  const factory ApiResponse({
    required int statusCode,
    required String statusMessage,
    required Map<String, dynamic> headers,
    required String body,
    required int responseTimeMs,
    required int sizeBytes,
    required DateTime timestamp,
    String? error,
  }) = _ApiResponse;

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);
}

/// Extension to check response status
extension ApiResponseStatus on ApiResponse {
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
  bool get hasError => error != null;
}
