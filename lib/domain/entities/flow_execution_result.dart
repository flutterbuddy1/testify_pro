// Flow Execution Result - Captures flow run output
// Stores detailed results of each step execution

import '../../domain/entities/api_response.dart';
import '../../domain/entities/api_request.dart';

class FlowExecutionResult {
  final String flowId;
  final String flowName;
  final DateTime startTime;
  final DateTime endTime;
  final bool success;
  final String? errorMessage;
  final List<StepExecutionResult> stepResults;
  final Map<String, dynamic> extractedVariables;

  FlowExecutionResult({
    required this.flowId,
    required this.flowName,
    required this.startTime,
    required this.endTime,
    required this.success,
    this.errorMessage,
    required this.stepResults,
    required this.extractedVariables,
  });

  Duration get duration => endTime.difference(startTime);
  int get totalSteps => stepResults.length;
  int get successfulSteps => stepResults.where((s) => s.success).length;
  int get failedSteps => stepResults.where((s) => !s.success).length;

  Map<String, dynamic> toJson() => {
    'flowId': flowId,
    'flowName': flowName,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'success': success,
    'errorMessage': errorMessage,
    'stepResults': stepResults.map((s) => s.toJson()).toList(),
    'extractedVariables': extractedVariables,
  };

  factory FlowExecutionResult.fromJson(Map<String, dynamic> json) =>
      FlowExecutionResult(
        flowId: json['flowId'],
        flowName: json['flowName'],
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        success: json['success'],
        errorMessage: json['errorMessage'],
        stepResults: (json['stepResults'] as List)
            .map((s) => StepExecutionResult.fromJson(s))
            .toList(),
        extractedVariables: Map<String, dynamic>.from(
          json['extractedVariables'],
        ),
      );
}

class StepExecutionResult {
  final int stepIndex;
  final String stepName;
  final DateTime startTime;
  final DateTime endTime;
  final bool success;
  final String? errorMessage;
  final ApiRequest? request;
  final ApiResponse? response;
  final Map<String, dynamic> extractedVars;

  StepExecutionResult({
    required this.stepIndex,
    required this.stepName,
    required this.startTime,
    required this.endTime,
    required this.success,
    this.errorMessage,
    this.request,
    this.response,
    required this.extractedVars,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toJson() => {
    'stepIndex': stepIndex,
    'stepName': stepName,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'success': success,
    'errorMessage': errorMessage,
    'request': request?.toJson(),
    'response': response?.toJson(),
    'extractedVars': extractedVars,
  };

  factory StepExecutionResult.fromJson(Map<String, dynamic> json) =>
      StepExecutionResult(
        stepIndex: json['stepIndex'],
        stepName: json['stepName'],
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        success: json['success'],
        errorMessage: json['errorMessage'],
        request: json['request'] != null
            ? ApiRequest.fromJson(json['request'])
            : null,
        response: json['response'] != null
            ? ApiResponse.fromJson(json['response'])
            : null,
        extractedVars: Map<String, dynamic>.from(json['extractedVars']),
      );
}
