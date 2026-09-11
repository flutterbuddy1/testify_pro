import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/api_request.dart';
import '../../domain/entities/api_response.dart';
import '../../domain/entities/flow.dart' as entities;
import '../../domain/entities/load_test_config.dart';
import '../../domain/entities/test_metrics.dart';
import '../../domain/entities/test_run.dart';
import '../../core/providers/global_providers.dart';
import '../../infrastructure/load_engine/load_coordinator.dart';

class LoadTestScreen extends ConsumerStatefulWidget {
  const LoadTestScreen({super.key});

  @override
  ConsumerState<LoadTestScreen> createState() => _LoadTestScreenState();
}

class _LoadTestScreenState extends ConsumerState<LoadTestScreen> {
  final _uuid = const Uuid();
  final _urlController = TextEditingController(
    text: 'https://jsonplaceholder.typicode.com/posts/1',
  );

  int _virtualUsers = 100;
  int _durationSeconds = 30;
  int _rampUpSeconds = 5;

  TargetType _targetType = TargetType.request;
  String? _selectedFlowId;

  TestMetrics? _currentMetrics;
  bool _isRunning = false;
  StreamSubscription<TestMetrics>? _metricsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final coordinator = ref.read(loadCoordinatorProvider);
      if (coordinator.isRunning) {
        _hookIntoCoordinator(coordinator);
      }
    });
  }

  void _hookIntoCoordinator(LoadCoordinator coordinator) {
    _metricsSubscription?.cancel();

    setState(() {
      _isRunning = true;
      _currentMetrics = coordinator.currentMetrics;
    });

    _metricsSubscription = coordinator.metricsStream.listen(
      (metrics) {
        if (mounted) {
          setState(() {
            _currentMetrics = metrics;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Load Test Error: $e')));
          setState(() {
            _isRunning = false;
          });
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isRunning = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _metricsSubscription?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _startLoadTest() async {
    final config = LoadTestConfig(
      id: _uuid.v4(),
      name: 'Load Test',
      targetId: _targetType == TargetType.request
          ? 'test-request'
          : (_selectedFlowId ?? ''),
      targetType: _targetType,
      virtualUsers: _virtualUsers,
      durationSeconds: _durationSeconds,
      rampUpSeconds: _rampUpSeconds,
      createdAt: DateTime.now(),
    );

    ApiRequest? request;
    entities.Flow? flow;

    if (_targetType == TargetType.request) {
      request = ApiRequest(
        id: 'test-request',
        name: 'Test Request',
        url: _urlController.text,
        method: HttpMethod.get,
      );
    } else {
      final flowsAsync = ref.read(flowsProvider);
      flow = flowsAsync.whenOrNull(
        data: (flows) =>
            flows.where((f) => f.id == _selectedFlowId).firstOrNull,
      );
    }

    final coordinator = ref.read(loadCoordinatorProvider);

    final testRun = TestRun(
      id: config.id,
      name:
          '${_targetType == TargetType.request ? "URL" : "Flow"} Load Test - ${config.virtualUsers} users',
      type: TestType.load,
      status: TestStatus.running,
      startTime: DateTime.now(),
      config: config.toJson(),
    );

    await ref.read(testRunRepositoryProvider).saveTestRun(testRun);

    setState(() {
      _isRunning = true;
    });

    try {
      await coordinator.start(
        config,
        request: request,
        flow: flow,
        testRunId: config.id,
        repository: ref.read(testRunRepositoryProvider),
      );
      _hookIntoCoordinator(coordinator);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  Future<void> _stopLoadTest() async {
    final coordinator = ref.read(loadCoordinatorProvider);
    if (_isRunning) {
      await coordinator.stop();
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Load Testing'),
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Configuration'),
              Tab(text: 'Results & Logs'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildConfigTab(), _buildResultsTab()]),
      ),
    );
  }

  Widget _buildConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Load Testing',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Simulate thousands of concurrent users',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Configuration',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Target Type',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<TargetType>(
                    segments: const [
                      ButtonSegment(
                        value: TargetType.request,
                        label: Text('Single URL'),
                        icon: Icon(Icons.link),
                      ),
                      ButtonSegment(
                        value: TargetType.flow,
                        label: Text('API Flow'),
                        icon: Icon(Icons.alt_route),
                      ),
                    ],
                    selected: {_targetType},
                    onSelectionChanged: _isRunning
                        ? null
                        : (Set<TargetType> newSelection) {
                            setState(() {
                              _targetType = newSelection.first;
                            });
                          },
                  ),
                  const SizedBox(height: 24),
                  if (_targetType == TargetType.request)
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'Target URL',
                        hintText: 'https://api.example.com/endpoint',
                        prefixIcon: Icon(Icons.link),
                      ),
                      enabled: !_isRunning,
                    )
                  else
                    Consumer(
                      builder: (context, ref, child) {
                        final flowsAsync = ref.watch(flowsProvider);

                        return flowsAsync.when(
                          data: (flows) {
                            if (flows.isEmpty) {
                              return const Text(
                                'No flows available. Create one in Flow Designer first.',
                                style: TextStyle(color: Colors.red),
                              );
                            }
                            if (_selectedFlowId == null ||
                                !flows.any((f) => f.id == _selectedFlowId)) {
                              _selectedFlowId = flows.isNotEmpty
                                  ? flows.first.id
                                  : null;
                            }
                            return DropdownButtonFormField<String>(
                              value: _selectedFlowId,
                              decoration: const InputDecoration(
                                labelText: 'Select Flow',
                                prefixIcon: Icon(Icons.alt_route),
                              ),
                              items: flows
                                  .map(
                                    (f) => DropdownMenuItem(
                                      value: f.id,
                                      child: Text(f.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _isRunning
                                  ? null
                                  : (value) =>
                                        setState(() => _selectedFlowId = value),
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (err, _) => Text(
                            'Error loading flows: $err',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  _ConfigSlider(
                    label: 'Virtual Users',
                    value: _virtualUsers,
                    min: 1,
                    max: 1000,
                    divisions: 100,
                    icon: Icons.people,
                    enabled: !_isRunning,
                    onChanged: (value) {
                      setState(() => _virtualUsers = value.toInt());
                    },
                  ),
                  _ConfigSlider(
                    label: 'Duration (seconds)',
                    value: _durationSeconds,
                    min: 10,
                    max: 300,
                    divisions: 29,
                    icon: Icons.timer,
                    enabled: !_isRunning,
                    onChanged: (value) {
                      setState(() => _durationSeconds = value.toInt());
                    },
                  ),
                  _ConfigSlider(
                    label: 'Ramp-up (seconds)',
                    value: _rampUpSeconds,
                    min: 0,
                    max: 60,
                    divisions: 12,
                    icon: Icons.trending_up,
                    enabled: !_isRunning,
                    onChanged: (value) {
                      setState(() => _rampUpSeconds = value.toInt());
                    },
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 480;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isRunning ? null : _startLoadTest,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Load Test'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: _isRunning ? _stopLoadTest : null,
                              icon: const Icon(Icons.stop),
                              label: const Text('Stop Test'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isRunning ? null : _startLoadTest,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Load Test'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isRunning ? _stopLoadTest : null,
                              icon: const Icon(Icons.stop),
                              label: const Text('Stop Test'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_currentMetrics != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Live Metrics',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        if (_isRunning)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Running',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 32),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final cols = width > 750 ? 3 : (width > 460 ? 2 : 1);
                        final ratio = width > 750 ? 2.2 : (width > 460 ? 2.2 : 3.0);
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: cols,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: ratio,
                          children: [
                            _MetricCard(
                              label: 'Total Requests',
                              value: '${_currentMetrics!.totalRequests}',
                              icon: Icons.cloud_done,
                              color: Colors.blue,
                            ),
                            _MetricCard(
                              label: 'Success Rate',
                              value: _currentMetrics!.successRatePercentage,
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                            _MetricCard(
                              label: 'Error Rate',
                              value: _currentMetrics!.errorRatePercentage,
                              icon: Icons.error,
                              color: Colors.red,
                            ),
                            _MetricCard(
                              label: 'Current RPS',
                              value:
                                  _currentMetrics!.currentRps.toStringAsFixed(1),
                              icon: Icons.speed,
                              color: Colors.purple,
                            ),
                            _MetricCard(
                              label: 'Avg Response Time',
                              value:
                                  '${_currentMetrics!.avgResponseTimeMs.toStringAsFixed(0)}ms',
                              icon: Icons.timer,
                              color: Colors.orange,
                            ),
                            _MetricCard(
                              label: 'P95 Response Time',
                              value:
                                  '${_currentMetrics!.p95ResponseTimeMs.toStringAsFixed(0)}ms',
                              icon: Icons.trending_up,
                              color: Colors.teal,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    if (_currentMetrics == null && !_isRunning) {
      return const Center(
        child: Text('No active test. Start a test to see results.'),
      );
    }

    final coordinator = ref.watch(loadCoordinatorProvider);
    final logs = coordinator.recentResponses;

    return Column(
      children: [
        if (_currentMetrics != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth > 500 ? 2 : 1;
                final ratio = cols == 2 ? 2.5 : 3.2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: ratio,
                  children: [
                    _MetricCard(
                      label: 'Throughput',
                      value:
                          '${_currentMetrics!.currentRps.toStringAsFixed(1)} rps',
                      icon: Icons.speed,
                      color: Colors.purple,
                    ),
                    _MetricCard(
                      label: 'Success Rate',
                      value: _currentMetrics!.successRatePercentage,
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                );
              },
            ),
          ),
        Expanded(
          child: ListView.separated(
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
                  '${log.body.substring(0, log.body.length > 100 ? 100 : log.body.length)}${log.body.length > 100 ? "..." : ""}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ConfigSlider extends StatelessWidget {
  final String label;
  final int value;
  final double min;
  final double max;
  final int divisions;
  final IconData icon;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _ConfigSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.icon,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              '$label: $value',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          label: value.toString(),
          onChanged: enabled ? onChanged : null,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
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
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
