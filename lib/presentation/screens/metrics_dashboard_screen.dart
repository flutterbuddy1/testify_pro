import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/global_providers.dart';
import '../../domain/entities/api_response.dart';
import '../../domain/entities/test_metrics.dart';

// Provider for metrics state (Watching the live stream from coordinator)
final metricsProvider = StreamProvider<TestMetrics>((ref) {
  final coordinator = ref.watch(loadCoordinatorProvider);
  return coordinator.metricsStream;
});

class MetricsDashboardScreen extends ConsumerWidget {
  final TestMetrics? historicalMetrics;
  final List<ApiResponse>? historicalLogs;
  final String? title;

  const MetricsDashboardScreen({
    super.key,
    this.historicalMetrics,
    this.historicalLogs,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If historical data is provided, show it directly with tabs for metrics and logs
    if (historicalMetrics != null) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title ?? 'Test Results'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.analytics), text: 'Metrics'),
                Tab(icon: Icon(Icons.list), text: 'Logs'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildDashboard(context, historicalMetrics!, isLive: false),
              _buildLogsList(context, historicalLogs ?? []),
            ],
          ),
        ),
      );
    }

    final metricsAsync = ref.watch(metricsProvider);
    final coordinator = ref.watch(loadCoordinatorProvider);

    return metricsAsync.when(
      data: (metrics) => _buildDashboard(context, metrics, isLive: true),
      loading: () {
        if (coordinator.isRunning &&
            coordinator.currentMetrics.totalRequests > 0) {
          return _buildDashboard(
            context,
            coordinator.currentMetrics,
            isLive: true,
          );
        }
        return _EmptyState(isInitialLoading: coordinator.isRunning);
      },
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    TestMetrics metrics, {
    required bool isLive,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (only for live, history has it in AppBar)
          if (isLive) ...[
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metrics Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Real-time performance metrics',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          // KPI Cards
          _KPICards(metrics: metrics),
          const SizedBox(height: 24),

          // RPS Chart
          _ChartCard(
            title: 'Requests Per Second (RPS)',
            icon: Icons.speed,
            color: Colors.purple,
            child: _RPSChart(dataPoints: metrics.rpsHistory),
          ),
          const SizedBox(height: 16),

          // Response Time Chart
          _ChartCard(
            title: 'Response Time (ms)',
            icon: Icons.timer,
            color: Colors.orange,
            child: _ResponseTimeChart(dataPoints: metrics.responseTimeHistory),
          ),
          const SizedBox(height: 16),

          // Error Rate Chart
          _ChartCard(
            title: 'Error Rate (%)',
            icon: Icons.error,
            color: Colors.red,
            child: _ErrorRateChart(dataPoints: metrics.errorRateHistory),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(BuildContext context, List<ApiResponse> logs) {
    if (logs.isEmpty) {
      return const Center(child: Text('No logs available for this test run.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final log = logs[index];
        final isSuccess = log.isSuccess;
        final timestamp = log.timestamp;

        return ListTile(
          leading: Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
          ),
          title: Text(
            'HTTP ${log.statusCode} - ${log.responseTimeMs}ms',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            log.body.length > 200
                ? '${log.body.substring(0, 200)}...'
                : log.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Response ${log.statusCode}'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('URL: ${_getUrl(log) ?? "N/A"}'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Headers (${log.headers.length}):',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (log.headers.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                final text = log.headers.entries
                                    .map((e) => '${e.key}: ${e.value}')
                                    .join('\n');
                                Clipboard.setData(ClipboardData(text: text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Headers copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 14),
                              label: const Text('Copy Headers', style: TextStyle(fontSize: 11)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 180),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: log.headers.isEmpty
                            ? const Text('No headers received', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: log.headers.entries
                                      .map(
                                        (e) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: SelectableText.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '${e.key}: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${e.value}',
                                                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Body:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (log.body.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: log.body));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Body copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 14),
                              label: const Text('Copy Body', style: TextStyle(fontSize: 11)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 220),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            log.body.isEmpty ? '(Empty body)' : log.body,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String? _getUrl(ApiResponse response) {
    // Current ApiResponse doesn't store URL, but we could add it to metadata if needed.
    return null;
  }
}

class _EmptyState extends StatelessWidget {
  final bool isInitialLoading;

  const _EmptyState({this.isInitialLoading = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isInitialLoading)
            const CircularProgressIndicator()
          else ...[
            Icon(
              Icons.analytics_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No active load test',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a load test to see live metrics and charts',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}

class _KPICards extends StatelessWidget {
  final TestMetrics metrics;

  const _KPICards({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2,
      children: [
        _KPICard(
          label: 'Total Requests',
          value: metrics.totalRequests.toString(),
          icon: Icons.cloud_done,
          color: Colors.blue,
        ),
        _KPICard(
          label: 'Success Rate',
          value: metrics.successRatePercentage,
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _KPICard(
          label: 'Avg Response',
          value: '${metrics.avgResponseTimeMs.toStringAsFixed(0)}ms',
          icon: Icons.timer,
          color: Colors.orange,
        ),
        _KPICard(
          label: 'P95 Latency',
          value: '${metrics.p95ResponseTimeMs.toStringAsFixed(0)}ms',
          icon: Icons.trending_up,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KPICard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(height: 200, child: child),
          ],
        ),
      ),
    );
  }
}

class _RPSChart extends StatelessWidget {
  final List<DataPoint> dataPoints;

  const _RPSChart({required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const Center(child: Text('No data yet'));
    }

    final spots = dataPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 10,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 10 == 0) {
                  return Text(
                    '${value.toInt()}s',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseTimeChart extends StatelessWidget {
  final List<DataPoint> dataPoints;

  const _ResponseTimeChart({required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const Center(child: Text('No data yet'));
    }

    final spots = dataPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 10 == 0) {
                  return Text(
                    '${value.toInt()}s',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}ms',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorRateChart extends StatelessWidget {
  final List<DataPoint> dataPoints;

  const _ErrorRateChart({required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const Center(child: Text('No data yet'));
    }

    final spots = dataPoints.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.value * 100,
      ); // Convert to percentage
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 10 == 0) {
                  return Text(
                    '${value.toInt()}s',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
