// History Screen - Shows all test activity
// Displays flow executions, load tests, and API requests with filtering

import 'package:flutter/material.dart';
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
  TestType? _filterType;
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
                      'View all test executions and results',
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
                DropdownButton<TestType?>(
                  value: _filterType,
                  hint: const Text('All Types'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...TestType.values.map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_getTypeLabel(type)),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _filterType = value),
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
    final stats = {
      'Total': history.length,
      'Success': history.where((r) => r.status == TestStatus.completed).length,
      'Failed': history.where((r) => r.status == TestStatus.failed).length,
    };

    return Row(
      children: stats.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              Text('${e.value}', style: Theme.of(context).textTheme.titleLarge),
              Text(e.key, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );
      }).toList(),
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
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No test history',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Run some tests to see history here',
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

    if (_filterType != null) {
      filtered = filtered.where((r) => r.type == _filterType).toList();
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
          print('Error parsing historical logs: $e');
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
      // Default detail dialog for other tests
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

  String _getTypeLabel(TestType type) {
    switch (type) {
      case TestType.api:
        return 'API Test';
      case TestType.flow:
        return 'Flow Test';
      case TestType.load:
        return 'Load Test';
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
    return GestureDetector(
      onSecondaryTapDown: (details) =>
          _showContextMenu(context, details.globalPosition),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: _buildIcon(context),
          title: Text(testRun.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatDateTime(testRun.startTime)),
              if (testRun.finalMetrics != null)
                Text(
                  '${testRun.finalMetrics!.totalRequests} requests • '
                  '${testRun.finalMetrics!.successRatePercentage} success',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusChip(context),
              const SizedBox(width: 8),
              if (testRun.finalMetrics != null)
                IconButton(
                  icon: const Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 20,
                    color: Colors.blue,
                  ),
                  onPressed: () => _exportReport(context),
                  tooltip: 'Export Report',
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
        if (testRun.finalMetrics != null)
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

  Widget _buildIcon(BuildContext context) {
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
      backgroundColor: color.withOpacity(0.2),
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
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dt);
  }
}

class _TestRunDetailsDialog extends StatelessWidget {
  final TestRun testRun;

  const _TestRunDetailsDialog({required this.testRun});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(testRun.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Type', _getTypeLabel(testRun.type)),
            _buildDetailRow('Status', _getStatusLabel(testRun.status)),
            _buildDetailRow(
              'Started',
              DateFormat('MMM dd, yyyy HH:mm:ss').format(testRun.startTime),
            ),
            if (testRun.endTime != null)
              _buildDetailRow(
                'Ended',
                DateFormat('MMM dd, yyyy HH:mm:ss').format(testRun.endTime!),
              ),
            if (testRun.finalMetrics != null) ...[
              const Divider(),
              const Text(
                'Metrics',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildDetailRow(
                'Total Requests',
                '${testRun.finalMetrics!.totalRequests}',
              ),
              _buildDetailRow(
                'Success Rate',
                testRun.finalMetrics!.successRatePercentage,
              ),
              _buildDetailRow(
                'Avg Response',
                '${testRun.finalMetrics!.avgResponseTimeMs.toStringAsFixed(0)}ms',
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  String _getTypeLabel(TestType type) {
    return type.toString().split('.').last.toUpperCase();
  }

  String _getStatusLabel(TestStatus status) {
    return status.toString().split('.').last.toUpperCase();
  }
}
