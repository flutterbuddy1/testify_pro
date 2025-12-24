import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/api_request.dart';
import '../../core/utils/map_utils.dart';

class ApiHistoryRepository {
  static const String _boxName = 'api_history';
  Box<Map>? _box;
  final Completer<void> _initCompleter = Completer<void>();

  ApiHistoryRepository();

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

  Future<void> saveRequest(ApiRequest request) async {
    await _ensureInitialized();
    final data = request.toJson();
    data['lastUsed'] = DateTime.now().toIso8601String();
    await _box?.put(request.id, data);

    // Maintain limit of 50 recent requests
    if ((_box?.length ?? 0) > 50) {
      final keys = _box!.keys.toList();
      await _box!.delete(keys.first);
    }
  }

  Future<List<ApiRequest>> getHistory() async {
    await _ensureInitialized();
    if (_box == null) return [];

    final requests = _box!.values
        .map((json) => ApiRequest.fromJson(MapUtils.ensureStringKeys(json)))
        .toList();

    return requests.reversed.toList();
  }

  Future<void> deleteRequest(String id) async {
    await _ensureInitialized();
    await _box?.delete(id);
  }

  Future<void> clearAll() async {
    await _ensureInitialized();
    await _box?.clear();
  }
}
