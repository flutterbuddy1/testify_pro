import 'dart:io';
import 'package:intl/intl.dart';
import '../../domain/entities/test_run.dart';
import '../../domain/entities/test_metrics.dart';

class ReportGenerator {
  static String generateHtmlReport(TestRun testRun) {
    final isDataDriven = testRun.metadata['isDataDriven'] == true ||
        (testRun.metadata['iterationResults'] != null &&
            (testRun.metadata['iterationResults'] as List).isNotEmpty);

    if (isDataDriven) {
      return _generateDataDrivenReport(testRun);
    } else if (testRun.type == TestType.flow) {
      return _generateFlowReport(testRun);
    } else if (testRun.type == TestType.load) {
      return _generateLoadTestReport(testRun);
    } else {
      return _generateApiTestReport(testRun);
    }
  }

  static String _formatDuration(int? ms) {
    if (ms == null) return 'N/A';
    if (ms < 1000) return '${ms}ms';
    final seconds = (ms / 1000).toStringAsFixed(2);
    return '${seconds}s';
  }

  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }

  static String _getBaseStyles() {
    return '''
      :root {
        --primary: #4f46e5;
        --primary-hover: #4338ca;
        --primary-light: #e0e7ff;
        --success: #059669;
        --success-bg: #d1fae5;
        --success-text: #065f46;
        --error: #dc2626;
        --error-bg: #fee2e2;
        --error-text: #991b1b;
        --warning: #d97706;
        --warning-bg: #fef3c7;
        --warning-text: #92400e;
        --bg: #f8fafc;
        --card-bg: #ffffff;
        --text: #0f172a;
        --text-muted: #64748b;
        --border: #e2e8f0;
        --border-subtle: #f1f5f9;
      }
      * { box-sizing: border-box; margin: 0; padding: 0; }
      body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        background-color: var(--bg);
        color: var(--text);
        line-height: 1.5;
        padding: 32px 20px;
      }
      .container { max-width: 1120px; margin: 0 auto; }
      .header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        flex-wrap: wrap;
        gap: 16px;
        background: var(--card-bg);
        border: 1px solid var(--border);
        border-radius: 16px;
        padding: 24px 28px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        margin-bottom: 24px;
      }
      .header-title-group h1 {
        font-size: 24px;
        font-weight: 700;
        color: var(--text);
        margin-bottom: 6px;
        display: flex;
        align-items: center;
        gap: 10px;
        flex-wrap: wrap;
      }
      .header-meta {
        color: var(--text-muted);
        font-size: 14px;
        display: flex;
        align-items: center;
        gap: 16px;
        flex-wrap: wrap;
      }
      .header-actions {
        display: flex;
        gap: 10px;
        align-items: center;
      }
      .badge {
        display: inline-flex;
        align-items: center;
        padding: 5px 12px;
        border-radius: 9999px;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.04em;
      }
      .badge-success { background: var(--success-bg); color: var(--success-text); }
      .badge-error { background: var(--error-bg); color: var(--error-text); }
      .badge-primary { background: var(--primary-light); color: var(--primary); }
      .badge-neutral { background: #f1f5f9; color: #475569; }

      .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 16px;
        margin-bottom: 24px;
      }
      .stat-card {
        background: var(--card-bg);
        border: 1px solid var(--border);
        border-radius: 14px;
        padding: 20px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        display: flex;
        flex-direction: column;
      }
      .stat-label {
        font-size: 12px;
        font-weight: 600;
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 0.05em;
        margin-bottom: 6px;
      }
      .stat-value {
        font-size: 26px;
        font-weight: 800;
        color: var(--text);
      }
      .stat-value.text-success { color: var(--success); }
      .stat-value.text-error { color: var(--error); }
      .stat-value.text-primary { color: var(--primary); }
      .stat-subtext {
        font-size: 12px;
        color: var(--text-muted);
        margin-top: 4px;
      }

      .section-card {
        background: var(--card-bg);
        border: 1px solid var(--border);
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        margin-bottom: 24px;
      }
      .section-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 12px;
        padding-bottom: 16px;
        border-bottom: 1px solid var(--border);
        margin-bottom: 18px;
      }
      .section-title {
        font-size: 18px;
        font-weight: 700;
        color: var(--text);
      }

      .filter-toolbar {
        display: flex;
        gap: 10px;
        align-items: center;
        flex-wrap: wrap;
        margin-bottom: 16px;
      }
      .search-box {
        flex: 1;
        min-width: 240px;
        padding: 8px 14px;
        border-radius: 8px;
        border: 1px solid var(--border);
        font-size: 14px;
        outline: none;
      }
      .search-box:focus { border-color: var(--primary); }
      .filter-btn {
        padding: 8px 14px;
        border-radius: 8px;
        border: 1px solid var(--border);
        background: var(--card-bg);
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.15s ease;
      }
      .filter-btn.active {
        background: var(--primary);
        color: #fff;
        border-color: var(--primary);
      }
      .action-btn {
        padding: 8px 16px;
        border-radius: 8px;
        background: var(--primary);
        color: #fff;
        font-size: 13px;
        font-weight: 600;
        border: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 6px;
      }
      .action-btn:hover { background: var(--primary-hover); }

      .table-wrapper {
        overflow-x: auto;
        border-radius: 8px;
        border: 1px solid var(--border);
      }
      table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
      }
      th {
        background: #f8fafc;
        color: var(--text-muted);
        font-size: 12px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        padding: 12px 16px;
        border-bottom: 1px solid var(--border);
      }
      td {
        padding: 14px 16px;
        border-bottom: 1px solid var(--border);
        font-size: 14px;
        vertical-align: middle;
      }
      tr:last-child td { border-bottom: none; }
      tr:hover td { background-color: #fafbfc; }

      .tag {
        display: inline-block;
        padding: 2px 8px;
        border-radius: 4px;
        font-size: 11px;
        font-weight: 600;
        margin: 2px 3px 2px 0;
        background: #f1f5f9;
        color: #334155;
        border: 1px solid #e2e8f0;
      }
      .method-tag {
        font-size: 11px;
        font-weight: 800;
        padding: 2px 6px;
        border-radius: 4px;
        color: #fff;
      }
      .method-GET { background-color: #059669; }
      .method-POST { background-color: #2563eb; }
      .method-PUT { background-color: #d97706; }
      .method-DELETE { background-color: #dc2626; }
      .method-PATCH { background-color: #7c3aed; }

      .status-pill {
        font-weight: 700;
        padding: 3px 8px;
        border-radius: 6px;
        font-size: 12px;
      }
      .status-2xx { background: var(--success-bg); color: var(--success-text); }
      .status-4xx, .status-5xx { background: var(--error-bg); color: var(--error-text); }

      .step-item {
        background: #fafbfc;
        border: 1px solid var(--border);
        border-radius: 8px;
        padding: 12px 14px;
        margin-top: 8px;
      }
      .step-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 8px;
        font-size: 13px;
      }
      .assertion-item {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 12px;
        margin-top: 4px;
        color: #334155;
      }
      .assertion-item.passed { color: var(--success); }
      .assertion-item.failed { color: var(--error); font-weight: 600; }

      pre {
        background: #0f172a;
        color: #e2e8f0;
        padding: 14px;
        border-radius: 8px;
        font-size: 12px;
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        overflow-x: auto;
      }

      footer {
        text-align: center;
        margin-top: 40px;
        color: var(--text-muted);
        font-size: 13px;
      }

      /* Responsive Layout */
      @media (max-width: 900px) {
        body { padding: 16px 12px; }
        .header { padding: 18px 20px; }
        .section-card { padding: 18px 16px; }
      }
      @media (max-width: 600px) {
        .header-title-group h1 { font-size: 20px; }
        .stat-value { font-size: 22px; }
        .stats-grid { grid-template-columns: 1fr; }
        .header-actions { width: 100%; justify-content: flex-end; }
      }
      @media print {
        body { background: #fff; color: #000; padding: 0; }
        .header-actions, .filter-toolbar { display: none !important; }
        .stat-card, .section-card, .header { box-shadow: none; border-color: #ccc; }
        details { open: true !important; }
      }
    ''';
  }

  // 1. DATA-DRIVEN REPORT
  static String _generateDataDrivenReport(TestRun testRun) {
    final meta = testRun.metadata;
    final totalIterations = meta['totalIterations'] ?? 0;
    final passedIterations = meta['passedIterations'] ?? 0;
    final failedIterations = meta['failedIterations'] ?? 0;
    final totalRequests = meta['totalRequests'] ?? 0;
    final totalDurationMs = meta['totalDurationMs'] ?? 0;
    final avgDurationMs = meta['avgDurationMs'] ?? 0.0;
    final iterationResults = (meta['iterationResults'] as List?) ?? [];

    final passRate = totalIterations > 0
        ? ((passedIterations / totalIterations) * 100).toStringAsFixed(1)
        : '0.0';

    final startTimeFormatted =
        DateFormat('MMM dd, yyyy HH:mm:ss').format(testRun.startTime);
    final statusBadgeClass =
        testRun.status == TestStatus.completed ? 'badge-success' : 'badge-error';
    final statusText =
        testRun.status == TestStatus.completed ? 'ALL PASSED' : 'HAS FAILURES';

    final rowsHtml = StringBuffer();
    for (int i = 0; i < iterationResults.length; i++) {
      final iter = iterationResults[i] as Map<String, dynamic>;
      final iterNum = iter['iterationNumber'] ?? (i + 1);
      final success = iter['success'] == true;
      final duration = iter['durationMs'] ?? 0;
      final errorMsg = iter['errorMessage'];
      final rowData = (iter['rowData'] as Map<String, dynamic>?) ?? {};
      final steps = (iter['stepResults'] as List?) ?? [];

      final rowTagsHtml = rowData.entries
          .map((e) =>
              '<span class="tag"><b>${_escapeHtml(e.key)}:</b> ${_escapeHtml(e.value?.toString() ?? '')}</span>')
          .join('');

      final stepsHtml = StringBuffer();
      for (final step in steps) {
        final stepMap = step as Map<String, dynamic>;
        final stepName = stepMap['stepName'] ?? 'Step';
        final stepSuccess = stepMap['success'] == true;
        final response = stepMap['response'] as Map<String, dynamic>?;
        final statusCode = response?['statusCode'] ?? stepMap['statusCode'];
        final responseTime = response?['responseTimeMs'] ?? stepMap['responseTimeMs'];
        final extractedVars = (stepMap['extractedVars'] as Map<String, dynamic>?) ?? {};
        final assertions = (stepMap['assertionResults'] as List?) ?? [];

        final statusClass = (statusCode != null && statusCode >= 200 && statusCode < 300)
            ? 'status-2xx'
            : 'status-4xx';

        final assertionsHtml = StringBuffer();
        for (final a in assertions) {
          final aMap = a as Map<String, dynamic>;
          final aPassed = aMap['passed'] == true;
          final aName = aMap['assertionName'] ?? '';
          final aMsg = aMap['message'] ?? '';
          assertionsHtml.write('''
            <div class="assertion-item ${aPassed ? 'passed' : 'failed'}">
              <span>${aPassed ? '✓' : '✗'}</span>
              <span>${_escapeHtml(aName)}</span>
              ${!aPassed && aMsg.isNotEmpty ? '<span style="color:#ef4444">(${_escapeHtml(aMsg)})</span>' : ''}
            </div>
          ''');
        }

        final extractedHtml = extractedVars.isNotEmpty
            ? '<div style="margin-top:6px;font-size:11px;color:#0284c7;"><b>Extracted:</b> ${extractedVars.entries.map((e) => '<span class="tag" style="background:#e0f2fe;color:#0369a1;">${_escapeHtml(e.key)}=${_escapeHtml(e.value?.toString() ?? '')}</span>').join('')}</div>'
            : '';

        stepsHtml.write('''
          <div class="step-item">
            <div class="step-header">
              <span style="font-weight:600">${_escapeHtml(stepName)}</span>
              <div style="display:flex;gap:8px;align-items:center;">
                ${statusCode != null ? '<span class="status-pill $statusClass">$statusCode</span>' : ''}
                ${responseTime != null ? '<span style="color:#64748b;font-size:12px;">${responseTime}ms</span>' : ''}
                <span class="badge ${stepSuccess ? 'badge-success' : 'badge-error'}" style="font-size:10px;padding:2px 8px;">
                  ${stepSuccess ? 'PASS' : 'FAIL'}
                </span>
              </div>
            </div>
            $extractedHtml
            ${assertionsHtml.isNotEmpty ? '<div style="margin-top:8px;">$assertionsHtml</div>' : ''}
            ${stepMap['errorMessage'] != null ? '<div style="color:#ef4444;font-size:12px;margin-top:6px;">Error: ${_escapeHtml(stepMap['errorMessage'])}</div>' : ''}
          </div>
        ''');
      }

      rowsHtml.write('''
        <tr class="iteration-row" data-status="${success ? 'passed' : 'failed'}" data-keywords="${_escapeHtml(rowData.values.join(' '))} ${_escapeHtml(errorMsg ?? '')}">
          <td style="font-weight:700;width:70px;">#$iterNum</td>
          <td style="width:110px;">
            <span class="badge ${success ? 'badge-success' : 'badge-error'}">
              ${success ? 'PASSED' : 'FAILED'}
            </span>
          </td>
          <td style="width:90px;font-weight:600;">${duration}ms</td>
          <td>
            <div style="margin-bottom:6px;">$rowTagsHtml</div>
            ${errorMsg != null ? '<div style="color:#dc2626;font-size:12px;font-weight:600;">Error: ${_escapeHtml(errorMsg)}</div>' : ''}
            <details style="margin-top:6px;cursor:pointer;">
              <summary style="font-size:12px;color:var(--primary);font-weight:600;">View ${steps.length} Steps & Assertions</summary>
              <div style="margin-top:8px;">$stepsHtml</div>
            </details>
          </td>
        </tr>
      ''');
    }

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Data-Driven Test Report - ${_escapeHtml(testRun.name)}</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>${_getBaseStyles()}</style>
</head>
<body>
    <div class="container">
        <header class="header">
            <div class="header-title-group">
                <h1>
                    <span>${_escapeHtml(testRun.name)}</span>
                    <span class="badge badge-primary">Data-Driven Flow</span>
                </h1>
                <div class="header-meta">
                    <span>📅 Started: $startTimeFormatted</span>
                    <span>⏱️ Total Time: ${_formatDuration(totalDurationMs)}</span>
                    ${testRun.config['datasetName'] != null ? '<span>📁 Dataset: ${_escapeHtml(testRun.config['datasetName'])}</span>' : ''}
                </div>
            </div>
            <div class="header-actions">
                <span class="badge $statusBadgeClass">$statusText</span>
                <button class="action-btn" onclick="window.print()">🖨️ Print / PDF</button>
            </div>
        </header>

        <section class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total Iterations</div>
                <div class="stat-value text-primary">$totalIterations</div>
                <div class="stat-subtext">Rows processed</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Pass Rate</div>
                <div class="stat-value ${failedIterations == 0 ? 'text-success' : 'text-error'}">$passRate%</div>
                <div class="stat-subtext">$passedIterations passed, $failedIterations failed</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Requests Executed</div>
                <div class="stat-value">$totalRequests</div>
                <div class="stat-subtext">Total HTTP calls</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Avg Iteration Time</div>
                <div class="stat-value">${avgDurationMs.toStringAsFixed(1)}ms</div>
                <div class="stat-subtext">Per data row</div>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2 class="section-title">Iteration Matrix & Step Executions</h2>
                <div class="filter-toolbar">
                    <input type="text" id="searchInput" class="search-box" placeholder="Search row data, error, variables..." oninput="filterRows()">
                    <button class="filter-btn active" onclick="setFilter('all', this)">All ($totalIterations)</button>
                    <button class="filter-btn" onclick="setFilter('passed', this)">Passed ($passedIterations)</button>
                    <button class="filter-btn" onclick="setFilter('failed', this)">Failed ($failedIterations)</button>
                </div>
            </div>

            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Status</th>
                            <th>Duration</th>
                            <th>Row Data & Step Execution Details</th>
                        </tr>
                    </thead>
                    <tbody id="iterationTableBody">
                        $rowsHtml
                    </tbody>
                </table>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2 class="section-title">Run Configuration</h2>
            </div>
            <div style="display:grid;grid-template-columns:repeat(auto-fit, minmax(240px, 1fr));gap:12px;">
                ${testRun.config.entries.map((e) => '<div style="padding:10px 14px;background:#f8fafc;border-radius:8px;border:1px solid #e2e8f0;"><div style="font-size:11px;color:#64748b;text-transform:uppercase;font-weight:600;">${_escapeHtml(e.key)}</div><div style="font-size:13px;font-weight:600;margin-top:2px;">${_escapeHtml(e.value?.toString() ?? '')}</div></div>').join('')}
            </div>
        </section>

        <footer>
            Generated by Testify Pro • Enterprise API Testing Suite
        </footer>
    </div>

    <script>
        let currentFilter = 'all';

        function setFilter(filter, btn) {
            currentFilter = filter;
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            filterRows();
        }

        function filterRows() {
            const query = (document.getElementById('searchInput').value || '').toLowerCase();
            const rows = document.querySelectorAll('.iteration-row');

            rows.forEach(row => {
                const status = row.getAttribute('data-status');
                const keywords = (row.getAttribute('data-keywords') || '').toLowerCase();

                const matchesStatus = (currentFilter === 'all') || (status === currentFilter);
                const matchesQuery = !query || keywords.includes(query);

                if (matchesStatus && matchesQuery) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }
    </script>
</body>
</html>
''';
  }

  // 2. STANDARD FLOW REPORT
  static String _generateFlowReport(TestRun testRun) {
    final startTimeFormatted =
        DateFormat('MMM dd, yyyy HH:mm:ss').format(testRun.startTime);
    final durationFormatted = testRun.durationFormatted;
    final statusBadgeClass =
        testRun.status == TestStatus.completed ? 'badge-success' : 'badge-error';
    final statusText = testRun.status.name.toUpperCase();

    final meta = testRun.metadata;
    final flowResult = meta['result'] as Map<String, dynamic>?;

    int totalSteps = testRun.config['totalSteps'] ?? 0;
    int successfulSteps = 0;
    int failedSteps = 0;
    final stepsHtml = StringBuffer();

    if (flowResult != null && flowResult['stepResults'] != null) {
      final steps = flowResult['stepResults'] as List;
      totalSteps = steps.length;

      for (int i = 0; i < steps.length; i++) {
        final step = steps[i] as Map<String, dynamic>;
        final success = step['success'] == true;
        if (success) {
          successfulSteps++;
        } else {
          failedSteps++;
        }

        final stepName = step['stepName'] ?? 'Step ${i + 1}';
        final response = step['response'] as Map<String, dynamic>?;
        final statusCode = response?['statusCode'] ?? step['statusCode'];
        final duration = response?['responseTimeMs'] ?? step['durationMs'];
        final extractedVars = (step['extractedVars'] as Map<String, dynamic>?) ?? {};
        final errorMsg = step['errorMessage'];
        final assertions = (step['assertionResults'] as List?) ?? [];

        final statusClass = (statusCode != null && statusCode >= 200 && statusCode < 300)
            ? 'status-2xx'
            : 'status-4xx';

        final assertionsHtml = StringBuffer();
        for (final a in assertions) {
          final aMap = a as Map<String, dynamic>;
          final aPassed = aMap['passed'] == true;
          final aName = aMap['assertionName'] ?? '';
          final aMsg = aMap['message'] ?? '';
          assertionsHtml.write('''
            <div class="assertion-item ${aPassed ? 'passed' : 'failed'}">
              <span>${aPassed ? '✓' : '✗'}</span>
              <span>${_escapeHtml(aName)}</span>
              ${!aPassed && aMsg.isNotEmpty ? '<span style="color:#ef4444">(${_escapeHtml(aMsg)})</span>' : ''}
            </div>
          ''');
        }

        stepsHtml.write('''
          <tr>
            <td style="font-weight:700;width:60px;">#${i + 1}</td>
            <td style="font-weight:600;">${_escapeHtml(stepName)}</td>
            <td style="width:110px;">
              <span class="badge ${success ? 'badge-success' : 'badge-error'}">
                ${success ? 'PASSED' : 'FAILED'}
              </span>
            </td>
            <td style="width:90px;">
              ${statusCode != null ? '<span class="status-pill $statusClass">$statusCode</span>' : '-'}
            </td>
            <td style="width:90px;font-weight:600;">${duration != null ? '${duration}ms' : '-'}</td>
            <td>
              ${assertionsHtml.isNotEmpty ? assertionsHtml.toString() : '<span style="color:#94a3b8;font-size:12px;">No assertions</span>'}
              ${extractedVars.isNotEmpty ? '<div style="margin-top:4px;font-size:11px;color:#0284c7;"><b>Variables:</b> ${extractedVars.entries.map((e) => '<span class="tag" style="background:#e0f2fe;color:#0369a1;">${_escapeHtml(e.key)}=${_escapeHtml(e.value?.toString() ?? '')}</span>').join('')}</div>' : ''}
              ${errorMsg != null ? '<div style="color:#ef4444;font-size:12px;margin-top:4px;font-weight:600;">Error: ${_escapeHtml(errorMsg)}</div>' : ''}
            </td>
          </tr>
        ''');
      }
    }

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flow Test Report - ${_escapeHtml(testRun.name)}</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>${_getBaseStyles()}</style>
</head>
<body>
    <div class="container">
        <header class="header">
            <div class="header-title-group">
                <h1>
                    <span>${_escapeHtml(testRun.name)}</span>
                    <span class="badge badge-primary">API Flow</span>
                </h1>
                <div class="header-meta">
                    <span>📅 Started: $startTimeFormatted</span>
                    <span>⏱️ Duration: $durationFormatted</span>
                </div>
            </div>
            <div class="header-actions">
                <span class="badge $statusBadgeClass">$statusText</span>
                <button class="action-btn" onclick="window.print()">🖨️ Print / PDF</button>
            </div>
        </header>

        <section class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total Steps</div>
                <div class="stat-value text-primary">$totalSteps</div>
                <div class="stat-subtext">Executed pipeline steps</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Step Success Rate</div>
                <div class="stat-value ${failedSteps == 0 ? 'text-success' : 'text-error'}">
                    ${totalSteps > 0 ? ((successfulSteps / totalSteps) * 100).toStringAsFixed(1) : '0.0'}%
                </div>
                <div class="stat-subtext">$successfulSteps passed, $failedSteps failed</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Execution Status</div>
                <div class="stat-value ${testRun.status == TestStatus.completed ? 'text-success' : 'text-error'}">
                    ${testRun.status.name.toUpperCase()}
                </div>
                <div class="stat-subtext">End-to-end outcome</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Total Duration</div>
                <div class="stat-value">$durationFormatted</div>
                <div class="stat-subtext">Wall-clock time</div>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2 class="section-title">Step Execution Pipeline</h2>
            </div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Step Name</th>
                            <th>Status</th>
                            <th>HTTP Status</th>
                            <th>Duration</th>
                            <th>Assertions & Outcomes</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${stepsHtml.isNotEmpty ? stepsHtml.toString() : '<tr><td colspan="6" style="text-align:center;color:#64748b;">No step execution details recorded.</td></tr>'}
                    </tbody>
                </table>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2 class="section-title">Flow Configuration</h2>
            </div>
            <div style="display:grid;grid-template-columns:repeat(auto-fit, minmax(240px, 1fr));gap:12px;">
                ${testRun.config.entries.map((e) => '<div style="padding:10px 14px;background:#f8fafc;border-radius:8px;border:1px solid #e2e8f0;"><div style="font-size:11px;color:#64748b;text-transform:uppercase;font-weight:600;">${_escapeHtml(e.key)}</div><div style="font-size:13px;font-weight:600;margin-top:2px;">${_escapeHtml(e.value?.toString() ?? '')}</div></div>').join('')}
            </div>
        </section>

        <footer>
            Generated by Testify Pro • Enterprise API Testing Suite
        </footer>
    </div>
</body>
</html>
''';
  }

  // 3. LOAD TEST REPORT
  static String _generateLoadTestReport(TestRun testRun) {
    final metrics = testRun.finalMetrics;
    final startTimeFormatted =
        DateFormat('MMM dd, yyyy HH:mm:ss').format(testRun.startTime);
    final durationFormatted = testRun.durationFormatted;
    final statusBadgeClass =
        testRun.status == TestStatus.completed ? 'badge-success' : 'badge-error';

    final totalReqs = metrics?.totalRequests ?? 0;
    final avgLatency = metrics?.avgResponseTimeMs.toStringAsFixed(2) ?? '0.00';
    final peakRps = metrics?.currentRps.toStringAsFixed(1) ?? '0.0';
    final successRate = metrics?.successRatePercentage ?? '0.0%';
    final p50 = metrics?.p50ResponseTimeMs.toStringAsFixed(2) ?? '0.00';
    final p95 = metrics?.p95ResponseTimeMs.toStringAsFixed(2) ?? '0.00';
    final p99 = metrics?.p99ResponseTimeMs.toStringAsFixed(2) ?? '0.00';
    final failures = metrics?.failureCount ?? 0;

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Load Test Report - ${_escapeHtml(testRun.name)}</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>${_getBaseStyles()}</style>
</head>
<body>
    <div class="container">
        <header class="header">
            <div class="header-title-group">
                <h1>
                    <span>${_escapeHtml(testRun.name)}</span>
                    <span class="badge badge-primary">Load Performance Test</span>
                </h1>
                <div class="header-meta">
                    <span>📅 Started: $startTimeFormatted</span>
                    <span>⏱️ Duration: $durationFormatted</span>
                </div>
            </div>
            <div class="header-actions">
                <span class="badge $statusBadgeClass">${testRun.status.name.toUpperCase()}</span>
                <button class="action-btn" onclick="window.print()">🖨️ Print / PDF</button>
            </div>
        </header>

        <section class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total Requests</div>
                <div class="stat-value text-primary">$totalReqs</div>
                <div class="stat-subtext">Completed HTTP transactions</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Success Rate</div>
                <div class="stat-value ${failures == 0 ? 'text-success' : 'text-error'}">$successRate</div>
                <div class="stat-subtext">$failures errors encountered</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Average Latency</div>
                <div class="stat-value">${avgLatency}ms</div>
                <div class="stat-subtext">Across all responses</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Peak Throughput</div>
                <div class="stat-value text-primary">$peakRps RPS</div>
                <div class="stat-subtext">Requests per second</div>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2 class="section-title">Latency Percentiles & Distribution</h2>
            </div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Percentile</th>
                            <th>Response Time</th>
                            <th>Description</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr><td><b>P50 (Median)</b></td><td><b>${p50}ms</b></td><td>50% of requests responded within this time</td></tr>
                        <tr><td><b>P95</b></td><td><b>${p95}ms</b></td><td>95% of requests responded within this time</td></tr>
                        <tr><td><b>P99</b></td><td><b>${p99}ms</b></td><td>99% of requests responded within this time</td></tr>
                        <tr><td><b>Min Latency</b></td><td>${metrics?.minResponseTimeMs.toStringAsFixed(2) ?? '0.00'}ms</td><td>Fastest recorded response</td></tr>
                        <tr><td><b>Max Latency</b></td><td>${metrics?.maxResponseTimeMs.toStringAsFixed(2) ?? '0.00'}ms</td><td>Slowest recorded response</td></tr>
                    </tbody>
                </table>
            </div>
        </section>

        <section class="section-card">
            <div class="section-header">
                <h2 class="section-title">Load Test Configuration</h2>
            </div>
            <div style="display:grid;grid-template-columns:repeat(auto-fit, minmax(240px, 1fr));gap:12px;">
                ${testRun.config.entries.map((e) => '<div style="padding:10px 14px;background:#f8fafc;border-radius:8px;border:1px solid #e2e8f0;"><div style="font-size:11px;color:#64748b;text-transform:uppercase;font-weight:600;">${_escapeHtml(e.key)}</div><div style="font-size:13px;font-weight:600;margin-top:2px;">${_escapeHtml(e.value?.toString() ?? '')}</div></div>').join('')}
            </div>
        </section>

        <footer>
            Generated by Testify Pro • Enterprise API Testing Suite
        </footer>
    </div>
</body>
</html>
''';
  }

  // 4. API TEST REPORT
  static String _generateApiTestReport(TestRun testRun) {
    final startTimeFormatted =
        DateFormat('MMM dd, yyyy HH:mm:ss').format(testRun.startTime);
    final statusBadgeClass =
        testRun.status == TestStatus.completed ? 'badge-success' : 'badge-error';

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Test Report - ${_escapeHtml(testRun.name)}</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>${_getBaseStyles()}</style>
</head>
<body>
    <div class="container">
        <header class="header">
            <div class="header-title-group">
                <h1>
                    <span>${_escapeHtml(testRun.name)}</span>
                    <span class="badge badge-primary">Single API Request</span>
                </h1>
                <div class="header-meta">
                    <span>📅 Executed: $startTimeFormatted</span>
                </div>
            </div>
            <div class="header-actions">
                <span class="badge $statusBadgeClass">${testRun.status.name.toUpperCase()}</span>
                <button class="action-btn" onclick="window.print()">🖨️ Print / PDF</button>
            </div>
        </header>

        <section class="section-card">
            <div class="section-header">
                <h2 class="section-title">Request Configuration</h2>
            </div>
            <div style="display:grid;grid-template-columns:repeat(auto-fit, minmax(240px, 1fr));gap:12px;">
                ${testRun.config.entries.map((e) => '<div style="padding:10px 14px;background:#f8fafc;border-radius:8px;border:1px solid #e2e8f0;"><div style="font-size:11px;color:#64748b;text-transform:uppercase;font-weight:600;">${_escapeHtml(e.key)}</div><div style="font-size:13px;font-weight:600;margin-top:2px;">${_escapeHtml(e.value?.toString() ?? '')}</div></div>').join('')}
            </div>
        </section>

        <footer>
            Generated by Testify Pro • Enterprise API Testing Suite
        </footer>
    </div>
</body>
</html>
''';
  }

  static Future<String> saveReport(String html, String testName) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final sanitizedName = testName
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final fileName = 'test_report_${sanitizedName}_$timestamp.html';

    final path = 'test_reports/$fileName';
    final file = File(path);

    if (!(await file.parent.exists())) {
      await file.parent.create(recursive: true);
    }

    await file.writeAsString(html);
    return file.absolute.path;
  }
}
