// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlowImpl _$$FlowImplFromJson(Map<String, dynamic> json) => _$FlowImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => FlowStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      variables: (json['variables'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$FlowImplToJson(_$FlowImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'steps': instance.steps.map((e) => e.toJson()).toList(),
      'variables': instance.variables,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
