import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/flow.dart';
import '../../core/utils/map_utils.dart';

class FlowRepository {
  static const String _boxName = 'flows';
  Box<Map>? _box;
  final Completer<void> _initCompleter = Completer<void>();

  FlowRepository();

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

  /// Save a flow to permanent storage
  Future<void> saveFlow(Flow flow) async {
    await _ensureInitialized();
    await _box?.put(flow.id, flow.toJson());
  }

  /// Get all persisted flows
  Future<List<Flow>> getAllFlows() async {
    await _ensureInitialized();
    if (_box == null) return [];
    return _box!.values
        .map((json) => Flow.fromJson(MapUtils.ensureStringKeys(json)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Watch flows for real-time UI updates
  Stream<List<Flow>> watchFlows() async* {
    await _ensureInitialized();
    if (_box == null) {
      yield [];
      return;
    }
    yield await getAllFlows();
    yield* _box!.watch().asyncMap((_) => getAllFlows());
  }

  /// Delete a flow
  Future<void> deleteFlow(String id) async {
    await _ensureInitialized();
    await _box?.delete(id);
  }

  /// Clear all flows
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _box?.clear();
  }
}
