// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flow_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlowStepImpl _$$FlowStepImplFromJson(Map<String, dynamic> json) =>
    _$FlowStepImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      request: ApiRequest.fromJson(json['request'] as Map<String, dynamic>),
      extractors: (json['extractors'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      assertions: (json['assertions'] as List<dynamic>?)
              ?.map((e) => Assertion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      thinkTimeMs: (json['thinkTimeMs'] as num?)?.toInt() ?? 0,
      stopOnFailure: json['stopOnFailure'] as bool? ?? true,
      enabled: json['enabled'] as bool? ?? true,
      preRequestScript: json['preRequestScript'] as String?,
      testScript: json['testScript'] as String?,
    );

Map<String, dynamic> _$$FlowStepImplToJson(_$FlowStepImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'request': instance.request.toJson(),
      'extractors': instance.extractors,
      'assertions': instance.assertions.map((e) => e.toJson()).toList(),
      'thinkTimeMs': instance.thinkTimeMs,
      'stopOnFailure': instance.stopOnFailure,
      'enabled': instance.enabled,
      'preRequestScript': instance.preRequestScript,
      'testScript': instance.testScript,
    };

_$AssertionImpl _$$AssertionImplFromJson(Map<String, dynamic> json) =>
    _$AssertionImpl(
      name: json['name'] as String,
      type: $enumDecode(_$AssertionTypeEnumMap, json['type']),
      expected: json['expected'] as String,
      actual: json['actual'] as String?,
    );

Map<String, dynamic> _$$AssertionImplToJson(_$AssertionImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$AssertionTypeEnumMap[instance.type]!,
      'expected': instance.expected,
      'actual': instance.actual,
    };

const _$AssertionTypeEnumMap = {
  AssertionType.statusCode: 'statusCode',
  AssertionType.responseTime: 'responseTime',
  AssertionType.jsonPath: 'jsonPath',
  AssertionType.contains: 'contains',
  AssertionType.notContains: 'notContains',
};
