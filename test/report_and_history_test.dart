import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:testify_pro/domain/entities/test_run.dart';
import 'package:testify_pro/domain/entities/test_metrics.dart';
import 'package:testify_pro/core/utils/report_generator.dart';

void main() {
  group('ReportGenerator Tests', () {
    test('Generates modern HTML report for Data-Driven test runs', () {
      final now = DateTime.now();
      final testRun = TestRun(
        id: 'dd-test-1',
        name: 'Quotation Workflow (Data-Driven - 3 Iterations)',
        type: TestType.flow,
        status: TestStatus.completed,
        startTime: now.subtract(const Duration(seconds: 10)),
        endTime: now,
        config: {
          'flowName': 'Quotation Workflow',
          'totalIterations': 3,
          'datasetName': 'rates_sample.csv',
        },
        metadata: {
          'isDataDriven': true,
          'totalIterations': 3,
          'passedIterations': 3,
          'failedIterations': 0,
          'totalRequests': 6,
          'totalDurationMs': 1250,
          'avgDurationMs': 416.6,
          'iterationResults': [
            {
              'iterationNumber': 1,
              'success': true,
              'durationMs': 410,
              'rowData': {'Sum Insured': 500000, '20Yrs': 4214},
              'stepResults': [
                {
                  'stepName': 'Calculate Premium',
                  'success': true,
                  'response': {'statusCode': 200, 'responseTimeMs': 180},
                  'assertionResults': [
                    {
                      'assertionName': 'Extract premium from response',
                      'passed': true,
                      'message': null,
                    }
                  ],
                }
              ],
            },
            {
              'iterationNumber': 2,
              'success': true,
              'durationMs': 420,
              'rowData': {'Sum Insured': 1000000, '20Yrs': 8500},
              'stepResults': [
                {
                  'stepName': 'Calculate Premium',
                  'success': true,
                  'response': {'statusCode': 200, 'responseTimeMs': 190},
                  'assertionResults': [
                    {
                      'assertionName': 'Extract premium from response',
                      'passed': true,
                      'message': null,
                    }
                  ],
                }
              ],
            },
          ],
        },
      );

      final html = ReportGenerator.generateHtmlReport(testRun);

      expect(html, contains('<!DOCTYPE html>'));
      expect(html, contains('Data-Driven Flow'));
      expect(html, contains('Total Iterations'));
      expect(html, contains('rates_sample.csv'));
      expect(html, contains('Sum Insured:</b> 500000'));
      expect(html, contains('20Yrs:</b> 4214'));
      expect(html, contains('Extract premium from response'));
      expect(html, contains('filterRows()')); // Interactive search script
      expect(html, contains('window.print()')); // Print / PDF button
    });

    test('Generates flow report for standard flow runs without requiring finalMetrics', () {
      final now = DateTime.now();
      final testRun = TestRun(
        id: 'flow-test-1',
        name: 'Login & Checkout Flow',
        type: TestType.flow,
        status: TestStatus.completed,
        startTime: now.subtract(const Duration(seconds: 5)),
        endTime: now,
        config: {
          'flowName': 'Login & Checkout Flow',
          'totalSteps': 2,
        },
        metadata: {
          'result': {
            'flowName': 'Login & Checkout Flow',
            'success': true,
            'stepResults': [
              {
                'stepName': 'Auth Step',
                'success': true,
                'response': {'statusCode': 200, 'responseTimeMs': 120},
                'extractedVars': {'authToken': 'jwt_xyz'},
                'assertionResults': [
                  {'assertionName': 'Status is 200', 'passed': true},
                ],
              },
              {
                'stepName': 'Checkout Step',
                'success': true,
                'response': {'statusCode': 201, 'responseTimeMs': 240},
                'assertionResults': [
                  {'assertionName': 'Order Created', 'passed': true},
                ],
              },
            ],
          },
        },
      );

      final html = ReportGenerator.generateHtmlReport(testRun);

      expect(html, isNot(contains('No metrics available')));
      expect(html, contains('API Flow'));
      expect(html, contains('Step Execution Pipeline'));
      expect(html, contains('Auth Step'));
      expect(html, contains('Checkout Step'));
      expect(html, contains('authToken=jwt_xyz'));
      expect(html, contains('200'));
      expect(html, contains('201'));
    });

    test('Generates load test report with percentile metrics', () {
      final now = DateTime.now();
      final metrics = TestMetrics(
        timestamp: now,
        totalRequests: 5000,
        successCount: 4950,
        failureCount: 50,
        avgResponseTimeMs: 45.2,
        currentRps: 250.0,
        p50ResponseTimeMs: 38.0,
        p95ResponseTimeMs: 85.0,
        p99ResponseTimeMs: 140.0,
        minResponseTimeMs: 12.0,
        maxResponseTimeMs: 320.0,
        errorRate: 0.01,
      );

      final testRun = TestRun(
        id: 'load-test-1',
        name: 'Peak Load Test',
        type: TestType.load,
        status: TestStatus.completed,
        startTime: now.subtract(const Duration(seconds: 30)),
        endTime: now,
        finalMetrics: metrics,
        config: {
          'virtualUsers': 100,
          'durationSeconds': 30,
        },
      );

      final html = ReportGenerator.generateHtmlReport(testRun);

      expect(html, contains('Load Performance Test'));
      expect(html, contains('5000'));
      expect(html, contains('99.00%'));
      expect(html, contains('250.0 RPS'));
      expect(html, contains('P50 (Median)'));
      expect(html, contains('38.00ms'));
      expect(html, contains('85.00ms'));
      expect(html, contains('140.00ms'));
    });

    test('saveReport creates HTML file on disk in test_reports directory', () async {
      const htmlContent = '<html><body><h1>Testify Pro Report</h1></body></html>';
      final path = await ReportGenerator.saveReport(htmlContent, 'Sample Test');

      final file = File(path);
      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(), equals(htmlContent));

      // Clean up test file
      file.deleteSync();
    });
  });
}
