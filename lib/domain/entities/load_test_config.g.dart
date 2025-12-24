// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_test_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoadTestConfigImpl _$$LoadTestConfigImplFromJson(Map<String, dynamic> json) =>
    _$LoadTestConfigImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      targetId: json['targetId'] as String,
      targetType: $enumDecode(_$TargetTypeEnumMap, json['targetType']),
      virtualUsers: (json['virtualUsers'] as num).toInt(),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      rampUpSeconds: (json['rampUpSeconds'] as num?)?.toInt() ?? 0,
      rampDownSeconds: (json['rampDownSeconds'] as num?)?.toInt() ?? 0,
      targetRps: (json['targetRps'] as num?)?.toInt() ?? 0,
      thinkTimeMs: (json['thinkTimeMs'] as num?)?.toInt() ?? 1000,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LoadTestConfigImplToJson(
        _$LoadTestConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'targetId': instance.targetId,
      'targetType': _$TargetTypeEnumMap[instance.targetType]!,
      'virtualUsers': instance.virtualUsers,
      'durationSeconds': instance.durationSeconds,
      'rampUpSeconds': instance.rampUpSeconds,
      'rampDownSeconds': instance.rampDownSeconds,
      'targetRps': instance.targetRps,
      'thinkTimeMs': instance.thinkTimeMs,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TargetTypeEnumMap = {
  TargetType.request: 'request',
  TargetType.flow: 'flow',
};
