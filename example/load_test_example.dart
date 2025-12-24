// Example Usage - Load Testing Demo
// This file demonstrates how to use the LoadCoordinator API

import 'package:testify_pro/domain/entities/api_request.dart';
import 'package:testify_pro/domain/entities/load_test_config.dart';
import 'package:testify_pro/domain/entities/test_metrics.dart';
import 'package:testify_pro/infrastructure/load_engine/load_coordinator.dart';
import 'package:uuid/uuid.dart';

void main() async {
  print('=== Testify Pro - Load Testing Example ===\n');

  // Create a simple GET request to test
  final request = ApiRequest(
    id: const Uuid().v4(),
    name: 'Example API Test',
    url: 'https://jsonplaceholder.typicode.com/posts/1',
    method: HttpMethod.get,
  );

  // Configure load test
  final config = LoadTestConfig(
    id: const Uuid().v4(),
    name: 'Example Load Test',
    targetId: request.id,
    targetType: TargetType.request,
    virtualUsers: 50, // Simulate 50 concurrent users
    durationSeconds: 10, // Run for 10 seconds
    rampUpSeconds: 2, // Ramp up over 2 seconds
    createdAt: DateTime.now(),
  );

  print('Configuration:');
  print('  - Virtual Users: ${config.virtualUsers}');
  print('  - Duration: ${config.durationSeconds}s');
  print('  - Ramp-up: ${config.rampUpSeconds}s');
  print('  - Target: ${request.url}\n');

  // Create coordinator
  final coordinator = LoadCoordinator();

  // Listen to metrics
  coordinator.metricsStream.listen((metrics) {
    print('📊 Metrics Update:');
    print('   Total Requests: ${metrics.totalRequests}');
    print('   Success Rate: ${metrics.successRate}');
    print('   Current RPS: ${metrics.currentRps.toStringAsFixed(1)}');
    print(
      '   Avg Response Time: ${metrics.avgResponseTimeMs.toStringAsFixed(0)}ms',
    );
    print(
      '   P95 Response Time: ${metrics.p95ResponseTimeMs.toStringAsFixed(0)}ms\n',
    );
  });

  // Start load test
  print('🚀 Starting load test...\n');
  await coordinator.start(config, request: request);

  // Wait for test to complete
  await Future.delayed(Duration(seconds: config.durationSeconds + 5));

  // Stop coordinator
  await coordinator.stop();
  coordinator.dispose();

  print('\n✅ Example complete!');
}
