import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:testify_pro/core/utils/flow_json_parser.dart';
import 'package:testify_pro/domain/entities/api_request.dart';
import 'package:testify_pro/domain/entities/flow_step.dart';

void main() {
  group('FlowJsonParser Tests', () {
    test('Validates and rejects malformed JSON', () {
      final resEmpty = FlowJsonParser.validateJson('');
      expect(resEmpty.isValid, isFalse);
      expect(resEmpty.errors.first, contains('empty'));

      final resMalformed = FlowJsonParser.validateJson('{not a valid json}');
      expect(resMalformed.isValid, isFalse);
      expect(resMalformed.errors.first, contains('syntax'));
    });

    test('Validates required fields: name and steps', () {
      final resNoName = FlowJsonParser.validateJson('{"steps": []}');
      expect(resNoName.isValid, isFalse);
      expect(resNoName.errors, anyElement(contains('name')));

      final resNoSteps = FlowJsonParser.validateJson('{"name": "Test Flow"}');
      expect(resNoSteps.isValid, isFalse);
      expect(resNoSteps.errors, anyElement(contains('steps')));
    });

    test('Parses hand-crafted minimal JSON with smart defaults (no IDs or timestamps needed)', () {
      const minimalJson = '''
      {
        "name": "Minimal Flow",
        "variables": {
          "host": "https://api.example.com"
        },
        "steps": [
          {
            "name": "First Step",
            "request": {
              "url": "{{host}}/users",
              "method": "GET"
            }
          }
        ]
      }
      ''';

      final result = FlowJsonParser.validateJson(minimalJson);
      expect(result.isValid, isTrue);
      expect(result.flow, isNotNull);

      final flow = result.flow!;
      expect(flow.name, equals('Minimal Flow'));
      expect(flow.id, isNotEmpty);
      expect(flow.variables['host'], equals('https://api.example.com'));
      expect(flow.steps.length, equals(1));

      final step = flow.steps.first;
      expect(step.name, equals('First Step'));
      expect(step.id, isNotEmpty);
      expect(step.request.url, equals('{{host}}/users'));
      expect(step.request.method, equals(HttpMethod.get));
      expect(step.enabled, isTrue);
      expect(step.stopOnFailure, isTrue);
    });

    test('Parses native JSON Map body and converts to formatted string', () {
      const jsonWithMapBody = '''
      {
        "name": "Post Flow",
        "steps": [
          {
            "name": "Create Item",
            "request": {
              "url": "https://api.example.com/items",
              "method": "POST",
              "body": {
                "title": "Widget",
                "price": 99.9,
                "inStock": true
              }
            }
          }
        ]
      }
      ''';

      final flow = FlowJsonParser.parseFlow(jsonWithMapBody);
      final body = flow.steps.first.request.body;
      expect(body, isNotNull);
      expect(body, contains('"title": "Widget"'));
      expect(body, contains('"price": 99.9'));
      expect(body, contains('"inStock": true'));
    });

    test('Parses case-insensitive HTTP methods correctly', () {
      const jsonMethods = '''
      {
        "name": "Methods Flow",
        "steps": [
          {"name": "s1", "request": {"url": "http://test.com", "method": "post"}},
          {"name": "s2", "request": {"url": "http://test.com", "method": "DELETE"}},
          {"name": "s3", "request": {"url": "http://test.com", "method": "Patch"}}
        ]
      }
      ''';

      final flow = FlowJsonParser.parseFlow(jsonMethods);
      expect(flow.steps[0].request.method, equals(HttpMethod.post));
      expect(flow.steps[1].request.method, equals(HttpMethod.delete));
      expect(flow.steps[2].request.method, equals(HttpMethod.patch));
    });

    test('Parses multiple assertion types and extractors', () {
      const jsonAssertions = '''
      {
        "name": "Assertions Flow",
        "steps": [
          {
            "name": "Step with Assertions",
            "request": {
              "url": "http://test.com/api"
            },
            "extractors": {
              "token": "\$.auth.token"
            },
            "assertions": [
              {
                "name": "Status 200",
                "type": "statusCode",
                "expected": "200"
              },
              {
                "name": "Fast response",
                "type": "responseTime",
                "expected": "1000"
              },
              {
                "name": "Check user role",
                "type": "jsonPath",
                "actual": "\$.user.role",
                "expected": "admin"
              },
              {
                "name": "Has success key",
                "type": "contains",
                "expected": "success"
              }
            ]
          }
        ]
      }
      ''';

      final flow = FlowJsonParser.parseFlow(jsonAssertions);
      final step = flow.steps.first;
      expect(step.extractors['token'], equals('\$.auth.token'));
      expect(step.assertions.length, equals(4));
      expect(step.assertions[0].type, equals(AssertionType.statusCode));
      expect(step.assertions[1].type, equals(AssertionType.responseTime));
      expect(step.assertions[2].type, equals(AssertionType.jsonPath));
      expect(step.assertions[2].actual, equals('\$.user.role'));
      expect(step.assertions[3].type, equals(AssertionType.contains));
    });

    test('Roundtrip export and re-import preserves structure', () {
      final sampleJson = FlowJsonParser.getSampleFlowJson();
      final flow1 = FlowJsonParser.parseFlow(sampleJson);

      final exported = FlowJsonParser.flowToJson(flow1);
      final flow2 = FlowJsonParser.parseFlow(exported);

      expect(flow2.name, equals(flow1.name));
      expect(flow2.steps.length, equals(flow1.steps.length));
      expect(flow2.variables.length, equals(flow1.variables.length));
      expect(flow2.steps.first.name, equals(flow1.steps.first.name));
      expect(flow2.steps.first.request.method, equals(flow1.steps.first.request.method));
    });

    test('Validates example/sample_flow.json file directly', () {
      final file = File('example/sample_flow.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final result = FlowJsonParser.validateJson(content);
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.flow, isNotNull);
      expect(result.flow!.steps.length, equals(2));
    });

    test('Parses Postman Collection format with nested folders and variables', () {
      const postmanJson = '''
      {
        "info": {
          "_postman_id": "test-id",
          "name": "Rate Chart Automation",
          "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
        },
        "item": [
          {
            "name": "STU Care",
            "item": [
              {
                "name": "P1 Policy",
                "item": [
                  {
                    "name": "Quotation - 20yrs",
                    "request": {
                      "method": "POST",
                      "header": [
                        {"key": "authorization", "value": "Token {{token}}"},
                        {"key": "content-type", "value": "application/json"}
                      ],
                      "body": {
                        "mode": "raw",
                        "raw": "{\\"policyName\\": \\"{{Policy Name}}\\"}"
                      },
                      "url": {
                        "raw": "{{URL}}/group/quotation",
                        "host": ["{{URL}}"],
                        "path": ["group", "quotation"]
                      }
                    },
                    "event": [
                      {
                        "listen": "test",
                        "script": {
                          "exec": [
                            "const response = pm.response.json();",
                            "const actualValue = response.data.total_net_premium;",
                            "pm.globals.set(\\"actualValue\\", actualValue);",
                            "if (pm.response.code !== 200) { pm.expect.fail(); }"
                          ]
                        }
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
      ''';

      final result = FlowJsonParser.validateJson(postmanJson);
      expect(result.isValid, isTrue);
      expect(result.flow, isNotNull);

      final flow = result.flow!;
      expect(flow.name, equals('Rate Chart Automation'));
      expect(flow.steps.length, equals(1));

      final step = flow.steps.first;
      expect(step.name, equals('STU Care / P1 Policy / Quotation - 20yrs'));
      expect(step.request.url, equals('{{URL}}/group/quotation'));
      expect(step.request.method, equals(HttpMethod.post));
      expect(step.request.headers['authorization'], equals('Token {{token}}'));
      expect(step.request.headers['content-type'], equals('application/json'));
      expect(step.request.body, contains('"policyName": "{{Policy Name}}"'));

      // Check extracted variables and assertions from test script
      expect(step.extractors['actualValue'], equals('\$.data.total_net_premium'));
      expect(step.assertions.any((a) => a.type == AssertionType.statusCode && a.expected == '200'), isTrue);

      // Check discovered variables
      expect(flow.variables.containsKey('token'), isTrue);
      expect(flow.variables.containsKey('Policy Name'), isTrue);
      expect(flow.variables.containsKey('URL'), isTrue);
    });

    test('Parses zoppertest/rate_chart_automation_collection.json and generates native flow', () {
      final file = File('zoppertest/rate_chart_automation_collection.json');
      if (!file.existsSync()) return;

      final content = file.readAsStringSync();
      final result = FlowJsonParser.validateJson(content);
      expect(result.isValid, isTrue);
      expect(result.flow, isNotNull);

      final flow = result.flow!;
      expect(flow.name, equals('Rate Chart Automation'));
      expect(flow.steps.length, equals(4));

      // Check step names preserved the folder hierarchy
      expect(flow.steps[0].name, equals('STU Care / P1 Policy / Quotation - 20yrs'));
      expect(flow.steps[1].name, equals('STU Care / P1 Policy / Quotation - 30yrs'));
      expect(flow.steps[2].name, equals('STU Care / P1 Policy / Quotation - 45yrs'));
      expect(flow.steps[3].name, equals('STU Care / P2 Policy / Quotation - 30yrs'));

      // Verify converted flow exports cleanly
      final flowJson = FlowJsonParser.flowToJson(flow);
      File('zoppertest/rate_chart_automation_flow.json').writeAsStringSync(flowJson);
      expect(File('zoppertest/rate_chart_automation_flow.json').existsSync(), isTrue);
    });
  });
}
