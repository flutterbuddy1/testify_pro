// Export Utilities
// Functions to export test results as CSV and JSON

import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import '../../domain/entities/test_run.dart';
import '../../domain/entities/test_metrics.dart';

class ExportUtils {
  /// Export test run results as CSV
  static String generateCsv(TestRun testRun) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Testify Pro - Test Results Export');
    buffer.writeln('Test Name,${testRun.name}');
    buffer.writeln('Test Type,${testRun.type.name.toUpperCase()}');
    buffer.writeln('Start Time,${_formatDateTime(testRun.startTime)}');
    buffer.writeln(
      'End Time,${testRun.endTime != null ? _formatDateTime(testRun.endTime!) : "N/A"}',
    );
    buffer.writeln('Duration,${testRun.durationFormatted}');
    buffer.writeln('Status,${testRun.status.name.toUpperCase()}');
    buffer.writeln('');

    // Configuration (generic)
    if (testRun.config.isNotEmpty) {
      buffer.writeln('Configuration');
      testRun.config.forEach((key, value) {
        buffer.writeln('$key,$value');
      });
      buffer.writeln('');
    }

    // Metrics
    if (testRun.finalMetrics != null) {
      final metrics = testRun.finalMetrics!;
      buffer.writeln('Final Metrics');
      buffer.writeln('Total Requests,${metrics.totalRequests}');
      buffer.writeln('Success Count,${metrics.successCount}');
      buffer.writeln('Failure Count,${metrics.failureCount}');
      buffer.writeln('Success Rate,${metrics.successRatePercentage}');
      buffer.writeln('Error Rate,${metrics.errorRatePercentage}');
      buffer.writeln('Average RPS,${metrics.currentRps.toStringAsFixed(2)}');
      buffer.writeln(
        'Avg Response Time (ms),${metrics.avgResponseTimeMs.toStringAsFixed(2)}',
      );
      buffer.writeln(
        'Min Response Time (ms),${metrics.minResponseTimeMs.toStringAsFixed(2)}',
      );
      buffer.writeln(
        'Max Response Time (ms),${metrics.maxResponseTimeMs.toStringAsFixed(2)}',
      );
      buffer.writeln(
        'P50 Response Time (ms),${metrics.p50ResponseTimeMs.toStringAsFixed(2)}',
      );
      buffer.writeln(
        'P95 Response Time (ms),${metrics.p95ResponseTimeMs.toStringAsFixed(2)}',
      );
      buffer.writeln(
        'P99 Response Time (ms),${metrics.p99ResponseTimeMs.toStringAsFixed(2)}',
      );
      buffer.writeln('');
    }

    // Metadata (test-specific results)
    if (testRun.metadata.isNotEmpty) {
      buffer.writeln('Additional Information');
      testRun.metadata.forEach((key, value) {
        if (value is Map || value is List) {
          buffer.writeln('$key,${jsonEncode(value)}');
        } else {
          buffer.writeln('$key,$value');
        }
      });
      buffer.writeln('');
    }

    // Error
    if (testRun.error != null) {
      buffer.writeln('Error');
      buffer.writeln(testRun.error!);
    }

    return buffer.toString();
  }

  /// Export test run results as JSON
  static String generateJson(TestRun testRun) {
    // Use the built-in toJson from Freezed
    final data = testRun.toJson();

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  /// Export simplified JSON (without large metadata)
  static String generateSimplifiedJson(TestRun testRun) {
    final data = {
      'id': testRun.id,
      'testName': testRun.name,
      'testType': testRun.type.name,
      'startTime': testRun.startTime.toIso8601String(),
      'endTime': testRun.endTime?.toIso8601String(),
      'duration': testRun.duration?.inSeconds,
      'status': testRun.status.name,
      'configuration': testRun.config,
      'metrics': testRun.finalMetrics != null
          ? {
              'totalRequests': testRun.finalMetrics!.totalRequests,
              'successRate': testRun.finalMetrics!.successRatePercentage,
              'avgResponseTime': testRun.finalMetrics!.avgResponseTimeMs,
              'p95ResponseTime': testRun.finalMetrics!.p95ResponseTimeMs,
            }
          : null,
      'error': testRun.error,
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  /// Save CSV to file
  static Future<void> saveCsvToFile(String csv, String filePath) async {
    final file = File(filePath);
    await file.writeAsString(csv);
  }

  /// Save JSON to file
  static Future<void> saveJsonToFile(String json, String filePath) async {
    final file = File(filePath);
    await file.writeAsString(json);
  }

  /// Generate filename for export
  static String generateFilename(TestRun testRun, String extension) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(testRun.startTime);
    final testType = testRun.type.name;
    return 'testify_${testType}_${timestamp}.$extension';
  }

  static String _formatDateTime(DateTime dt) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
  }
}
