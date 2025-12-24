// Load Coordinator - Brain of the Load Testing Engine
//
// RESPONSIBILITIES:
// 1. Spawns and manages a pool of worker isolates
// 2. Distributes virtual user simulation across workers
// 3. Implements ramp-up/ramp-down scheduling
// 4. Aggregates metrics from all workers in real-time
// 5. Provides stream of metrics to UI
// 6. Handles graceful shutdown of all workers

import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

import '../../data/repositories/test_run_repository.dart';
import '../../domain/entities/test_run.dart';
import '../../domain/entities/api_request.dart';
import '../../domain/entities/api_response.dart';
import '../../domain/entities/load_test_config.dart';
import '../../domain/entities/flow.dart';
import '../../domain/entities/test_metrics.dart';
import 'worker_isolate.dart';
import 'metrics_aggregator.dart';

class LoadCoordinator with ChangeNotifier {
  // Worker pool
  final List<_WorkerInfo> _workers = [];

  // Metrics aggregator
  final MetricsAggregator _metricsAggregator = MetricsAggregator();

  // Control
  bool _isRunning = false;
  Timer? _metricsTimer;
  Timer? _rampTimer;

  // Configuration
  late LoadTestConfig _config;
  ApiRequest? _request;
  Flow? _flow;

  // Metrics stream controller
  StreamController<TestMetrics> _metricsController =
      StreamController<TestMetrics>.broadcast();

  // Persistence
  TestRunRepository? _repository;
  String? _currentTestRunId;

  /// Stream of real-time metrics (emits every 1 second)
  Stream<TestMetrics> get metricsStream => _metricsController.stream;

  /// Is the load test currently running
  bool get isRunning => _isRunning;

  /// Get current aggregated metrics snapshot
  TestMetrics get currentMetrics => _metricsAggregator.getCurrentMetrics();

  /// Get recent response samples for UI logs
  List<ApiResponse> get recentResponses => _metricsAggregator.recentResponses;

