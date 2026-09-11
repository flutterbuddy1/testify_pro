import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/test_run_repository.dart';
import '../../data/repositories/api_history_repository.dart';
import '../../data/services/http_service.dart';
import '../../infrastructure/load_engine/load_coordinator.dart';
import '../../data/repositories/flow_repository.dart';
import '../../data/repositories/saved_request_repository.dart';
import '../../data/repositories/environment_repository.dart';
import '../../domain/entities/environment.dart';
import '../../domain/entities/flow.dart' as entities;
import '../../infrastructure/flow_engine/flow_executor.dart';

/// Flow Executor Provider
final flowExecutorProvider = Provider<FlowExecutor>((ref) {
  final repo = ref.watch(testRunRepositoryProvider);
  return FlowExecutor(HttpService(), repository: repo);
});

/// Test Run Repository Provider (Singleton)
final testRunRepositoryProvider = Provider<TestRunRepository>((ref) {
  final repo = TestRunRepository();
  repo.init();
  return repo;
});

/// API History Repository Provider
final apiHistoryRepositoryProvider = Provider<ApiHistoryRepository>((ref) {
  final repo = ApiHistoryRepository();
  repo.init();
  return repo;
});

final savedRequestRepositoryProvider = Provider<SavedRequestRepository>((ref) {
  final repo = SavedRequestRepository();
  repo.init();
  return repo;
});

/// Flow Repository Provider
final flowRepositoryProvider = Provider<FlowRepository>((ref) {
  final repo = FlowRepository();
  repo.init();
  return repo;
});

final environmentRepositoryProvider = Provider<EnvironmentRepository>((ref) {
  final repo = EnvironmentRepository();
  repo.init();
  return repo;
});

/// Flows Provider (Watching persistent storage)
final flowsProvider = StreamProvider<List<entities.Flow>>((ref) {
  final repo = ref.watch(flowRepositoryProvider);
  return repo.watchFlows();
});

/// Environments Provider
final environmentsProvider = StreamProvider<List<Environment>>((ref) {
  final repo = ref.watch(environmentRepositoryProvider);
  return repo.watchEnvironments();
});

final activeEnvironmentProvider = Provider<Environment?>((ref) {
  return ref
      .watch(environmentsProvider)
      .whenOrNull(
        data: (envs) => envs.where((e) => e.isActive).firstOrNull,
      );
});

/// HTTP Service Provider
final httpServiceProvider = Provider<HttpService>((ref) {
  return HttpService();
});

/// Load Coordinator Provider (Singleton for persistence across navigation)
final loadCoordinatorProvider = ChangeNotifierProvider<LoadCoordinator>((ref) {
  return LoadCoordinator();
});
