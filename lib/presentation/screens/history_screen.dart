import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/report_generator.dart';
import '../../domain/entities/test_run.dart';
import '../../domain/entities/test_metrics.dart';
import '../../domain/entities/api_response.dart';
import '../../core/providers/global_providers.dart';
import 'metrics_dashboard_screen.dart';

// Provider for history (Stream for real-time updates)
final historyProvider = StreamProvider<List<TestRun>>((ref) {
  final repo = ref.watch(testRunRepositoryProvider);
  return repo.watchTestRuns();
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _categoryFilter;
  TestStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test History',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'View all test executions, data-driven runs, and results',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Spacer(),
                // Statistics
                historyAsync.when(
                  data: (history) => _buildQuickStats(history),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                DropdownButton<String?>(
                  value: _categoryFilter,
                  hint: const Text('All Tests'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Tests')),
                    DropdownMenuItem(
                      value: 'data_driven',
                      child: Text('Data-Driven Flows'),
                    ),
                    DropdownMenuItem(
                      value: 'flow',
                      child: Text('Standard Flows'),
                    ),
                    DropdownMenuItem(
                      value: 'load',
                      child: Text('Load Tests'),
                    ),
                    DropdownMenuItem(
                      value: 'api',
                      child: Text('API Tests'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _categoryFilter = value),
                ),
                const SizedBox(width: 16),
                DropdownButton<TestStatus?>(
                  value: _filterStatus,
                  hint: const Text('All Status'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Status'),
                    ),
                    ...TestStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusLabel(status)),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _filterStatus = value),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _clearHistory(),
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Clear All'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Test runs list
          Expanded(
            child: historyAsync.when(
              data: (history) {
                final filtered = _applyFilters(history);

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final testRun = filtered[index];
                    return _TestRunCard(
                      testRun: testRun,
                      onTap: () => _showTestRunDetails(testRun),
                      onDelete: () => _deleteTestRun(testRun.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Error loading history: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<TestRun> history) {
    final total = history.length;
    final success =
        history.where((r) => r.status == TestStatus.completed).length;
    final failed = history.where((r) => r.status == TestStatus.failed).length;
    final dataDriven =
        history.where((r) => r.metadata['isDataDriven'] == true).length;

    return Row(
      children: [
        _buildStatItem('Total', '$total', null),
        _buildStatItem('Success', '$success', Colors.green),
        _buildStatItem('Failed', '$failed', Colors.red),
        _buildStatItem('Data-Driven', '$dataDriven', Colors.deepPurple),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color? color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No test history',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Run tests or data-driven iterations to see history here',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  List<TestRun> _applyFilters(List<TestRun> history) {
    var filtered = history;

    if (_categoryFilter == 'data_driven') {
      filtered = filtered
          .where((r) => r.metadata['isDataDriven'] == true)
          .toList();
    } else if (_categoryFilter == 'flow') {
      filtered = filtered
          .where((r) =>
              r.type == TestType.flow && r.metadata['isDataDriven'] != true)
          .toList();
    } else if (_categoryFilter == 'load') {
      filtered = filtered.where((r) => r.type == TestType.load).toList();
    } else if (_categoryFilter == 'api') {
      filtered = filtered.where((r) => r.type == TestType.api).toList();
    }

    if (_filterStatus != null) {
      filtered = filtered.where((r) => r.status == _filterStatus).toList();
    }

    return filtered;
  }

  void _showTestRunDetails(TestRun testRun) {
    if (testRun.type == TestType.load && testRun.finalMetrics != null) {
      // Show full dashboard for load tests
      List<ApiResponse> logs = [];
      if (testRun.metadata.containsKey('logs')) {
        try {
          final logsList = testRun.metadata['logs'] as List;
          logs = logsList
              .map(
                (l) =>
                    ApiResponse.fromJson(Map<String, dynamic>.from(l as Map)),
              )
              .toList();
        } catch (e) {
          // ignore parsing error
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MetricsDashboardScreen(
            historicalMetrics: testRun.finalMetrics,
            historicalLogs: logs,
            title: testRun.name,
          ),
        ),
      );
    } else {
      // Show comprehensive detail dialog for data-driven, flow, and api tests
      showDialog(
        context: context,
        builder: (context) => _TestRunDetailsDialog(testRun: testRun),
      );
    }
  }

  Future<void> _deleteTestRun(String id) async {
    final repo = ref.read(testRunRepositoryProvider);
    await repo.deleteTestRun(id);
    ref.invalidate(historyProvider);
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repo = ref.read(testRunRepositoryProvider);
      await repo.clearAll();
      ref.invalidate(historyProvider);
    }
  }

  String _getStatusLabel(TestStatus status) {
    switch (status) {
      case TestStatus.running:
        return 'Running';
      case TestStatus.completed:
        return 'Completed';
      case TestStatus.failed:
        return 'Failed';
      case TestStatus.stopped:
        return 'Stopped';
    }
  }
}

class _TestRunCard extends StatelessWidget {
  final TestRun testRun;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TestRunCard({
    required this.testRun,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDataDriven = testRun.metadata['isDataDriven'] == true;

    return GestureDetector(
      onSecondaryTapDown: (details) =>
          _showContextMenu(context, details.globalPosition),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: _buildIcon(context, isDataDriven),
          title: Text(
            testRun.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(_formatDateTime(testRun.startTime)),
              const SizedBox(height: 2),
              if (isDataDriven)
                Text(
                  '${testRun.metadata['passedIterations'] ?? 0}/${testRun.metadata['totalIterations'] ?? 0} iterations passed • ${testRun.finalMetrics?.totalRequests ?? 0} requests • ${testRun.metadata['totalDurationMs'] != null ? "${testRun.metadata['totalDurationMs']}ms" : testRun.durationFormatted}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.deepPurple.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                )
              else if (testRun.finalMetrics != null)
                Text(
                  '${testRun.finalMetrics!.totalRequests} requests • '
                  '${testRun.finalMetrics!.successRatePercentage} success • '
                  '${testRun.durationFormatted}',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else if (testRun.type == TestType.flow)
                Text(
                  '${testRun.config['totalSteps'] ?? 0} steps • ${testRun.durationFormatted}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDataDriven) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.deepPurple.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Text(
                    'DATA-DRIVEN',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              _buildStatusChip(context),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: Colors.blue,
                ),
                onPressed: () => _exportReport(context),
                tooltip: 'Export HTML Report',
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Future<void> _exportReport(BuildContext context) async {
    final html = ReportGenerator.generateHtmlReport(testRun);
    final path = await ReportGenerator.saveReport(html, testRun.name);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report saved to: $path'),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }

  void _showContextMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          onTap: onTap,
          child: const Row(
            children: [
              Icon(Icons.bar_chart, size: 18),
              SizedBox(width: 12),
              Text('View Details'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => _exportReport(context),
          child: const Row(
            children: [
              Icon(Icons.description_outlined, size: 18, color: Colors.blue),
              SizedBox(width: 12),
              Text('Export HTML Report'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: onDelete,
          child: const Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(BuildContext context, bool isDataDriven) {
    if (isDataDriven) {
      return CircleAvatar(
        backgroundColor: Colors.deepPurple.withValues(alpha: 0.15),
        child: const Icon(Icons.dataset_outlined,
            color: Colors.deepPurple, size: 20),
      );
    }

    IconData icon;
    Color color;

    switch (testRun.type) {
      case TestType.api:
        icon = Icons.api;
        color = Colors.blue;
        break;
      case TestType.flow:
        icon = Icons.account_tree;
        color = Colors.purple;
        break;
      case TestType.load:
        icon = Icons.speed;
        color = Colors.orange;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String label;

    switch (testRun.status) {
      case TestStatus.completed:
        color = Colors.green;
        label = 'Success';
        break;
      case TestStatus.failed:
        color = Colors.red;
        label = 'Failed';
        break;
      case TestStatus.running:
        color = Colors.blue;
        label = 'Running';
        break;
      case TestStatus.stopped:
        color = Colors.orange;
        label = 'Stopped';
        break;
    }

    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color),
    );
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dt);
  }
}

class _TestRunDetailsDialog extends StatefulWidget {
  final TestRun testRun;

  const _TestRunDetailsDialog({required this.testRun});

  @override
  State<_TestRunDetailsDialog> createState() => _TestRunDetailsDialogState();
}

class _TestRunDetailsDialogState extends State<_TestRunDetailsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final isDataDriven = widget.testRun.metadata['isDataDriven'] == true;
    final hasFlowResult = widget.testRun.metadata['result'] != null;
    final hasStepsOrIterations = isDataDriven || hasFlowResult;

    _tabController =
        TabController(length: hasStepsOrIterations ? 3 : 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _exportHtmlReport() async {
    setState(() => _isExporting = true);
    try {
      final html = ReportGenerator.generateHtmlReport(widget.testRun);
      final path = await ReportGenerator.saveReport(html, widget.testRun.name);
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

  void _copyJson() {
    final encoder = const JsonEncoder.withIndent('  ');
    final jsonStr = encoder.convert(widget.testRun.toJson());
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDataDriven = widget.testRun.metadata['isDataDriven'] == true;
    final hasFlowResult = widget.testRun.metadata['result'] != null;
    final hasStepsOrIterations = isDataDriven || hasFlowResult;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 900,
          maxHeight: 700,
          minWidth: 420,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDataDriven
                          ? Colors.deepPurple.withValues(alpha: 0.15)
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isDataDriven
                          ? Icons.dataset_outlined
                          : (widget.testRun.type == TestType.flow
                              ? Icons.account_tree
                              : Icons.speed),
                      color: isDataDriven
                          ? Colors.deepPurple
                          : theme.colorScheme.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.testRun.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildBadge(
                              isDataDriven
                                  ? 'DATA-DRIVEN'
                                  : widget.testRun.type.name.toUpperCase(),
                              isDataDriven ? Colors.deepPurple : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            _buildBadge(
                              widget.testRun.status.name.toUpperCase(),
                              widget.testRun.status == TestStatus.completed
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Started: ${DateFormat('MMM dd, yyyy HH:mm:ss').format(widget.testRun.startTime)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // TabBar
              TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                indicatorColor: theme.colorScheme.primary,
                tabs: [
                  const Tab(
                    icon: Icon(Icons.dashboard_outlined, size: 18),
                    text: 'Overview',
                  ),
                  if (hasStepsOrIterations)
                    Tab(
                      icon: Icon(
                        isDataDriven
                            ? Icons.table_rows_outlined
                            : Icons.format_list_numbered,
                        size: 18,
                      ),
                      text: isDataDriven
                          ? 'Iterations (${(widget.testRun.metadata['iterationResults'] as List?)?.length ?? 0})'
                          : 'Flow Steps',
                    ),
                  const Tab(
                    icon: Icon(Icons.code, size: 18),
                    text: 'Raw JSON',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(theme, isDataDriven),
                    if (hasStepsOrIterations)
                      _buildIterationsOrStepsTab(theme, isDataDriven),
                    _buildRawJsonTab(theme),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
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
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme, bool isDataDriven) {
    final meta = widget.testRun.metadata;
    final totalIterations = meta['totalIterations'] ?? 0;
    final passedIterations = meta['passedIterations'] ?? 0;
    final failedIterations = meta['failedIterations'] ?? 0;
    final totalRequests =
        meta['totalRequests'] ?? widget.testRun.finalMetrics?.totalRequests ?? 0;
    final totalDurationMs = meta['totalDurationMs'];
    final avgDurationMs = meta['avgDurationMs'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat cards
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 650 ? 4 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  if (isDataDriven) ...[
                    _buildKpiCard(
                      'Iterations',
                      '$totalIterations',
                      Icons.repeat,
                      Colors.blue,
                    ),
                    _buildKpiCard(
                      'Pass Rate',
                      totalIterations > 0
                          ? '${((passedIterations / totalIterations) * 100).toStringAsFixed(1)}%'
                          : '0.0%',
                      Icons.check_circle_outline,
                      failedIterations == 0 ? Colors.green : Colors.red,
                    ),
                    _buildKpiCard(
                      'Total Requests',
                      '$totalRequests',
                      Icons.cloud_done_outlined,
                      Colors.purple,
                    ),
                    _buildKpiCard(
                      'Avg / Iteration',
                      avgDurationMs != null
                          ? '${(avgDurationMs as num).toStringAsFixed(1)}ms'
                          : widget.testRun.durationFormatted,
                      Icons.timer_outlined,
                      Colors.orange,
                    ),
                  ] else ...[
                    _buildKpiCard(
                      'Duration',
                      widget.testRun.durationFormatted,
                      Icons.timer_outlined,
                      Colors.blue,
                    ),
                    _buildKpiCard(
                      'Status',
                      widget.testRun.status.name.toUpperCase(),
                      widget.testRun.status == TestStatus.completed
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      widget.testRun.status == TestStatus.completed
                          ? Colors.green
                          : Colors.red,
                    ),
                    _buildKpiCard(
                      'Total Requests',
                      '$totalRequests',
                      Icons.cloud_done_outlined,
                      Colors.purple,
                    ),
                    _buildKpiCard(
                      'Success Rate',
                      widget.testRun.finalMetrics?.successRatePercentage ??
                          (widget.testRun.status == TestStatus.completed
                              ? '100%'
                              : '0%'),
                      Icons.trending_up,
                      Colors.teal,
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Failure error card if any
          if (widget.testRun.error != null ||
              (meta['errorMessage'] != null &&
                  meta['errorMessage'].toString().isNotEmpty)) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.error),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.testRun.error ?? meta['errorMessage'].toString(),
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Configuration details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuration & Metadata',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 20),
                  ...widget.testRun.config.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Flexible(
                            child: Text(
                              e.value?.toString() ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (totalDurationMs != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Execution Time',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text('${totalDurationMs}ms'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIterationsOrStepsTab(ThemeData theme, bool isDataDriven) {
    if (isDataDriven) {
      final iterations =
          (widget.testRun.metadata['iterationResults'] as List?) ?? [];

      final filteredIterations = iterations.where((iter) {
        if (_searchQuery.isEmpty) return true;
        final map = iter as Map<String, dynamic>;
        final iterNum = (map['iterationNumber'] ?? '').toString();
        final rowData = (map['rowData'] as Map<String, dynamic>?) ?? {};
        final err = (map['errorMessage'] ?? '').toString().toLowerCase();

        return iterNum.contains(_searchQuery) ||
            err.contains(_searchQuery) ||
            rowData.values.any(
              (v) => v.toString().toLowerCase().contains(_searchQuery),
            );
      }).toList();

      return Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search iteration by row data, column values, or error...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredIterations.isEmpty
                ? const Center(child: Text('No iterations matching search query.'))
                : ListView.builder(
                    itemCount: filteredIterations.length,
                    itemBuilder: (context, index) {
                      final item =
                          filteredIterations[index] as Map<String, dynamic>;
                      final iterNum = item['iterationNumber'] ?? (index + 1);
                      final success = item['success'] == true;
                      final duration = item['durationMs'] ?? 0;
                      final rowData =
                          (item['rowData'] as Map<String, dynamic>?) ?? {};
                      final steps = (item['stepResults'] as List?) ?? [];
                      final error = item['errorMessage'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: success
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: Icon(
                              success ? Icons.check : Icons.close,
                              size: 16,
                              color: success
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                'Iteration #$iterNum',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildBadge(
                                success ? 'PASSED' : 'FAILED',
                                success ? Colors.green : Colors.red,
                              ),
                              const Spacer(),
                              Text(
                                '${duration}ms',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: rowData.entries.map((e) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme.surfaceContainerHighest
                                            .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${e.key}: ${e.value}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                if (error != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Error: $error',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: steps.map((s) {
                                  final stepMap = s as Map<String, dynamic>;
                                  final stepName =
                                      stepMap['stepName'] ?? 'Step';
                                  final stepSuccess =
                                      stepMap['success'] == true;
                                  final resp = stepMap['response']
                                      as Map<String, dynamic>?;
                                  final statusCode =
                                      resp?['statusCode'] ?? stepMap['statusCode'];
                                  final latency = resp?['responseTimeMs'] ??
                                      stepMap['responseTimeMs'];
                                  final assertions =
                                      (stepMap['assertionResults'] as List?) ??
                                          [];
                                  final extractedVars =
                                      (stepMap['extractedVars']
                                              as Map<String, dynamic>?) ??
                                          {};

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colorScheme.outlineVariant,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              stepSuccess
                                                  ? Icons.check_circle
                                                  : Icons.error,
                                              size: 16,
                                              color: stepSuccess
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                stepName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            if (statusCode != null) ...[
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: (statusCode >= 200 &&
                                                          statusCode < 300)
                                                      ? Colors.green.shade100
                                                      : Colors.red.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '$statusCode',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                    color: (statusCode >= 200 &&
                                                            statusCode < 300)
                                                        ? Colors.green.shade800
                                                        : Colors.red.shade800,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                            ],
                                            if (latency != null)
                                              Text(
                                                '${latency}ms',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (extractedVars.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Extracted: ${extractedVars.entries.map((e) => "${e.key}=${e.value}").join(", ")}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                        if (assertions.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          ...assertions.map((a) {
                                            final aMap =
                                                a as Map<String, dynamic>;
                                            final passed = aMap['passed'] == true;
                                            return Row(
                                              children: [
                                                Icon(
                                                  passed
                                                      ? Icons.done
                                                      : Icons.close,
                                                  size: 14,
                                                  color: passed
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  aMap['assertionName'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: passed
                                                      ? Colors.green.shade800
                                                      : Colors.red.shade800,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ],
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    } else {
      // Standard flow steps
      final result =
          widget.testRun.metadata['result'] as Map<String, dynamic>?;
      final steps = (result?['stepResults'] as List?) ?? [];

      if (steps.isEmpty) {
        return const Center(
          child: Text('No step execution records available.'),
        );
      }

      return ListView.builder(
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final s = steps[index] as Map<String, dynamic>;
          final stepName = s['stepName'] ?? 'Step ${index + 1}';
          final success = s['success'] == true;
          final resp = s['response'] as Map<String, dynamic>?;
          final statusCode = resp?['statusCode'] ?? s['statusCode'];
          final latency = resp?['responseTimeMs'] ?? s['durationMs'];
          final error = s['errorMessage'];
          final assertions = (s['assertionResults'] as List?) ?? [];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
              ),
              title: Text(
                stepName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (statusCode != null) ...[
                        Text('Status: $statusCode'),
                        const SizedBox(width: 12),
                      ],
                      if (latency != null) Text('Latency: ${latency}ms'),
                    ],
                  ),
                  if (error != null)
                    Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  if (assertions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ...assertions.map((a) {
                      final aMap = a as Map<String, dynamic>;
                      final passed = aMap['passed'] == true;
                      return Text(
                        '${passed ? "✓" : "✗"} ${aMap["assertionName"] ?? ""}',
                        style: TextStyle(
                          fontSize: 11,
                          color: passed ? Colors.green : Colors.red,
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildRawJsonTab(ThemeData theme) {
    final encoder = const JsonEncoder.withIndent('  ');
    final jsonStr = encoder.convert(widget.testRun.toJson());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: _copyJson,
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy JSON'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                jsonStr,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFFE2E8F0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
