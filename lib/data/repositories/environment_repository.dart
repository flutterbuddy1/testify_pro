import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/environment.dart';
import '../../core/utils/map_utils.dart';

class EnvironmentRepository {
  static const String _boxName = 'environments';
  Box<Map>? _box;
  final Completer<void> _initCompleter = Completer<void>();

  EnvironmentRepository();

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

  Future<void> saveEnvironment(Environment env) async {
    await _ensureInitialized();
    await _box?.put(env.id, env.toJson());
  }

  Future<List<Environment>> getAllEnvironments() async {
    await _ensureInitialized();
    if (_box == null) return [];
    return _box!.values
        .map((json) => Environment.fromJson(MapUtils.ensureStringKeys(json)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Stream<List<Environment>> watchEnvironments() async* {
    await _ensureInitialized();
    if (_box == null) {
      yield [];
      return;
    }
    yield await getAllEnvironments();
    yield* _box!.watch().asyncMap((_) => getAllEnvironments());
  }

  Future<void> deleteEnvironment(String id) async {
    await _ensureInitialized();
    await _box?.delete(id);
  }

  Future<void> setActive(String id) async {
    await _ensureInitialized();
    if (_box == null) return;

    // Deactivate all others
    for (var key in _box!.keys) {
      final json = _box!.get(key);
      if (json != null) {
        final env = Environment.fromJson(MapUtils.ensureStringKeys(json));
        if (env.isActive || env.id == id) {
          final updated = env.copyWith(
            isActive: env.id == id,
            updatedAt: DateTime.now(),
          );
          await _box!.put(env.id, updated.toJson());
        }
      }
    }
  }

  Future<Environment?> getActive() async {
    await _ensureInitialized();
    if (_box == null) return null;
    try {
      final activeJson = _box!.values
          .where((json) => json['isActive'] == true)
          .firstOrNull;
      if (activeJson == null) return null;
      return Environment.fromJson(MapUtils.ensureStringKeys(activeJson));
    } catch (_) {
      return null;
    }
  }
}
