import 'package:intl/intl.dart';
import '../../domain/entities/test_run.dart';
import '../../domain/entities/test_metrics.dart';
import 'dart:io';

class ReportGenerator {
  static String generateHtmlReport(TestRun testRun) {
    final metrics = testRun.finalMetrics;
    if (metrics == null) return 'No metrics available for this test run.';

    final startTime = DateFormat(
      'MMM dd, yyyy HH:mm:ss',
    ).format(testRun.startTime);
    final duration = metrics.timestamp.difference(testRun.startTime).inSeconds;

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Testify Pro Report - ${testRun.name}</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #2563eb;
            --success: #10b981;
            --error: #ef4444;
            --bg: #f8fafc;
            --card: #ffffff;
            --text: #1e293b;
        }
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg);
            color: var(--text);
            margin: 0;
            padding: 40px;
            line-height: 1.5;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 40px;
        }
        h1 { margin: 0; font-size: 24px; font-weight: 700; color: var(--primary); }
        .timestamp { color: #64748b; font-size: 14px; }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 40px;
        }
        .stat-card {
            background: var(--card);
            padding: 24px;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .stat-label { color: #64748b; font-size: 13px; font-weight: 600; text-transform: uppercase; margin-bottom: 8px; }
        .stat-value { font-size: 24px; font-weight: 700; }
        
        .section {
            background: var(--card);
            border-radius: 12px;
            padding: 32px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 32px;
        }
        h2 { font-size: 18px; margin-top: 0; margin-bottom: 24px; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; }
        
        .table-container { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th { color: #64748b; font-weight: 600; font-size: 13px; padding: 12px; border-bottom: 1px solid #e2e8f0; }
        td { padding: 12px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
        
        .badge {
            padding: 4px 12px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-success { background: #d1fae5; color: #065f46; }
        .badge-error { background: #fee2e2; color: #991b1b; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div>
                <h1>${testRun.name}</h1>
                <div class="timestamp">Started on ${startTime}</div>
            </div>
            <div class="badge ${testRun.status.name == 'completed' ? 'badge-success' : 'badge-error'}">
                ${testRun.status.name.toUpperCase()}
            </div>
        </div>

        <div class="grid">
            <div class="stat-card">
                <div class="stat-label">Total Requests</div>
                <div class="stat-value">${metrics.totalRequests}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Avg Latency</div>
                <div class="stat-value">${metrics.avgResponseTimeMs.toStringAsFixed(2)}ms</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Peak RPS</div>
                <div class="stat-value">${metrics.currentRps.toStringAsFixed(1)}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Success Rate</div>
                <div class="stat-value">${metrics.successRatePercentage}</div>
            </div>
        </div>

        <div class="section">
            <h2>Detailed Metrics</h2>
            <table>
                <thead>
                    <tr>
                        <th>Metric</th>
                        <th>Value</th>
                    </tr>
                </thead>
                <tbody>
                    <tr><td>Duration</td><td>${duration}s</td></tr>
                    <tr><td>Total Errors</td><td>${metrics.failureCount}</td></tr>
                    <tr><td>P95 Latency</td><td>${metrics.p95ResponseTimeMs.toStringAsFixed(2)}ms</td></tr>
                    <tr><td>P99 Latency</td><td>${metrics.p99ResponseTimeMs.toStringAsFixed(2)}ms</td></tr>
                </tbody>
            </table>
        </div>

        <div class="section">
            <h2>Configuration</h2>
            <pre style="background: #f1f5f9; padding: 16px; border-radius: 8px; font-size: 13px;">${testRun.config.entries.map((e) => '${e.key}: ${e.value}').join('\\n')}</pre>
        </div>

        <footer style="text-align: center; margin-top: 60px; color: #94a3b8; font-size: 12px;">
            Generated by Testify Pro - The Professional API Testing Suite
        </footer>
    </div>
</body>
</html>
''';
  }

  static Future<String> saveReport(String html, String testName) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName =
        'test_report_${testName.replaceAll(" ", "_")}_$timestamp.html';

    // For Windows, default to test_reports directory
    final path = 'test_reports/$fileName';
    final file = File(path);

    if (!(await file.parent.exists())) {
      await file.parent.create(recursive: true);
    }

    await file.writeAsString(html);
    return file.absolute.path;
  }
}
