// Flow Context - Execution State for a Single Flow Instance
//
// PURPOSE:
// - Maintains state during flow execution
// - Stores variables extracted from responses
// - Tracks current step and execution history
// - Provides error handling context
//
// LIFECYCLE:
// - Created when flow starts
// - Updated after each step (variables extracted, step completed)
// - Disposed when flow completes or fails
//
// USAGE:
// final context = FlowContext(flow);
// context.setVariable('authToken', 'abc123');
// final token = context.getVariable('authToken');
// context.moveToNextStep();

import '../../domain/entities/flow.dart';
import '../../domain/entities/flow_step.dart';
import '../../domain/entities/api_response.dart';

class FlowContext {
  final Flow flow;

  // Execution state
  int _currentStepIndex = 0;
  final Map<String, String> _variables;
  final List<StepResult> _history = [];
  bool _hasError = false;
  String? _errorMessage;

  FlowContext(this.flow) : _variables = Map.from(flow.variables);

  /// Current step being executed
  FlowStep? get currentStep {
    if (_currentStepIndex >= flow.steps.length) return null;
    return flow.steps[_currentStepIndex];
  }

  /// Get variable value
  String? getVariable(String name) => _variables[name];

  /// Set variable value
  void setVariable(String name, String value) {
    _variables[name] = value;
  }

  /// Set multiple variables
  void setVariables(Map<String, String> variables) {
    _variables.addAll(variables);
  }

  /// Get all variables
  Map<String, String> get variables => Map.from(_variables);

  /// Move to next step
  bool moveToNextStep() {
    _currentStepIndex++;
    return _currentStepIndex < flow.steps.length;
  }

  /// Record step result
  void recordStepResult(FlowStep step, ApiResponse response) {
    _history.add(
      StepResult(step: step, response: response, timestamp: DateTime.now()),
    );
  }

  /// Mark as errored
  void setError(String message) {
    _hasError = true;
    _errorMessage = message;
  }

  /// Check if flow is complete
  bool get isComplete => _currentStepIndex >= flow.steps.length;

  /// Check if flow has error
  bool get hasError => _hasError;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Get execution history
  List<StepResult> get history => List.from(_history);

  /// Get current step index
  int get currentStepIndex => _currentStepIndex;

  /// Get total steps
  int get totalSteps => flow.steps.length;

  /// Get progress percentage
  double get progress => totalSteps > 0 ? _currentStepIndex / totalSteps : 0.0;

  /// Reset context to start
  void reset() {
    _currentStepIndex = 0;
    _variables.clear();
    _variables.addAll(flow.variables);
    _history.clear();
    _hasError = false;
    _errorMessage = null;
  }
}

/// Result of a single step execution
class StepResult {
  final FlowStep step;
  final ApiResponse response;
  final DateTime timestamp;

  StepResult({
    required this.step,
    required this.response,
    required this.timestamp,
  });

  bool get success => response.isSuccess;
}