  /// Start load test
  Future<void> start(
    LoadTestConfig config, {
    ApiRequest? request,
    Flow? flow,
    String? testRunId,
    TestRunRepository? repository,
  }) async {
    if (_isRunning) {
      throw StateError('Load test is already running');
    }

    if (request == null && flow == null) {
      throw ArgumentError('Either request or flow must be provided');
    }

    _config = config;
    _request = request;
    _flow = flow;
    _currentTestRunId = testRunId;
    _repository = repository;
    _isRunning = true;
    _metricsAggregator.reset();

    // Re-initialize metrics controller for new run
    _metricsController = StreamController<TestMetrics>.broadcast();
    notifyListeners();

    try {
      // Calculate worker pool size
      final workerCount = config.recommendedWorkers;

      print('🚀 Starting load test: ${config.name}');

      // Spawn worker pool
      await _spawnWorkerPool(workerCount);

      // Start metrics aggregation timer (1 second intervals)
      _startMetricsAggregation();

      // Implement ramp-up strategy
      if (config.rampUpSeconds > 0) {
        await _executeRampUp();
      }

      // Start sustained load (Steady State)
      if (_isRunning) {
        print(
          '🚀 Starting steady state load for ${config.durationSeconds}s...',
        );
        await _startAllUsers();
      }

      // Schedule test duration timeout (Duration + Ramp-up)
      final totalDurationSeconds =
          config.durationSeconds + config.rampUpSeconds;
      Future.delayed(Duration(seconds: totalDurationSeconds), () {
        if (_isRunning) {
          stop();
        }
      });
    } catch (e) {
      _isRunning = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Stop load test gracefully
  Future<void> stop() async {
    if (!_isRunning) return;

    print('⏹️  Stopping load test...');
    _isRunning = false;
    notifyListeners();

    // Stop metrics timer
    _metricsTimer?.cancel();
    _rampTimer?.cancel();

    // Send stop message to all workers
    for (final worker in _workers) {
      worker.sendPort?.send(WorkerMessage(WorkerMessageType.stop, null));
    }

    // Wait a bit for workers to clean up
    await Future.delayed(const Duration(milliseconds: 500));

    // Kill isolates
    for (final worker in _workers) {
      worker.isolate.kill(priority: Isolate.immediate);
    }

    _workers.clear();

    // Send final metrics
    final finalMetrics = _metricsAggregator.getCurrentMetrics();
    _metricsController.add(finalMetrics);

    // Persist final results if we have the necessary info
    if (_repository != null && _currentTestRunId != null) {
      try {
        final currentRun = await _repository!.getTestRun(_currentTestRunId!);
        if (currentRun != null && currentRun.status == TestStatus.running) {
          final updatedRun = currentRun.copyWith(
            status: TestStatus.completed,
            endTime: DateTime.now(),
            finalMetrics: finalMetrics,
            metadata: {
              ...currentRun.metadata,
              'logs': recentResponses.map((r) => r.toJson()).toList(),
            },
          );
          await _repository!.saveTestRun(updatedRun);
          print('💾 Final results persisted for $_currentTestRunId');
        }
      } catch (e) {
        print('⚠️ Failed to persist final results: $e');
      }
    }

    await _metricsController.close();
    print('✅ Load test stopped');
  }

  /// Spawn worker isolate pool
  Future<void> _spawnWorkerPool(int count) async {
    for (int i = 0; i < count; i++) {
      final receivePort = ReceivePort();

      // Spawn worker isolate
      final isolate = await Isolate.spawn(
        workerIsolateEntryPoint,
        receivePort.sendPort,
        debugName: 'Worker-$i',
      );

      // Wait for worker to send back its SendPort
      final Completer<SendPort> completer = Completer<SendPort>();

      receivePort.listen((message) {
        if (message is SendPort && !completer.isCompleted) {
          completer.complete(message);
        } else if (message is WorkerMessage) {
          _handleWorkerMessage(message);
        }
      });

      final sendPort = await completer.future;

      _workers.add(
        _WorkerInfo(
          id: 'worker-$i',
          isolate: isolate,
          receivePort: receivePort,
          sendPort: sendPort,
        ),
      );
    }

    print('✅ Spawned ${_workers.length} worker isolates');
  }

  /// Start all virtual users immediately (no ramp-up)
  Future<void> _startAllUsers() async {
    final usersPerWorker = _config.usersPerWorker(_workers.length);

    for (final worker in _workers) {
      final package = WorkPackage(
        workerId: worker.id,
        request: _request,
        flow: _flow,
        iterations:
            usersPerWorker *
            (_config.durationSeconds ~/ (_config.thinkTimeMs / 1000)).ceil(),
        concurrency: usersPerWorker,
        delayMs: _config.thinkTimeMs,
      );

      worker.sendPort?.send(
        WorkerMessage(WorkerMessageType.startWork, package),
      );
    }
  }

  /// Execute ramp-up strategy
  Future<void> _executeRampUp() async {
    final totalUsers = _config.virtualUsers;
    final rampUpSeconds = _config.rampUpSeconds;
    final steps = 10;
    final usersPerStep = totalUsers ~/ steps;
    final intervalMs = (rampUpSeconds * 1000) ~/ steps;

    final iterationsPerUser = (intervalMs / _config.thinkTimeMs).ceil();

    print('📈 Ramping up $totalUsers users over ${rampUpSeconds}s...');

    for (int step = 1; step <= steps; step++) {
      if (!_isRunning) break;

      final activeUsers = usersPerStep * step;
      final usersPerWorker = activeUsers ~/ _workers.length;

      _metricsAggregator.setActiveUsers(activeUsers);

      for (final worker in _workers) {
        final package = WorkPackage(
          workerId: worker.id,
          request: _request,
          flow: _flow,
          iterations: usersPerWorker * iterationsPerUser,
          concurrency: usersPerWorker,
          delayMs: _config.thinkTimeMs,
        );

        worker.sendPort?.send(
          WorkerMessage(WorkerMessageType.startWork, package),
        );
      }

      print('   Step $step: $activeUsers users active');

      if (step < steps) {
        await Future.delayed(Duration(milliseconds: intervalMs));
      }
    }

    print('✅ Ramp-up complete');
  }

  /// Handle messages from worker isolates
  void _handleWorkerMessage(WorkerMessage message) {
    switch (message.type) {
      case WorkerMessageType.result:
        final response = message.data as ApiResponse;
        _metricsAggregator.addResult(response);
        break;

      case WorkerMessageType.error:
        print('❌ Worker error: ${message.data}');
        break;

      default:
        break;
    }
  }

  /// Start metrics aggregation timer
  void _startMetricsAggregation() {
    // Emit initial metrics immediately
    final initialMetrics = _metricsAggregator.getCurrentMetrics();
    _metricsController.add(initialMetrics);

    _metricsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      final metrics = _metricsAggregator.getCurrentMetrics();
      _metricsController.add(metrics);
    });
  }

  @override
  void dispose() {
    stop();
    _metricsController.close();
    super.dispose();
  }
}

/// Internal worker info
class _WorkerInfo {
  final String id;
  final Isolate isolate;
  final ReceivePort receivePort;
  final SendPort? sendPort;

  _WorkerInfo({
    required this.id,
    required this.isolate,
    required this.receivePort,
    this.sendPort,
  });
}
