// Flow Executor with Result Tracking - Execute Multi-Step API Flows
// Enhanced to capture detailed execution results and save to local storage

import '../../domain/entities/flow.dart' as entities;
import '../../domain/entities/flow_step.dart';
import '../../domain/entities/api_request.dart';
import '../../domain/entities/api_response.dart';
import '../../domain/entities/test_run.dart';
import '../../domain/entities/flow_execution_result.dart';
import '../../data/services/http_service.dart';
import '../../data/repositories/test_run_repository.dart';
import 'flow_context.dart';
import 'json_extractor.dart';
import 'variable_injector.dart';
import 'package:uuid/uuid.dart';

class FlowExecutor {
  final HttpService _httpService;
  final TestRunRepository? _repository;
  final JsonExtractor _jsonExtractor = JsonExtractor();
  final _uuid = const Uuid();

  FlowExecutor(this._httpService, {TestRunRepository? repository})
    : _repository = repository;

  /// Execute a complete flow and save results
  Future<FlowExecutionResult> executeWithTracking(
    entities.Flow flow, {
    Function(StepExecutionResult)? onStepComplete,
  }) async {
    final startTime = DateTime.now();
    final stepResults = <StepExecutionResult>[];
    bool success = true;
    String? errorMessage;

    final context = FlowContext(flow);

    try {
      while (!context.isComplete && !context.hasError) {
        final step = context.currentStep;
        if (step == null) break;

        if (!step.enabled) {
          context.moveToNextStep();
          continue;
        }

        final stepResult = await _executeStepWithTracking(step, context);
        stepResults.add(stepResult);
        onStepComplete?.call(stepResult);

        if (!stepResult.success) {
          success = false;
          errorMessage = stepResult.errorMessage;
          if (step.stopOnFailure) break;
        }

        if (!context.moveToNextStep()) break;
      }

      if (context.hasError) {
        success = false;
        errorMessage = context.errorMessage;
      }
    } catch (e) {
      success = false;
      errorMessage = 'Execution error: $e';
    }

    final endTime = DateTime.now();

    final result = FlowExecutionResult(
      flowId: flow.id,
      flowName: flow.name,
      startTime: startTime,
      endTime: endTime,
      success: success,
      errorMessage: errorMessage,
      stepResults: stepResults,
      extractedVariables: context.variables,
    );

    // Save to repository
    if (_repository != null) {
      await _saveTestRun(flow, result, startTime, endTime);
    }

    return result;
  }

  /// Execute original method for backward compatibility
  Future<FlowContext> execute(entities.Flow flow) async {
    final context = FlowContext(flow);

    while (!context.isComplete && !context.hasError) {
      final step = context.currentStep;
      if (step == null) break;

      if (!step.enabled) {
        context.moveToNextStep();
        continue;
      }

      try {
        await _executeStep(step, context);
      } catch (e) {
        context.setError('Step "${step.name}" failed: $e');
        break;
      }

      if (step.stopOnFailure && context.history.last.response.hasError) {
        context.setError('Step "${step.name}" failed, stopping flow');
        break;
      }

      if (!context.moveToNextStep()) break;
    }

    return context;
  }

  /// Execute step with detailed tracking
  Future<StepExecutionResult> _executeStepWithTracking(
    FlowStep step,
    FlowContext context,
  ) async {
    final stepStartTime = DateTime.now();
    final stepIndex = context.currentStepIndex;
    bool success = true;
    String? errorMessage;
    ApiResponse? response;
    ApiRequest? injectedRequest;
    final extractedVars = <String, dynamic>{};

    try {
      // Inject variables
      final injector = VariableInjector(context.variables);
      injectedRequest = _injectVariablesIntoRequest(step.request, injector);

      // Execute request
      response = await _httpService.execute(injectedRequest);

      // Extract variables
      if (step.extractors.isNotEmpty && !response.hasError) {
        final vars = _jsonExtractor.extractMultiple(
          response.body,
          step.extractors,
        );
        extractedVars.addAll(vars);
        context.setVariables(vars);
      }

      // Evaluate assertions
      if (step.assertions.isNotEmpty) {
        final assertionsPassed = _evaluateAssertions(step.assertions, response);
        if (!assertionsPassed) {
          success = false;
          errorMessage = 'Assertions failed';
        }
      }

      // Record in context
      context.recordStepResult(step, response);

      // Think time
      if (step.thinkTimeMs > 0) {
        await Future.delayed(Duration(milliseconds: step.thinkTimeMs));
      }
    } catch (e) {
      success = false;
      errorMessage = e.toString();
    }

    final stepEndTime = DateTime.now();

    return StepExecutionResult(
      stepIndex: stepIndex,
      stepName: step.name,
      startTime: stepStartTime,
      endTime: stepEndTime,
      success: success,
      errorMessage: errorMessage,
      request: injectedRequest,
      response: response,
      extractedVars: extractedVars,
    );
  }

