import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/flow.dart' as entities;
import '../../domain/entities/test_run.dart';
import '../../domain/entities/test_metrics.dart';
import '../../core/utils/csv_parser.dart';
import '../../core/utils/report_generator.dart';
import '../../infrastructure/flow_engine/iteration_runner.dart';
import '../../core/providers/global_providers.dart';
import '../screens/history_screen.dart';

class DataRunnerDialog extends ConsumerStatefulWidget {
  final entities.Flow flow;

  const DataRunnerDialog({
    super.key,
    required this.flow,
  });

  static Future<void> show(BuildContext context, entities.Flow flow) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DataRunnerDialog(flow: flow),
    );
  }

  @override
  ConsumerState<DataRunnerDialog> createState() => _DataRunnerDialogState();
}

class _DataRunnerDialogState extends ConsumerState<DataRunnerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _pasteController = TextEditingController();

  String? _selectedFileName;
  List<Map<String, dynamic>> _parsedRows = [];
  String? _parseError;

  bool _isRunning = false;
  int _currentIteration = 0;
  IterationRunSummary? _runSummary;
  TestRun? _savedTestRun;
  bool _isExporting = false;
  final List<IterationResult> _liveResults = [];
  bool _stopOnFailure = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _parsedRows = [];
        _parseError = null;
      });
      return;
    }

    try {
      final rows = CsvParser.parseAuto(text);
      setState(() {
        _parsedRows = rows;
        _parseError = rows.isEmpty ? 'No data rows found in input.' : null;
      });
    } catch (e) {
      setState(() {
        _parsedRows = [];
        _parseError = 'Parse Error: $e';
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          final file = File(path);
          final content = await file.readAsString();
          setState(() {
            _selectedFileName = result.files.first.name;
          });
          _onTextChanged(content);
        }
      }
    } catch (e) {
      setState(() {
        _parseError = 'Error reading file: $e';
      });
    }
  }

  void _loadSampleData() {
    const sampleCsv = '''userId,username,role,email,expectedStatus
101,alex_tester,admin,alex@example.com,active
102,sarah_dev,editor,sarah@example.com,active
103,david_ops,viewer,david@example.com,pending
104,emma_qa,tester,emma@example.com,active''';

    _pasteController.text = sampleCsv;
    _tabController.animateTo(1);
    _onTextChanged(sampleCsv);
  }

  Future<void> _startExecution() async {
    if (_parsedRows.isEmpty) return;

    setState(() {
      _isRunning = true;
      _currentIteration = 0;
      _liveResults.clear();
      _runSummary = null;
      _savedTestRun = null;
    });

    final flowExecutor = ref.read(flowExecutorProvider);
    final runner = IterationRunner(flowExecutor);
    final startTime = DateTime.now();

    try {
      final summary = await runner.runWithData(
        flow: widget.flow,
        iterationData: _parsedRows,
        stopOnFailure: _stopOnFailure,
        onIterationComplete: (result) {
          if (mounted) {
            setState(() {
              _currentIteration = result.iterationNumber;
              _liveResults.add(result);
            });
          }
        },
      );

      final endTime = DateTime.now();
      final totalRequests = summary.totalRequestsExecuted;
      final avgResp = totalRequests > 0
          ? (summary.totalDurationMs / totalRequests).toDouble()
          : 0.0;

      final testMetrics = TestMetrics(
        timestamp: endTime,
        totalRequests: totalRequests,
        successCount: summary.iterationResults.fold(
            0,
            (acc, r) =>
                acc +
                r.flowResult.stepResults.where((s) => s.success).length),
        failureCount: summary.iterationResults.fold(
            0,
            (acc, r) =>
                acc +
                r.flowResult.stepResults.where((s) => !s.success).length),
        avgResponseTimeMs: avgResp,
        minResponseTimeMs: 0.0,
        maxResponseTimeMs: 0.0,
        currentRps: summary.totalDurationMs > 0
            ? (totalRequests / (summary.totalDurationMs / 1000.0))
            : 0.0,
        errorRate: summary.totalIterations > 0
            ? (summary.failedIterations / summary.totalIterations)
            : 0.0,
      );

      final testRunId = const Uuid().v4();
      final testRun = TestRun(
        id: testRunId,
        name: '${widget.flow.name} (Data-Driven - ${summary.totalIterations} Iterations)',
        type: TestType.flow,
        status: summary.allPassed ? TestStatus.completed : TestStatus.failed,
        startTime: startTime,
        endTime: endTime,
        finalMetrics: testMetrics,
        config: {
          'flowId': widget.flow.id,
          'flowName': widget.flow.name,
          'totalIterations': summary.totalIterations,
          'stopOnFailure': _stopOnFailure,
          'datasetName': _selectedFileName ?? 'Pasted Dataset',
        },
        metadata: {
          'isDataDriven': true,
          'totalIterations': summary.totalIterations,
          'passedIterations': summary.passedIterations,
          'failedIterations': summary.failedIterations,
          'totalRequests': summary.totalRequestsExecuted,
          'totalDurationMs': summary.totalDurationMs,
          'avgDurationMs': summary.averageIterationDurationMs,
          'iterationResults': summary.iterationResults.map((r) => {
            'iterationNumber': r.iterationNumber,
            'success': r.success,
            'durationMs': r.durationMs,
            'errorMessage': r.errorMessage,
            'rowData': r.rowData,
            'stepResults': r.flowResult.stepResults.map((s) => s.toJson()).toList(),
          }).toList(),
        },
      );

      await ref.read(testRunRepositoryProvider).saveTestRun(testRun);
      ref.invalidate(historyProvider);

      if (mounted) {
        setState(() {
          _isRunning = false;
          _runSummary = summary;
          _savedTestRun = testRun;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRunning = false;
          _parseError = 'Execution Error: $e';
        });
      }
    }
  }

  Future<void> _exportHtmlReport() async {
    if (_savedTestRun == null) return;
    setState(() => _isExporting = true);
    try {
      final html = ReportGenerator.generateHtmlReport(_savedTestRun!);
      final path = await ReportGenerator.saveReport(html, _savedTestRun!.name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('Report saved to: $path')),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 960,
          maxHeight: 740,
          minWidth: 400,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.dataset_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data-Driven Iteration Runner',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Run "${widget.flow.name}" across CSV or JSON data rows (Newman-style)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _isRunning ? null : _loadSampleData,
                    icon: const Icon(Icons.lightbulb_outline, size: 16),
                    label: const Text('Load Sample CSV'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isRunning ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // If running or finished, show run console
              if (_isRunning || _runSummary != null)
                Expanded(child: _buildExecutionView(theme))
              else
                Expanded(child: _buildInputView(theme)),

              const SizedBox(height: 16),

              // Footer Actions
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tabs
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.file_upload_outlined, size: 18), text: 'Pick CSV / JSON File'),
            Tab(icon: Icon(Icons.edit_note_outlined, size: 18), text: 'Paste CSV / JSON Text'),
          ],
        ),
        const SizedBox(height: 14),

        // Tab Content
        Expanded(
          flex: 2,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: File Picker
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.table_chart_outlined, size: 48, color: theme.colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(
                        _selectedFileName ?? 'Select a CSV or JSON file from your computer',
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.tonalIcon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Browse Data File...'),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab 2: Paste Code Editor
              TextField(
                controller: _pasteController,
                onChanged: _onTextChanged,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Paste CSV (comma-separated with headers) or JSON array of objects...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Preview Table / Status
        Expanded(
          flex: 3,
          child: _buildPreviewTable(theme),
        ),
      ],
    );
  }

  Widget _buildPreviewTable(ThemeData theme) {
    if (_parseError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.error),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _parseError!,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      );
    }

    if (_parsedRows.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No dataset loaded. Upload a CSV file or paste data above to preview columns and rows.',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final headers = _parsedRows.first.keys.toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table header info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'Dataset Ready: ${_parsedRows.length} iterations, ${headers.length} columns',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Columns: ${headers.join(', ')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable data preview
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20,
                  headingRowHeight: 36,
                  dataRowMinHeight: 32,
                  dataRowMaxHeight: 36,
                  columns: [
                    const DataColumn(label: Text('#')),
                    ...headers.map((h) => DataColumn(label: Text(h))),
                  ],
                  rows: _parsedRows.take(10).toList().asMap().entries.map((e) {
                    final idx = e.key + 1;
                    final row = e.value;
                    return DataRow(
                      cells: [
                        DataCell(Text(idx.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                        ...headers.map((h) => DataCell(Text(row[h]?.toString() ?? ''))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live Progress Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isRunning
                ? theme.colorScheme.primaryContainer
                : (_runSummary?.allPassed == true
                    ? Colors.green.shade50
                    : Colors.red.shade50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isRunning
                  ? theme.colorScheme.primary
                  : (_runSummary?.allPassed == true ? Colors.green : Colors.red),
            ),
          ),
          child: Row(
            children: [
              if (_isRunning) ...[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Running Iteration $_currentIteration of ${_parsedRows.length}...',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                Icon(
                  _runSummary?.allPassed == true ? Icons.check_circle : Icons.error,
                  color: _runSummary?.allPassed == true ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _runSummary?.allPassed == true
                            ? 'All Iterations Passed (${_runSummary!.passedIterations}/${_runSummary!.totalIterations})'
                            : 'Iterations Completed with Failures (${_runSummary!.failedIterations} failed)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _runSummary?.allPassed == true ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                      Text(
                        'Total requests: ${_runSummary?.totalRequestsExecuted} | Total time: ${_runSummary?.totalDurationMs}ms | Avg iteration: ${_runSummary?.averageIterationDurationMs.toStringAsFixed(1)}ms',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _runSummary?.allPassed == true ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Iteration rows list
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              itemCount: _liveResults.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _liveResults[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: item.success ? Colors.green.shade100 : Colors.red.shade100,
                    child: Icon(
                      item.success ? Icons.check : Icons.close,
                      size: 16,
                      color: item.success ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                  title: Text(
                    'Iteration ${item.iterationNumber}: ${item.success ? "Passed" : "Failed"} (${item.durationMs}ms)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item.success ? Colors.green.shade900 : Colors.red.shade900,
                    ),
                  ),
                  subtitle: Text(
                    item.errorMessage != null
                        ? 'Error: ${item.errorMessage}'
                        : 'Data: ${item.rowData.entries.map((e) => "${e.key}: ${e.value}").take(4).join(" | ")}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${item.flowResult.stepResults.length} steps',
                    style: theme.textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    if (_runSummary != null) {
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 18, color: Colors.green.shade600),
              const SizedBox(width: 6),
              Text(
                'Saved to Test History',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.tonalIcon(
                onPressed: _isExporting ? null : _exportHtmlReport,
                icon: _isExporting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.description_outlined, size: 18),
                label: const Text('Export HTML Report'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _runSummary = null;
                  _savedTestRun = null;
                }),
                icon: const Icon(Icons.replay, size: 18),
                label: const Text('Re-run'),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        if (!_isRunning) ...[
          Checkbox(
            value: _stopOnFailure,
            onChanged: (val) => setState(() => _stopOnFailure = val ?? false),
          ),
          const Flexible(
            child: Text(
              'Stop on first failure',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        const Spacer(),
        OutlinedButton(
          onPressed: _isRunning ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: (_parsedRows.isNotEmpty && !_isRunning)
              ? _startExecution
              : null,
          icon: const Icon(Icons.play_arrow),
          label: Text(
            _parsedRows.isEmpty
                ? 'Run Iterations'
                : 'Run ${_parsedRows.length} Iterations 🚀',
          ),
        ),
      ],
    );
  }
}
