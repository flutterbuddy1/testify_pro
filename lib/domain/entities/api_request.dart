// Domain Entity: API Request
// Represents a single HTTP API request with all its configuration
// This is a pure domain model with no external dependencies

import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_request.freezed.dart';
part 'api_request.g.dart';

@freezed
class ApiRequest with _$ApiRequest {
  const factory ApiRequest({
    required String id,
    required String name,
    required String url,
    required HttpMethod method,
    @Default({}) Map<String, String> headers,
    @Default({}) Map<String, String> queryParams,
    String? body,
    AuthConfig? auth,
    @Default(30000) int timeoutMs,
  }) = _ApiRequest;

  factory ApiRequest.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestFromJson(json);
}

/// HTTP Methods supported by the API testing tool
enum HttpMethod { get, post, put, patch, delete, head, options }

/// Authentication Configuration
@freezed
class AuthConfig with _$AuthConfig {
  const factory AuthConfig.bearer({required String token}) = BearerAuth;

  const factory AuthConfig.basic({
    required String username,
    required String password,
  }) = BasicAuth;

  const factory AuthConfig.apiKey({
    required String key,
    required String value,
    @Default(ApiKeyLocation.header) ApiKeyLocation location,
  }) = ApiKeyAuth;

  factory AuthConfig.fromJson(Map<String, dynamic> json) =>
      _$AuthConfigFromJson(json);
}

enum ApiKeyLocation { header, query }
