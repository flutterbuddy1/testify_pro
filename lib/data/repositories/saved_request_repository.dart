import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/api_request.dart';
import '../../core/utils/map_utils.dart';

class SavedRequestRepository {
  static const String _boxName = 'saved_requests';
  Box<Map>? _box;
  final Completer<void> _initCompleter = Completer<void>();

  SavedRequestRepository();

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
    await _box?.put(request.id, request.toJson());
  }

  Future<List<ApiRequest>> getAllRequests() async {
    await _ensureInitialized();
    if (_box == null) return [];
    return _box!.values
        .map((json) => ApiRequest.fromJson(MapUtils.ensureStringKeys(json)))
        .toList();
  }

  Stream<List<ApiRequest>> watchRequests() async* {
    await _ensureInitialized();
    if (_box == null) {
      yield [];
      return;
    }
    yield await getAllRequests();
    yield* _box!.watch().asyncMap((_) => getAllRequests());
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
