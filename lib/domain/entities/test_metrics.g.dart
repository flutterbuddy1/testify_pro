// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TestMetricsImpl _$$TestMetricsImplFromJson(Map<String, dynamic> json) =>
    _$TestMetricsImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      totalRequests: (json['totalRequests'] as num?)?.toInt() ?? 0,
      successCount: (json['successCount'] as num?)?.toInt() ?? 0,
      failureCount: (json['failureCount'] as num?)?.toInt() ?? 0,
      currentRps: (json['currentRps'] as num?)?.toDouble() ?? 0.0,
      avgResponseTimeMs: (json['avgResponseTimeMs'] as num?)?.toDouble() ?? 0.0,
      minResponseTimeMs: (json['minResponseTimeMs'] as num?)?.toDouble() ?? 0.0,
      maxResponseTimeMs: (json['maxResponseTimeMs'] as num?)?.toDouble() ?? 0.0,
      p50ResponseTimeMs: (json['p50ResponseTimeMs'] as num?)?.toDouble() ?? 0.0,
      p95ResponseTimeMs: (json['p95ResponseTimeMs'] as num?)?.toDouble() ?? 0.0,
      p99ResponseTimeMs: (json['p99ResponseTimeMs'] as num?)?.toDouble() ?? 0.0,
      errorRate: (json['errorRate'] as num?)?.toDouble() ?? 0.0,
      activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
      rpsHistory: (json['rpsHistory'] as List<dynamic>?)
              ?.map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      responseTimeHistory: (json['responseTimeHistory'] as List<dynamic>?)
              ?.map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      errorRateHistory: (json['errorRateHistory'] as List<dynamic>?)
              ?.map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TestMetricsImplToJson(_$TestMetricsImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'totalRequests': instance.totalRequests,
      'successCount': instance.successCount,
      'failureCount': instance.failureCount,
      'currentRps': instance.currentRps,
      'avgResponseTimeMs': instance.avgResponseTimeMs,
      'minResponseTimeMs': instance.minResponseTimeMs,
      'maxResponseTimeMs': instance.maxResponseTimeMs,
      'p50ResponseTimeMs': instance.p50ResponseTimeMs,
      'p95ResponseTimeMs': instance.p95ResponseTimeMs,
      'p99ResponseTimeMs': instance.p99ResponseTimeMs,
      'errorRate': instance.errorRate,
      'activeUsers': instance.activeUsers,
      'rpsHistory': instance.rpsHistory.map((e) => e.toJson()).toList(),
      'responseTimeHistory':
          instance.responseTimeHistory.map((e) => e.toJson()).toList(),
      'errorRateHistory':
          instance.errorRateHistory.map((e) => e.toJson()).toList(),
    };

_$DataPointImpl _$$DataPointImplFromJson(Map<String, dynamic> json) =>
    _$DataPointImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$$DataPointImplToJson(_$DataPointImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'value': instance.value,
    };
