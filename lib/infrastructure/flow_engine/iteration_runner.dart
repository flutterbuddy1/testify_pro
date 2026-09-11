import '../../domain/entities/flow.dart' as entities;
import '../../domain/entities/flow_execution_result.dart';
import 'flow_executor.dart';

/// Execution outcome of a single iteration over a row of data
class IterationResult {
  final int iterationNumber;
  final Map<String, dynamic> rowData;
  final FlowExecutionResult flowResult;
  final bool success;
  final int durationMs;
  final String? errorMessage;

  const IterationResult({
    required this.iterationNumber,
    required this.rowData,
    required this.flowResult,
    required this.success,
    required this.durationMs,
    this.errorMessage,
  });
}

/// Overall summary report for a complete data-driven test run
class IterationRunSummary {
  final String flowName;
  final int totalIterations;
  final int passedIterations;
  final int failedIterations;
  final int totalRequestsExecuted;
  final int totalDurationMs;
  final double averageIterationDurationMs;
  final List<IterationResult> iterationResults;

  const IterationRunSummary({
    required this.flowName,
    required this.totalIterations,
    required this.passedIterations,
    required this.failedIterations,
    required this.totalRequestsExecuted,
    required this.totalDurationMs,
    required this.averageIterationDurationMs,
    required this.iterationResults,
  });

  bool get allPassed => failedIterations == 0;
  double get passPercentage =>
      totalIterations > 0 ? (passedIterations / totalIterations) * 100 : 0.0;
}

/// Runner that executes a Flow repeatedly over rows of a CSV/JSON dataset (Newman-style).
class IterationRunner {
  final FlowExecutor _flowExecutor;

  IterationRunner(this._flowExecutor);

  /// Executes the given [flow] across each row of [iterationData].
  Future<IterationRunSummary> runWithData({
    required entities.Flow flow,
    required List<Map<String, dynamic>> iterationData,
    int? maxIterations,
    int delayBetweenIterationsMs = 0,
    bool stopOnFailure = false,
    Function(IterationResult)? onIterationComplete,
  }) async {
    final startTime = DateTime.now();
    final results = <IterationResult>[];
    final rowsToRun = (maxIterations != null && maxIterations < iterationData.length)
        ? iterationData.sublist(0, maxIterations)
        : iterationData;

    int passedCount = 0;
    int failedCount = 0;
    int totalRequests = 0;

    for (int i = 0; i < rowsToRun.length; i++) {
      final row = rowsToRun[i];
      final iterNumber = i + 1;
      final iterStartTime = DateTime.now();

      // Merge base flow variables with row values (row values take precedence)
      final mergedVars = Map<String, String>.from(flow.variables);
      row.forEach((k, v) {
        mergedVars[k] = v?.toString() ?? '';
      });

      final iterationFlow = flow.copyWith(variables: mergedVars);

      final flowResult = await _flowExecutor.executeWithTracking(iterationFlow);
      final iterEndTime = DateTime.now();
      final iterDuration = iterEndTime.difference(iterStartTime).inMilliseconds;

      totalRequests += flowResult.stepResults.length;
      final isSuccess = flowResult.success;

      if (isSuccess) {
        passedCount++;
      } else {
        failedCount++;
      }

      final iterResult = IterationResult(
        iterationNumber: iterNumber,
        rowData: row,
        flowResult: flowResult,
        success: isSuccess,
        durationMs: iterDuration,
        errorMessage: flowResult.errorMessage,
      );

      results.add(iterResult);
      onIterationComplete?.call(iterResult);

      if (stopOnFailure && !isSuccess) {
        break;
      }

      if (delayBetweenIterationsMs > 0 && i < rowsToRun.length - 1) {
        await Future.delayed(Duration(milliseconds: delayBetweenIterationsMs));
      }
    }

    final totalDuration = DateTime.now().difference(startTime).inMilliseconds;
    final avgDuration = results.isNotEmpty ? totalDuration / results.length : 0.0;

    return IterationRunSummary(
      flowName: flow.name,
      totalIterations: results.length,
      passedIterations: passedCount,
      failedIterations: failedCount,
      totalRequestsExecuted: totalRequests,
      totalDurationMs: totalDuration,
      averageIterationDurationMs: avgDuration,
      iterationResults: results,
    );
  }
}
