// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiRequestImpl _$$ApiRequestImplFromJson(Map<String, dynamic> json) =>
    _$ApiRequestImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      method: $enumDecode(_$HttpMethodEnumMap, json['method']),
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      queryParams: (json['queryParams'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      body: json['body'] as String?,
      auth: json['auth'] == null
          ? null
          : AuthConfig.fromJson(json['auth'] as Map<String, dynamic>),
      timeoutMs: (json['timeoutMs'] as num?)?.toInt() ?? 30000,
    );

Map<String, dynamic> _$$ApiRequestImplToJson(_$ApiRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'method': _$HttpMethodEnumMap[instance.method]!,
      'headers': instance.headers,
      'queryParams': instance.queryParams,
      'body': instance.body,
      'auth': instance.auth?.toJson(),
      'timeoutMs': instance.timeoutMs,
    };

const _$HttpMethodEnumMap = {
  HttpMethod.get: 'get',
  HttpMethod.post: 'post',
  HttpMethod.put: 'put',
  HttpMethod.patch: 'patch',
  HttpMethod.delete: 'delete',
  HttpMethod.head: 'head',
  HttpMethod.options: 'options',
};

_$BearerAuthImpl _$$BearerAuthImplFromJson(Map<String, dynamic> json) =>
    _$BearerAuthImpl(
      token: json['token'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$BearerAuthImplToJson(_$BearerAuthImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'runtimeType': instance.$type,
    };

_$BasicAuthImpl _$$BasicAuthImplFromJson(Map<String, dynamic> json) =>
    _$BasicAuthImpl(
      username: json['username'] as String,
      password: json['password'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$BasicAuthImplToJson(_$BasicAuthImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'runtimeType': instance.$type,
    };

_$ApiKeyAuthImpl _$$ApiKeyAuthImplFromJson(Map<String, dynamic> json) =>
    _$ApiKeyAuthImpl(
      key: json['key'] as String,
      value: json['value'] as String,
      location:
          $enumDecodeNullable(_$ApiKeyLocationEnumMap, json['location']) ??
              ApiKeyLocation.header,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ApiKeyAuthImplToJson(_$ApiKeyAuthImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'location': _$ApiKeyLocationEnumMap[instance.location]!,
      'runtimeType': instance.$type,
    };

const _$ApiKeyLocationEnumMap = {
  ApiKeyLocation.header: 'header',
  ApiKeyLocation.query: 'query',
};
