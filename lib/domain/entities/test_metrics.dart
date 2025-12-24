// Domain Entity: Test Metrics
// Real-time metrics collected during load testing
// Aggregated data for performance analysis

import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_metrics.freezed.dart';
part 'test_metrics.g.dart';

@freezed
class TestMetrics with _$TestMetrics {
  const factory TestMetrics({
    required DateTime timestamp,

    /// Total number of requests completed
    @Default(0) int totalRequests,

    /// Successful requests (2xx status)
    @Default(0) int successCount,

    /// Failed requests (4xx, 5xx, or errors)
    @Default(0) int failureCount,

    /// Current requests per second
    @Default(0.0) double currentRps,

    /// Average response time in milliseconds
    @Default(0.0) double avgResponseTimeMs,

    /// Minimum response time
    @Default(0.0) double minResponseTimeMs,

    /// Maximum response time
    @Default(0.0) double maxResponseTimeMs,

    /// 50th percentile (median)
    @Default(0.0) double p50ResponseTimeMs,

    /// 95th percentile
    @Default(0.0) double p95ResponseTimeMs,

    /// 99th percentile
    @Default(0.0) double p99ResponseTimeMs,

    /// Error rate (0.0 to 1.0)
    @Default(0.0) double errorRate,

    /// Active virtual users
    @Default(0) int activeUsers,

    /// Time series data for charting (last N seconds)
    @Default([]) List<DataPoint> rpsHistory,
    @Default([]) List<DataPoint> responseTimeHistory,
    @Default([]) List<DataPoint> errorRateHistory,
  }) = _TestMetrics;

  factory TestMetrics.fromJson(Map<String, dynamic> json) =>
      _$TestMetricsFromJson(json);
}

@freezed
class DataPoint with _$DataPoint {
  const factory DataPoint({
    required DateTime timestamp,
    required double value,
  }) = _DataPoint;

  factory DataPoint.fromJson(Map<String, dynamic> json) =>
      _$DataPointFromJson(json);
}

/// Extension for metrics calculations
extension TestMetricsCalculations on TestMetrics {
  double get successRate =>
      totalRequests > 0 ? successCount / totalRequests : 0.0;

  String get errorRatePercentage => '${(errorRate * 100).toStringAsFixed(2)}%';

  String get successRatePercentage =>
      '${(successRate * 100).toStringAsFixed(2)}%';
}