  /// Execute a single step (original method)
  Future<void> _executeStep(FlowStep step, FlowContext context) async {
    final injector = VariableInjector(context.variables);
    final injectedRequest = _injectVariablesIntoRequest(step.request, injector);
    final response = await _httpService.execute(injectedRequest);

    if (step.extractors.isNotEmpty && !response.hasError) {
      final extractedVars = _jsonExtractor.extractMultiple(
        response.body,
        step.extractors,
      );
      if (extractedVars.isNotEmpty) {
        context.setVariables(extractedVars);
      }
    }

    if (step.assertions.isNotEmpty) {
      final assertionsPassed = _evaluateAssertions(step.assertions, response);
      if (!assertionsPassed) {
        context.setError('Assertions failed for step "${step.name}"');
      }
    }

    context.recordStepResult(step, response);

    if (step.thinkTimeMs > 0) {
      await Future.delayed(Duration(milliseconds: step.thinkTimeMs));
    }
  }

  ApiRequest _injectVariablesIntoRequest(
    ApiRequest request,
    VariableInjector injector,
  ) {
    return ApiRequest(
      id: request.id,
      name: request.name,
      url: injector.inject(request.url),
      method: request.method,
      headers: request.headers.map(
        (k, v) =>
            MapEntry(injector.inject(k), injector.inject(v?.toString() ?? '')),
      ),
      queryParams: request.queryParams.map(
        (k, v) =>
            MapEntry(injector.inject(k), injector.inject(v?.toString() ?? '')),
      ),
      body: request.body != null ? injector.inject(request.body!) : null,
      auth: request.auth,
      timeoutMs: request.timeoutMs,
    );
  }

  bool _evaluateAssertions(List<Assertion> assertions, ApiResponse response) {
    for (final assertion in assertions) {
      final passed = _evaluateAssertion(assertion, response);
      if (!passed) return false;
    }
    return true;
  }

  bool _evaluateAssertion(Assertion assertion, ApiResponse response) {
    switch (assertion.type) {
      case AssertionType.statusCode:
        final expected = int.tryParse(assertion.expected) ?? 0;
        return response.statusCode == expected;
      case AssertionType.responseTime:
        final expected = int.tryParse(assertion.expected) ?? 0;
        return response.responseTimeMs <= expected;
      case AssertionType.jsonPath:
        if (assertion.actual == null) return false;
        final value = _jsonExtractor.extract(response.body, assertion.actual!);
        return value == assertion.expected;
      case AssertionType.contains:
        return response.body.contains(assertion.expected);
      case AssertionType.notContains:
        return !response.body.contains(assertion.expected);
    }
  }

  Future<void> _saveTestRun(
    entities.Flow flow,
    FlowExecutionResult result,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final testRun = TestRun(
      id: _uuid.v4(),
      name: 'Flow: ${flow.name}',
      type: TestType.flow,
      status: result.success ? TestStatus.completed : TestStatus.failed,
      startTime: startTime,
      endTime: endTime,
      config: {
        'flowId': flow.id,
        'flowName': flow.name,
        'totalSteps': result.totalSteps,
      },
      metadata: {'result': result.toJson()},
    );

    await _repository!.saveTestRun(testRun);
  }
}
