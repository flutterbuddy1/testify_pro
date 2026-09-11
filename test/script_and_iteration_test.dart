import 'package:flutter_test/flutter_test.dart';
import 'package:testify_pro/core/utils/csv_parser.dart';
import 'package:testify_pro/infrastructure/flow_engine/script_engine.dart';
import 'package:testify_pro/infrastructure/flow_engine/iteration_runner.dart';
import 'package:testify_pro/infrastructure/flow_engine/flow_executor.dart';
import 'package:testify_pro/data/services/http_service.dart';
import 'package:testify_pro/domain/entities/flow.dart' as entities;
import 'package:testify_pro/domain/entities/flow_step.dart';
import 'package:testify_pro/domain/entities/api_request.dart';
import 'package:testify_pro/domain/entities/api_response.dart';

void main() {
  group('CsvParser Tests', () {
    test('Parses standard CSV with headers and values', () {
      const csv = '''Name,Age,Active
Alice,30,true
Bob,25,false''';

      final rows = CsvParser.parse(csv);
      expect(rows.length, equals(2));
      expect(rows[0]['Name'], equals('Alice'));
      expect(rows[0]['Age'], equals(30));
      expect(rows[0]['Active'], isTrue);
      expect(rows[1]['Name'], equals('Bob'));
      expect(rows[1]['Age'], equals(25));
      expect(rows[1]['Active'], isFalse);
    });

    test('Handles quoted fields with commas and escaped quotes', () {
      const csv = '''"Product, Name",Price,"Description"
"Super, Widget",99.99,"A ""great"" product"''';

      final rows = CsvParser.parse(csv);
      expect(rows.length, equals(1));
      expect(rows[0]['Product, Name'], equals('Super, Widget'));
      expect(rows[0]['Price'], equals(99.99));
      expect(rows[0]['Description'], equals('A "great" product'));
    });

    test('Parses JSON array of objects automatically', () {
      const jsonArr = '''[
        {"id": 101, "role": "admin"},
        {"id": 102, "role": "user"}
      ]''';

      final rows = CsvParser.parseAuto(jsonArr);
      expect(rows.length, equals(2));
      expect(rows[0]['id'], equals(101));
      expect(rows[0]['role'], equals('admin'));
    });
  });

  group('ScriptEngine Tests', () {
    test('Pre-request script calculates DOB and extracts iterationData', () {
      const script = '''
      let age = 25;
      let DOB = calculateDOB(age);
      pm.globals.set("DOB", DOB);
      const sumInsured = pm.iterationData.get("Sum Insured");
      pm.globals.set("familyComp", pm.iterationData.get("Family Composition"));
      ''';

      final variables = <String, dynamic>{};
      final iterationData = <String, dynamic>{
        'Sum Insured': 500000,
        'Family Composition': '1A+2C',
      };

      final result = ScriptEngine.executePreRequest(
        script: script,
        variables: variables,
        iterationData: iterationData,
      );

      expect(result.success, isTrue);
      expect(result.modifiedVariables['DOB'], isNotEmpty);
      expect(result.modifiedVariables['Sum Insured'], equals('500000'));
      expect(result.modifiedVariables['Family Composition'], equals('1A+2C'));
    });

    test('Pre-request script generates dynamic member payload from family composition', () {
      const script = '''
      function createMembers(familyComp) { ... }
      pm.globals.set("membersPayload", JSON.stringify(membersArray, null, 2));
      ''';

      final variables = <String, dynamic>{
        'familyComp': '2A+1C',
        'sumInsured': '750000',
        'DOB': '1995-05-15',
      };

      final result = ScriptEngine.executePreRequest(
        script: script,
        variables: variables,
      );

      expect(result.success, isTrue);
      final payload = result.modifiedVariables['membersPayload'] as String;
      expect(payload, isNotEmpty);
      expect(payload, contains('"relationship": "SELF"'));
      expect(payload, contains('"relationship": "SPOUSE"'));
      expect(payload, contains('"relationship": "SON"'));
      expect(payload, contains('750000'));
    });

    test('Test script evaluates status code and value assertions', () {
      const script = '''
      const response = pm.response.json();
      const actualValue = response.data.total_net_premium;
      pm.globals.set("actualValue", actualValue);
      if (pm.response.code !== 200) { pm.expect.fail(); }
      pm.expect(Number(actualValue)).to.eql(Number(expectedValue));
      ''';

      final variables = <String, dynamic>{};
      final iterationData = <String, dynamic>{
        '20Yrs': 4214,
      };

      const responseBody = '{"data": {"total_net_premium": 4214}}';
      final response = ApiResponse(
        statusCode: 200,
        statusMessage: 'OK',
        headers: {'content-type': 'application/json'},
        body: responseBody,
        responseTimeMs: 120,
        sizeBytes: responseBody.length,
        timestamp: DateTime.now(),
      );

      final result = ScriptEngine.executeTest(
        script: script,
        variables: variables,
        response: response,
        iterationData: iterationData,
      );

      expect(result.success, isTrue);
      expect(result.passedTests.length, greaterThanOrEqualTo(1));
      expect(result.modifiedVariables['actualValue'], equals(4214));
    });

    test('Test script reports mismatch when premium differs', () {
      const script = '''
      const response = pm.response.json();
      const actualValue = response.data.total_net_premium;
      pm.globals.set("actualValue", actualValue);
      pm.expect(Number(actualValue)).to.eql(Number(expectedValue));
      ''';

      final variables = <String, dynamic>{};
      final iterationData = <String, dynamic>{
        'expected': 9999, // Mismatched
      };

      const responseBody = '{"data": {"total_net_premium": 4214}}';
      final response = ApiResponse(
        statusCode: 200,
        statusMessage: 'OK',
        headers: {'content-type': 'application/json'},
        body: responseBody,
        responseTimeMs: 100,
        sizeBytes: responseBody.length,
        timestamp: DateTime.now(),
      );

      final result = ScriptEngine.executeTest(
        script: script,
        variables: variables,
        response: response,
        iterationData: iterationData,
      );

      expect(result.success, isFalse);
      expect(result.failedTests, isNotEmpty);
      expect(result.failedTests.first, contains('Actual (4214) != Expected (9999)'));
    });
  });

  group('IterationRunner Integration Tests', () {
    test('Runs multiple iterations merging row data into flow variables', () async {
      final flow = entities.Flow(
        id: 'iter-flow-1',
        name: 'Data Iteration Test',
        variables: {'baseToken': 'secret123'},
        tags: [],
        steps: [
          FlowStep(
            id: 'step-1',
            name: 'Echo Step',
            request: const ApiRequest(
              id: 'req-1',
              name: 'Echo',
              url: 'https://jsonplaceholder.typicode.com/posts/{{postId}}',
              method: HttpMethod.get,
            ),
            assertions: [
              const Assertion(
                name: 'Status 200',
                type: AssertionType.statusCode,
                expected: '200',
              ),
            ],
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final dataset = [
        {'postId': 1},
        {'postId': 2},
      ];

      final httpService = HttpService();
      final executor = FlowExecutor(httpService);
      final runner = IterationRunner(executor);

      final summary = await runner.runWithData(
        flow: flow,
        iterationData: dataset,
      );

      expect(summary.totalIterations, equals(2));
      expect(summary.passedIterations, equals(2));
      expect(summary.failedIterations, equals(0));
      expect(summary.allPassed, isTrue);
      expect(summary.iterationResults[0].rowData['postId'], equals(1));
      expect(summary.iterationResults[1].rowData['postId'], equals(2));
    });
  });
}
