// Domain Entity: Load Test Configuration
// Defines how a load test should be executed
// Includes virtual users, duration, ramp-up strategy

import 'package:freezed_annotation/freezed_annotation.dart';

part 'load_test_config.freezed.dart';
part 'load_test_config.g.dart';

@freezed
class LoadTestConfig with _$LoadTestConfig {
  const factory LoadTestConfig({
    required String id,
    required String name,

    /// Test target - either a single request ID or flow ID
    required String targetId,
    required TargetType targetType,

    /// Number of virtual users to simulate
    required int virtualUsers,

    /// Test duration in seconds
    required int durationSeconds,

    /// Ramp-up time in seconds (gradual increase of users)
    @Default(0) int rampUpSeconds,

    /// Ramp-down time in seconds (gradual decrease of users)
    @Default(0) int rampDownSeconds,

    /// Target requests per second (0 = unlimited)
    @Default(0) int targetRps,

    /// Think time between iterations in milliseconds
    @Default(1000) int thinkTimeMs,

    required DateTime createdAt,
  }) = _LoadTestConfig;

  factory LoadTestConfig.fromJson(Map<String, dynamic> json) =>
      _$LoadTestConfigFromJson(json);
}

enum TargetType { request, flow }

/// Extension for load test validation
extension LoadTestConfigValidation on LoadTestConfig {
  bool get isValid =>
      virtualUsers > 0 &&
      durationSeconds > 0 &&
      rampUpSeconds >= 0 &&
      rampDownSeconds >= 0;

  /// Calculate number of worker isolates to spawn
  /// Based on CPU cores, typically 4-8 workers
  int get recommendedWorkers {
    if (virtualUsers <= 100) return 2;
    if (virtualUsers <= 1000) return 4;
    if (virtualUsers <= 10000) return 8;
    return 16; // Max workers for very high load
  }

  /// Calculate users per worker
  int usersPerWorker(int workers) => (virtualUsers / workers).ceil();
}
