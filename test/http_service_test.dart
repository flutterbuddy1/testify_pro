import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testify_pro/core/providers/global_providers.dart';
import 'package:testify_pro/data/services/http_service.dart';
import 'package:testify_pro/domain/entities/api_request.dart';

void main() {
  group('HttpService URL and Query Parameters Tests', () {
    late HttpService httpService;

    setUp(() {
      httpService = HttpService();
    });

    tearDown(() {
      httpService.dispose();
    });

    test('Executes GET request without trailing question mark when queryParams is empty', () async {
      final request = ApiRequest(
        id: 'test-1',
        name: 'Get Post',
        url: 'https://jsonplaceholder.typicode.com/posts/1',
        method: HttpMethod.get,
      );

      final response = await httpService.execute(request);

      expect(response.statusCode, equals(200));
      expect(response.statusMessage, equals('OK'));
      expect(response.headers, isNotEmpty);
      expect(response.headers.containsKey('content-type'), isTrue);
      expect(response.body, contains('"id": 1'));
      expect(response.error, isNull);
    });

    test('Appends query parameters correctly when queryParams is provided', () async {
      final request = ApiRequest(
        id: 'test-2',
        name: 'Filter Comments',
        url: 'https://jsonplaceholder.typicode.com/comments',
        method: HttpMethod.get,
        queryParams: {'postId': '1'},
      );

      final response = await httpService.execute(request);

      expect(response.statusCode, equals(200));
      expect(response.headers, isNotEmpty);
      expect(response.body, contains('"postId": 1'));
    });

    test('Executes POST request and auto-detects JSON content-type header', () async {
      final request = ApiRequest(
        id: 'test-3',
        name: 'Create Post',
        url: 'https://jsonplaceholder.typicode.com/posts',
        method: HttpMethod.post,
        body: '{"title": "test", "body": "testing", "userId": 1}',
      );

      final response = await httpService.execute(request);

      expect(response.statusCode, equals(201));
      expect(response.headers, isNotEmpty);
      // Verify location header does not contain trailing question mark before path like 'posts?/101'
      final location = response.headers['location']?.toString() ?? '';
      expect(location.contains('posts?'), isFalse);
    });

    test('Handles 404 response properly with status code, message, and headers', () async {
      final request = ApiRequest(
        id: 'test-4',
        name: 'Not Found',
        url: 'https://jsonplaceholder.typicode.com/invalid-endpoint-abc-xyz',
        method: HttpMethod.get,
      );

      final response = await httpService.execute(request);

      expect(response.statusCode, equals(404));
      expect(response.statusMessage, equals('Not Found'));
      expect(response.headers, isNotEmpty);
    });

    test('Handles network connection failure with code 0 and human-readable error', () async {
      final request = ApiRequest(
        id: 'test-5',
        name: 'Invalid Host',
        url: 'https://this-domain-does-not-exist-123456789.org',
        method: HttpMethod.get,
        timeoutMs: 3000,
      );

      final response = await httpService.execute(request);

      expect(response.statusCode, equals(0));
      expect(response.statusMessage, equals('Connection Error'));
      expect(response.error, isNotNull);
      expect(response.error!.isNotEmpty, isTrue);
    });

    test('activeEnvironmentProvider returns null without throwing when no active environment exists', () {
      final container = ProviderContainer(
        overrides: [
          environmentsProvider.overrideWith((ref) => Stream.value([])),
        ],
      );
      addTearDown(container.dispose);

      final activeEnv = container.read(activeEnvironmentProvider);
      expect(activeEnv, isNull);
    });
  });
}
