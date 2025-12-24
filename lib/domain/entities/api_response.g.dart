// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiResponseImpl _$$ApiResponseImplFromJson(Map<String, dynamic> json) =>
    _$ApiResponseImpl(
      statusCode: (json['statusCode'] as num).toInt(),
      statusMessage: json['statusMessage'] as String,
      headers: json['headers'] as Map<String, dynamic>,
      body: json['body'] as String,
      responseTimeMs: (json['responseTimeMs'] as num).toInt(),
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$ApiResponseImplToJson(_$ApiResponseImpl instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'statusMessage': instance.statusMessage,
      'headers': instance.headers,
      'body': instance.body,
      'responseTimeMs': instance.responseTimeMs,
      'sizeBytes': instance.sizeBytes,
      'timestamp': instance.timestamp.toIso8601String(),
      'error': instance.error,
    };
