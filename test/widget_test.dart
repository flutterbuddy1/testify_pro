import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testify_pro/core/providers/global_providers.dart';
import 'package:testify_pro/data/repositories/api_history_repository.dart';
import 'package:testify_pro/domain/entities/api_request.dart';
import 'package:testify_pro/presentation/screens/api_test_screen.dart';

class FakeApiHistoryRepository extends ApiHistoryRepository {
  final List<ApiRequest> _items = [];

  @override
  Future<void> init() async {}

  @override
  Future<List<ApiRequest>> getHistory() async => _items;

  @override
  Future<void> saveRequest(ApiRequest request) async => _items.add(request);

  @override
  Future<void> clearAll() async => _items.clear();
}

void main() {
  testWidgets('ApiTestScreen renders URL bar and Send button', (WidgetTester tester) async {
    final fakeRepo = FakeApiHistoryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiHistoryRepositoryProvider.overrideWithValue(fakeRepo),
          activeEnvironmentProvider.overrideWithValue(null),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ApiTestScreen(),
          ),
        ),
      ),
    );

    // Initial pump and settle
    await tester.pumpAndSettle();

    // Verify presence of URL field, method selector, and Send button
    expect(find.text('GET'), findsOneWidget);
    expect(find.text('Send'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Hit Send to see the response'), findsOneWidget);
  });
}
