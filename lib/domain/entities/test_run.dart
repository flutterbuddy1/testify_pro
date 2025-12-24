// Domain Entity: Test Run
// Complete test run with configuration, metrics, and results
// Used for test history and result export

import 'package:freezed_annotation/freezed_annotation.dart';
import 'test_metrics.dart';

part 'test_run.freezed.dart';
part 'test_run.g.dart';

/// Test type enum
enum TestType {
  api, // Single API request
  flow, // Multi-step flow
  load, // Load test
}

/// Test status enum
enum TestStatus { running, completed, stopped, failed }

@freezed
class TestRun with _$TestRun {
  const factory TestRun({
    required String id,
    required String name,
    required TestType type,
    required TestStatus status,
    required DateTime startTime,
    DateTime? endTime,

    /// Configuration (varies by test type)
    @Default({}) Map<String, dynamic> config,

    /// Final metrics snapshot
    TestMetrics? finalMetrics,

    /// Additional metadata (e.g., flow result, request details)
    @Default({}) Map<String, dynamic> metadata,

    /// Error messages if test failed
    String? error,
  }) = _TestRun;

  factory TestRun.fromJson(Map<String, dynamic> json) =>
      _$TestRunFromJson(json);
}

/// Extension for test run analysis
extension TestRunAnalysis on TestRun {
  Duration? get duration => endTime?.difference(startTime);

  bool get isActive => status == TestStatus.running;

  String get durationFormatted {
    final d = duration;
    if (d == null) return 'N/A';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  bool get isSuccessful => status == TestStatus.completed;
  bool get isFailed => status == TestStatus.failed;
}
