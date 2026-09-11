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
import 'script_engine.dart';
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
      // Execute Pre-Request Script if present (e.g. calculateDOB, createMembers)
      if (step.preRequestScript != null && step.preRequestScript!.trim().isNotEmpty) {
        final preResult = ScriptEngine.executePreRequest(
          script: step.preRequestScript!,
          variables: context.variables,
        );
        if (preResult.modifiedVariables.isNotEmpty) {
          final stringified = preResult.modifiedVariables.map((k, v) => MapEntry(k, v?.toString() ?? ''));
          context.setVariables(stringified);
        }
      }

      // Inject variables
      final injector = VariableInjector(context.variables);
      injectedRequest = _injectVariablesIntoRequest(step.request, injector);

      // Execute request
      response = await _httpService.execute(injectedRequest);

      // Extract variables via JSONPath
      if (step.extractors.isNotEmpty && !response.hasError) {
        final vars = _jsonExtractor.extractMultiple(
          response.body,
          step.extractors,
        );
        extractedVars.addAll(vars);
        context.setVariables(vars);
      }

      // Evaluate native assertions
      if (step.assertions.isNotEmpty) {
        final assertionError = _evaluateAssertions(step.assertions, response);
        if (assertionError != null) {
          success = false;
          errorMessage = assertionError;
        }
      }

      // Execute Test Script if present (e.g. pm.expect, response value validation)
      if (step.testScript != null && step.testScript!.trim().isNotEmpty) {
        final testResult = ScriptEngine.executeTest(
          script: step.testScript!,
          variables: context.variables,
          response: response,
        );
        if (testResult.modifiedVariables.isNotEmpty) {
          final stringified = testResult.modifiedVariables.map((k, v) => MapEntry(k, v?.toString() ?? ''));
          extractedVars.addAll(stringified);
          context.setVariables(stringified);
        }
        if (!testResult.success && testResult.errorMessage != null) {
          success = false;
          errorMessage = errorMessage != null ? '$errorMessage; ${testResult.errorMessage}' : testResult.errorMessage;
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
    // Execute Pre-Request Script if present
    if (step.preRequestScript != null && step.preRequestScript!.trim().isNotEmpty) {
      final preResult = ScriptEngine.executePreRequest(
        script: step.preRequestScript!,
        variables: context.variables,
      );
      if (preResult.modifiedVariables.isNotEmpty) {
        context.setVariables(preResult.modifiedVariables.map((k, v) => MapEntry(k, v?.toString() ?? '')));
      }
    }

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
      final assertionError = _evaluateAssertions(step.assertions, response);
      if (assertionError != null) {
        context.setError(assertionError);
      }
    }

    // Execute Test Script if present
    if (step.testScript != null && step.testScript!.trim().isNotEmpty) {
      final testResult = ScriptEngine.executeTest(
        script: step.testScript!,
        variables: context.variables,
        response: response,
      );
      if (testResult.modifiedVariables.isNotEmpty) {
        context.setVariables(testResult.modifiedVariables.map((k, v) => MapEntry(k, v?.toString() ?? '')));
      }
      if (!testResult.success && testResult.errorMessage != null) {
        context.setError(testResult.errorMessage!);
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
        (k, v) => MapEntry(injector.inject(k), injector.inject(v)),
      ),
      queryParams: request.queryParams.map(
        (k, v) => MapEntry(injector.inject(k), injector.inject(v)),
      ),
      body: request.body != null ? injector.inject(request.body!) : null,
      auth: request.auth,
      timeoutMs: request.timeoutMs,
    );
  }

  String? _evaluateAssertions(List<Assertion> assertions, ApiResponse response) {
    for (final assertion in assertions) {
      final failure = _evaluateAssertion(assertion, response);
      if (failure != null) return failure;
    }
    return null;
  }

  String? _evaluateAssertion(Assertion assertion, ApiResponse response) {
    switch (assertion.type) {
      case AssertionType.statusCode:
        final expected = int.tryParse(assertion.expected) ?? 0;
        if (response.statusCode != expected) {
          return 'Assertion "${assertion.name}" failed: expected HTTP status $expected, got ${response.statusCode}';
        }
        return null;
      case AssertionType.responseTime:
        final expected = int.tryParse(assertion.expected) ?? 0;
        if (response.responseTimeMs > expected) {
          return 'Assertion "${assertion.name}" failed: response time ${response.responseTimeMs}ms exceeded max limit of ${expected}ms';
        }
        return null;
      case AssertionType.jsonPath:
        if (assertion.actual == null) {
          return 'Assertion "${assertion.name}" failed: missing JSONPath in "actual" field';
        }
        final value = _jsonExtractor.extract(response.body, assertion.actual!);
        if (value?.toString() != assertion.expected) {
          return 'Assertion "${assertion.name}" failed: JSONPath "${assertion.actual}" expected "${assertion.expected}", got "${value ?? 'null'}"';
        }
        return null;
      case AssertionType.contains:
        if (!response.body.contains(assertion.expected)) {
          return 'Assertion "${assertion.name}" failed: response body did not contain "${assertion.expected}"';
        }
        return null;
      case AssertionType.notContains:
        if (response.body.contains(assertion.expected)) {
          return 'Assertion "${assertion.name}" failed: response body unexpectedly contained "${assertion.expected}"';
        }
        return null;
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
