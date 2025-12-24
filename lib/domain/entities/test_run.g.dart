// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TestRunImpl _$$TestRunImplFromJson(Map<String, dynamic> json) =>
    _$TestRunImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$TestTypeEnumMap, json['type']),
      status: $enumDecode(_$TestStatusEnumMap, json['status']),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      config: json['config'] as Map<String, dynamic>? ?? const {},
      finalMetrics: json['finalMetrics'] == null
          ? null
          : TestMetrics.fromJson(json['finalMetrics'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$TestRunImplToJson(_$TestRunImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$TestTypeEnumMap[instance.type]!,
      'status': _$TestStatusEnumMap[instance.status]!,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'config': instance.config,
      'finalMetrics': instance.finalMetrics?.toJson(),
      'metadata': instance.metadata,
      'error': instance.error,
    };

const _$TestTypeEnumMap = {
  TestType.api: 'api',
  TestType.flow: 'flow',
  TestType.load: 'load',
};

const _$TestStatusEnumMap = {
  TestStatus.running: 'running',
  TestStatus.completed: 'completed',
  TestStatus.stopped: 'stopped',
  TestStatus.failed: 'failed',
};
