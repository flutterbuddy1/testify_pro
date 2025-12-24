import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/test_run.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/map_utils.dart';

class TestRunRepository {
  static const String _boxName = AppConstants.testRunsBoxName;
  Box<Map>? _box;
  final Completer<void> _initCompleter = Completer<void>();

  TestRunRepository();

  Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<Map>(_boxName);
      } else {
        _box = Hive.box<Map>(_boxName);
      }
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    } catch (e) {
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
    }
  }

  Future<void> _ensureInitialized() async {
    await _initCompleter.future;
  }

  /// Save a test run to storage
  Future<void> saveTestRun(TestRun testRun) async {
    await _ensureInitialized();
    await _box?.put(testRun.id, testRun.toJson());
  }

  /// Get all test runs
  Future<List<TestRun>> getAllTestRuns() async {
    await _ensureInitialized();
    if (_box == null) return [];

    return _box!.values
        .map((json) => TestRun.fromJson(MapUtils.ensureStringKeys(json)))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  /// Watch test runs for real-time updates
  Stream<List<TestRun>> watchTestRuns() async* {
    await _ensureInitialized();
    if (_box == null) {
      yield [];
      return;
    }
    yield await getAllTestRuns();
    yield* _box!.watch().asyncMap((_) => getAllTestRuns());
  }

  /// Get test runs by type
  Future<List<TestRun>> getTestRunsByType(TestType type) async {
    final all = await getAllTestRuns();
    return all.where((run) => run.type == type).toList();
  }

  /// Get a specific test run
  Future<TestRun?> getTestRun(String id) async {
    await _ensureInitialized();
    final json = _box?.get(id);
    if (json == null) return null;
    return TestRun.fromJson(MapUtils.ensureStringKeys(json));
  }

  /// Delete a test run
  Future<void> deleteTestRun(String id) async {
    await _ensureInitialized();
    await _box?.delete(id);
  }

  /// Clear all test runs
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _box?.clear();
  }

  /// Get recent test runs (last N)
  Future<List<TestRun>> getRecentTestRuns({int limit = 10}) async {
    final all = await getAllTestRuns();
    return all.take(limit).toList();
  }

  /// Get test run statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final all = await getAllTestRuns();

    return {
      'total': all.length,
      'load_tests': all.where((r) => r.type == TestType.load).length,
      'flow_tests': all.where((r) => r.type == TestType.flow).length,
      'api_tests': all.where((r) => r.type == TestType.api).length,
      'successful': all.where((r) => r.status == TestStatus.completed).length,
      'failed': all.where((r) => r.status == TestStatus.failed).length,
    };
  }

  void dispose() {
    _box?.close();
  }
}
