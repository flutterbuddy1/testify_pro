// Domain Entity: Flow Step
// Represents a single step in an API flow/scenario
// Includes request, extractors (JSONPath), assertions, and think time

import 'package:freezed_annotation/freezed_annotation.dart';
import 'api_request.dart';

part 'flow_step.freezed.dart';
part 'flow_step.g.dart';

@freezed
class FlowStep with _$FlowStep {
  const factory FlowStep({
    required String id,
    required String name,
    required ApiRequest request,

    /// JSONPath extractors to extract data from response
    /// Format: {"variableName": "$.path.to.value"}
    @Default({}) Map<String, String> extractors,

    /// Assertions to validate response
    @Default([]) List<Assertion> assertions,

    /// Think time in milliseconds (simulates user delay before next step)
    @Default(0) int thinkTimeMs,

    /// Stop flow if this step fails
    @Default(true) bool stopOnFailure,

    /// Enable this step
    @Default(true) bool enabled,

    /// Optional pre-request script executed before the HTTP call
    String? preRequestScript,

    /// Optional test script executed after the response is received
    String? testScript,
  }) = _FlowStep;

  factory FlowStep.fromJson(Map<String, dynamic> json) =>
      _$FlowStepFromJson(json);
}

/// Assertion to validate response
@freezed
class Assertion with _$Assertion {
  const factory Assertion({
    required String name,
    required AssertionType type,
    required String expected,
    String? actual, // JSONPath to extract actual value
  }) = _Assertion;

  factory Assertion.fromJson(Map<String, dynamic> json) =>
      _$AssertionFromJson(json);
}

enum AssertionType { statusCode, responseTime, jsonPath, contains, notContains }
