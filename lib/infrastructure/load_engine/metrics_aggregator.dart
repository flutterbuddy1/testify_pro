// Metrics Aggregator - Real-time Performance Metrics Calculator
//
// RESPONSIBILITIES:
// - Collects individual request results from workers
// - Computes aggregated metrics (RPS, avg response time, percentiles)
// - Maintains time-series data for charting
// - Calculates percentiles efficiently
//
// PERFORMANCE OPTIMIZATION:
// - Does NOT emit metrics per request (would overwhelm UI)
// - Aggregates internally and emits every 1 second
// - Uses efficient percentile calculation
// - Limits history data points to prevent memory growth
//
// METRICS PROVIDED:
// - Total requests, success/failure counts
// - Current RPS (requests per second)
// - Response time statistics (min, max, avg, p50, p95, p99)
// - Error rate
// - Time-series data for charting

import '../../domain/entities/api_response.dart';
import '../../domain/entities/test_metrics.dart';
import '../../core/constants/app_constants.dart';

class MetricsAggregator {
  // Request results buffer
  final List<ApiResponse> _results = [];

  // Recent responses sample buffer (for UI logs)
  final List<ApiResponse> _recentResponses = [];
  static const int _maxSampleSize = 50;

  // Time series data
  final List<DataPoint> _rpsHistory = [];
  final List<DataPoint> _responseTimeHistory = [];
  final List<DataPoint> _errorRateHistory = [];

  // Counters
  int _totalRequests = 0;
  int _successCount = 0;
  int _failureCount = 0;
  int _activeUsers = 0;

  // Timing
  DateTime? _startTime;
  DateTime? _lastMetricTime;
  int _lastRequestCount = 0;

  /// Add a request result
  void addResult(ApiResponse response) {
    _results.add(response);
    _totalRequests++;

    if (response.isSuccess) {
      _successCount++;
    } else {
      _failureCount++;
    }

    // Add to recent responses buffer (sampling)
    _recentResponses.insert(0, response);
    if (_recentResponses.length > _maxSampleSize) {
      _recentResponses.removeLast();
    }

    if (_startTime == null) {
      _startTime = DateTime.now();
      _lastMetricTime = _startTime; // Initialize last metric time to start time
    }
  }

  /// Set active users count (for ramp-up)
  void setActiveUsers(int count) {
    _activeUsers = count;
  }

  /// Get current aggregated metrics
  TestMetrics getCurrentMetrics() {
    final now = DateTime.now();

    // Calculate RPS
    final rps = _calculateCurrentRps(now);

    // Calculate response time statistics
    final responseStats = _calculateResponseTimeStats();

    // Calculate error rate
    final errorRate = _totalRequests > 0 ? _failureCount / _totalRequests : 0.0;

    // Update time series
    _updateTimeSeries(now, rps, responseStats.avg, errorRate);

    _lastMetricTime = now;

    return TestMetrics(
      timestamp: now,
      totalRequests: _totalRequests,
      successCount: _successCount,
      failureCount: _failureCount,
      currentRps: rps,
      avgResponseTimeMs: responseStats.avg,
      minResponseTimeMs: responseStats.min,
      maxResponseTimeMs: responseStats.max,
      p50ResponseTimeMs: responseStats.p50,
      p95ResponseTimeMs: responseStats.p95,
      p99ResponseTimeMs: responseStats.p99,
      errorRate: errorRate,
      activeUsers: _activeUsers,
      rpsHistory: List.from(_rpsHistory),
      responseTimeHistory: List.from(_responseTimeHistory),
      errorRateHistory: List.from(_errorRateHistory),
    );
  }

  /// Get recent responses for UI logs
  List<ApiResponse> get recentResponses => List.from(_recentResponses);

  /// Calculate current RPS
  double _calculateCurrentRps(DateTime now) {
    if (_lastMetricTime == null) return 0.0;

    final elapsedSeconds =
        now.difference(_lastMetricTime!).inMilliseconds / 1000.0;
    if (elapsedSeconds <= 0) return 0.0;

    final newRequests = _totalRequests - _lastRequestCount;
    _lastRequestCount = _totalRequests;

    return newRequests / elapsedSeconds;
  }

  /// Calculate response time statistics including percentiles
  _ResponseStats _calculateResponseTimeStats() {
    if (_results.isEmpty) {
      return _ResponseStats(
        min: 0.0,
        max: 0.0,
        avg: 0.0,
        p50: 0.0,
        p95: 0.0,
        p99: 0.0,
      );
    }

    // Extract response times and sort for percentile calculation
    final responseTimes =
        _results.map((r) => r.responseTimeMs.toDouble()).toList()..sort();

    final min = responseTimes.first;
    final max = responseTimes.last;
    final avg = responseTimes.reduce((a, b) => a + b) / responseTimes.length;

    // Calculate percentiles
    final p50 = _percentile(responseTimes, 0.50);
    final p95 = _percentile(responseTimes, 0.95);
    final p99 = _percentile(responseTimes, 0.99);

    return _ResponseStats(
      min: min,
      max: max,
      avg: avg,
      p50: p50,
      p95: p95,
      p99: p99,
    );
  }

  /// Calculate percentile value
  double _percentile(List<double> sortedValues, double percentile) {
    if (sortedValues.isEmpty) return 0.0;

    final index = (sortedValues.length * percentile).ceil() - 1;
    return sortedValues[index.clamp(0, sortedValues.length - 1)];
  }

  /// Update time series data for charting
  void _updateTimeSeries(
    DateTime now,
    double rps,
    double avgResponseTime,
    double errorRate,
  ) {
    // Add new data points
    _rpsHistory.add(DataPoint(timestamp: now, value: rps));
    _responseTimeHistory.add(DataPoint(timestamp: now, value: avgResponseTime));
    _errorRateHistory.add(DataPoint(timestamp: now, value: errorRate));

    // Limit history size to prevent memory growth
    final maxPoints = AppConstants.maxHistoryDataPoints;

    if (_rpsHistory.length > maxPoints) {
      _rpsHistory.removeAt(0);
    }
    if (_responseTimeHistory.length > maxPoints) {
      _responseTimeHistory.removeAt(0);
    }
    if (_errorRateHistory.length > maxPoints) {
      _errorRateHistory.removeAt(0);
    }

    // Periodically clear old results to prevent memory growth
    // Keep only recent results for percentile calculation
    if (_results.length > 10000) {
      _results.removeRange(0, _results.length - 5000);
    }
  }

  /// Reset all metrics
  void reset() {
    _results.clear();
    _rpsHistory.clear();
    _responseTimeHistory.clear();
    _errorRateHistory.clear();
    _totalRequests = 0;
    _successCount = 0;
    _failureCount = 0;
    _activeUsers = 0;
    _recentResponses.clear();
    _startTime = null;
    _lastMetricTime = null;
    _lastRequestCount = 0;
  }
}

/// Response time statistics
class _ResponseStats {
  final double min;
  final double max;
  final double avg;
  final double p50;
  final double p95;
  final double p99;

  _ResponseStats({
    required this.min,
    required this.max,
    required this.avg,
    required this.p50,
    required this.p95,
    required this.p99,
  });
}
