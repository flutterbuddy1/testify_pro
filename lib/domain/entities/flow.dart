// Domain Entity: Flow
// Represents a complete API flow/scenario with multiple steps
// This represents one user's journey through the application

import 'package:freezed_annotation/freezed_annotation.dart';
import 'flow_step.dart';

part 'flow.freezed.dart';
part 'flow.g.dart';

@freezed
class Flow with _$Flow {
  const factory Flow({
    required String id,
    required String name,
    String? description,
    required List<FlowStep> steps,

    /// Global variables available to all steps
    @Default({}) Map<String, String> variables,

    /// Tags for organization
    @Default([]) List<String> tags,

    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Flow;

  factory Flow.fromJson(Map<String, dynamic> json) => _$FlowFromJson(json);
}

/// Extension for flow validation
extension FlowValidation on Flow {
  bool get isValid => steps.isNotEmpty && steps.every((step) => step.enabled);
  int get enabledStepsCount => steps.where((step) => step.enabled).length;
}
