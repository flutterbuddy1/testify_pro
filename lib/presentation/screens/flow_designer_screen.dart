import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/flow.dart' as entities;
import '../../domain/entities/flow_step.dart';
import '../../domain/entities/api_request.dart';
import '../../infrastructure/flow_engine/flow_executor.dart';
import '../../data/services/http_service.dart';
import '../../core/providers/global_providers.dart';
import '../widgets/desktop_splitter.dart';
import '../dialogs/flow_json_dialog.dart';
import '../dialogs/data_runner_dialog.dart';

class FlowDesignerScreen extends ConsumerStatefulWidget {
  const FlowDesignerScreen({super.key});

  @override
  ConsumerState<FlowDesignerScreen> createState() => _FlowDesignerScreenState();
}

class _FlowDesignerScreenState extends ConsumerState<FlowDesignerScreen> {
  final _uuid = const Uuid();
  entities.Flow? _selectedFlow;
  int? _expandedStepIndex;

  // Execution state
  bool _isExecuting = false;
  final List<ConsoleLogEntry> _consoleLogs = [];
  final ScrollController _consoleScrollController = ScrollController();
  // Console state
  double _consoleHeight = 250;
  double _sidebarWidth = 260.0;
  bool _isSidebarCollapsed = false;

  Future<void> _createNewFlow() async {
    final newFlow = entities.Flow(
      id: _uuid.v4(),
      name: 'New Flow',
      description: 'API testing scenario',
      steps: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(flowRepositoryProvider).saveFlow(newFlow);
    if (mounted) {
      setState(() {
        _selectedFlow = newFlow;
        _expandedStepIndex = null;
      });
    }
  }

  void _log(String message, {LogType type = LogType.info, String? details}) {
    if (!mounted) return;
    setState(() {
      _consoleLogs.add(
        ConsoleLogEntry(
          timestamp: DateTime.now(),
          message: message,
          type: type,
          details: details,
        ),
      );
    });
    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_consoleScrollController.hasClients) {
        _consoleScrollController.animateTo(
          _consoleScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _runFlow() async {
    if (_selectedFlow == null || _selectedFlow!.steps.isEmpty) return;

    setState(() {
      _isExecuting = true;
      _consoleLogs.clear();
    });

    _log(
      '🚀 Starting flow execution: ${_selectedFlow!.name}',
      type: LogType.system,
    );

    try {
      final repo = ref.read(testRunRepositoryProvider);
      final executor = FlowExecutor(HttpService(), repository: repo);

      final result = await executor.executeWithTracking(
        _selectedFlow!,
        onStepComplete: (stepResult) {
          final method =
              stepResult.request?.method
                  .toString()
                  .split('.')
                  .last
                  .toUpperCase() ??
              'REQ';
          final status = stepResult.response?.statusCode ?? 0;
          final duration = stepResult.response?.responseTimeMs ?? 0;

          if (stepResult.success) {
            _log(
              'Step ${stepResult.stepIndex + 1}: ${stepResult.stepName} ($method $status) - ${duration}ms',
              type: LogType.success,
              details: _formatResponseDetails(stepResult),
            );
          } else {
            _log(
              'Step ${stepResult.stepIndex + 1}: ${stepResult.stepName} ($method $status) - Failed',
              type: LogType.error,
              details:
                  'Error: ${stepResult.errorMessage}\n\n${_formatResponseDetails(stepResult)}',
            );
          }
        },
      );

      if (mounted) {
        setState(() => _isExecuting = false);
        if (result.success) {
          _log('🏁 Flow completed successfully!', type: LogType.system);
        } else {
          _log(
            '🏁 Flow failed after step ${result.stepResults.length}.\nReason: ${result.errorMessage}',
            type: LogType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExecuting = false);
        _log('🛑 Execution error: $e', type: LogType.error);
      }
    }
  }

  String _formatResponseDetails(dynamic result) {
    final response = result.response;
    if (response == null) return 'No response received';

    final buffer = StringBuffer();
    buffer.writeln('URL: ${result.request?.url}');
    buffer.writeln(
      'Method: ${result.request?.method.toString().split('.').last.toUpperCase()}',
    );
    buffer.writeln('Status: ${response.statusCode} ${response.statusMessage}');
    buffer.writeln('Time: ${response.responseTimeMs}ms');
    buffer.writeln('Size: ${response.sizeBytes} bytes');
    buffer.writeln('\n--- Headers (${response.headers.length}) ---');
    if (response.headers.isEmpty) {
      buffer.writeln('(None)');
    } else {
      (response.headers as Map).forEach((k, v) => buffer.writeln('$k: $v'));
    }
    buffer.writeln('\n--- Body ---');
    buffer.write(response.body);
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final flowsAsync = ref.watch(flowsProvider);

    return Scaffold(
      body: flowsAsync.when(
        data: (flows) => Row(
          children: [
            // Left Sidebar: Flows List (Collapsible and Resizable)
            if (!_isSidebarCollapsed) ...[
              SizedBox(
                width: _sidebarWidth,
                child: _buildSidebar(flows),
              ),
              DesktopVerticalSplitter(
                onDrag: (dx) {
                  setState(() {
                    _sidebarWidth = (_sidebarWidth + dx).clamp(180.0, 500.0);
                  });
                },
                onDoubleTap: () => setState(() => _isSidebarCollapsed = true),
              ),
            ] else ...[
              Container(
                width: 42,
                color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    IconButton(
                      icon: const Icon(Icons.account_tree, size: 20),
                      tooltip: 'Expand Flows Sidebar',
                      onPressed: () =>
                          setState(() => _isSidebarCollapsed = false),
                    ),
                    IconButton(
                      icon: const Icon(Icons.upload_file, size: 18),
                      tooltip: 'Import Flow from JSON',
                      onPressed: _showImportDialog,
                    ),
                    const SizedBox(height: 8),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'Flows (${flows.length})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
            ],
            // Right Plane: Editor + Console
            Expanded(
              child: _selectedFlow == null
                  ? _buildEmptyState()
                  : _buildMainEditor(),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSidebar(List<entities.Flow> flows) {
    return Container(
      color: Theme.of(context).cardColor.withValues(alpha: 0.5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _createNewFlow,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Flow'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.upload_file, size: 18),
                  tooltip: 'Import Flow from JSON',
                  onPressed: _showImportDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  tooltip: 'Collapse sidebar',
                  onPressed: () => setState(() => _isSidebarCollapsed = true),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: flows.length,
              itemBuilder: (context, index) {
                final flow = flows[index];
                final isSelected = flow.id == _selectedFlow?.id;
                return GestureDetector(
                  onSecondaryTapDown: (details) => _showFlowContextMenu(
                    context,
                    details.globalPosition,
                    flow,
                  ),
                  child: ListTile(
                    selected: isSelected,
                    leading: const Icon(Icons.account_tree_outlined),
                    title: Text(
                      flow.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('${flow.steps.length} steps'),
                    onTap: () => setState(() {
                      _selectedFlow = flow;
                      _expandedStepIndex = null;
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Select or create a flow to begin',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMainEditor() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Editor Toolbar
          _buildToolbar(),
          const TabBar(
            tabs: [
              Tab(text: 'Steps', icon: Icon(Icons.list, size: 18)),
              Tab(text: 'Variables', icon: Icon(Icons.vibration, size: 18)),
            ],
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 1),
          // Tab Views
          Expanded(
            child: TabBarView(
              children: [_buildStepsList(), _buildVariablesEditor()],
            ),
          ),
          const Divider(height: 1),
          // Execution Console
          _buildConsole(),
        ],
      ),
    );
  }

  Widget _buildVariablesEditor() {
    return _selectedFlow == null
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flow Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _selectedFlow!.description,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Describe what this flow tests...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    final updated = _selectedFlow!.copyWith(
                      description: v,
                      updatedAt: DateTime.now(),
                    );
                    _saveFlow(updated);
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Global Variables',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Text(
                  'Variables defined here are available in all steps using {{var_name}} syntax.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildKVEditor(
                    _selectedFlow!.variables.entries.toList(),
                    'Variable',
                    onUpdate: (vars) {
                      final updated = _selectedFlow!.copyWith(
                        variables: Map.fromEntries(vars),
                        updatedAt: DateTime.now(),
                      );
                      _saveFlow(updated);
                    },
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildKVEditor(
    List<MapEntry<String, String>> list,
    String label, {
    required ValueChanged<List<MapEntry<String, String>>> onUpdate,
  }) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: list.length + 1,
            itemBuilder: (context, idx) {
              if (idx == list.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      final newList = [...list, const MapEntry('', '')];
                      onUpdate(newList);
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text('Add $label'),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: list[idx].key,
                        decoration: const InputDecoration(
                          hintText: 'Key',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          final newList = List<MapEntry<String, String>>.from(
                            list,
                          );
                          newList[idx] = MapEntry(v, list[idx].value);
                          onUpdate(newList);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: list[idx].value,
                        decoration: const InputDecoration(
                          hintText: 'Value',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          final newList = List<MapEntry<String, String>>.from(
                            list,
                          );
                          newList[idx] = MapEntry(list[idx].key, v);
                          onUpdate(newList);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        final newList = List<MapEntry<String, String>>.from(
                          list,
                        );
                        newList.removeAt(idx);
                        onUpdate(newList);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.account_tree, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              key: ValueKey('title_${_selectedFlow!.id}'),
              initialValue: _selectedFlow!.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Flow Name',
              ),
              onFieldSubmitted: (val) {
                if (val.isNotEmpty) {
                  final updated = _selectedFlow!.copyWith(
                    name: val,
                    updatedAt: DateTime.now(),
                  );
                  _saveFlow(updated);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, size: 20),
            tooltip: 'Export Flow to JSON',
            onPressed: () => FlowJsonExportDialog.show(context, _selectedFlow!),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, size: 18),
            tooltip: 'Flow JSON Specification Guide',
            onPressed: () => FlowJsonHelpDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.dataset_outlined, size: 20, color: Colors.blue),
            tooltip: 'Run with Data File (CSV / JSON)',
            onPressed: _isExecuting ? null : () => DataRunnerDialog.show(context, _selectedFlow!),
          ),
          IconButton(
            icon: Icon(
              _isExecuting ? Icons.stop : Icons.play_arrow,
              color: _isExecuting ? Colors.red : Colors.green,
            ),
            onPressed: _isExecuting ? null : _runFlow,
            tooltip: 'Run Flow',
          ),
          const SizedBox(width: 8),
          const Text(
            'Saved',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.check_circle_outline, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedFlow!.steps.length + 1,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        if (oldIndex >= _selectedFlow!.steps.length ||
            newIndex >= _selectedFlow!.steps.length)
          return;

        final steps = List<FlowStep>.from(_selectedFlow!.steps);
        final step = steps.removeAt(oldIndex);
        steps.insert(newIndex, step);
        _saveFlow(_selectedFlow!.copyWith(steps: steps));
      },
      itemBuilder: (context, index) {
        if (index == _selectedFlow!.steps.length) {
          return Center(
            key: const ValueKey('add_step_button'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: OutlinedButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add),
                label: const Text('Add New Step'),
              ),
            ),
          );
        }

        final step = _selectedFlow!.steps[index];
        final isExpanded = _expandedStepIndex == index;

        return _StepCard(
          key: ValueKey(step.id),
          index: index,
          step: step,
          isExpanded: isExpanded,
          onToggle: () =>
              setState(() => _expandedStepIndex = isExpanded ? null : index),
          onDelete: () => _deleteStep(index),
          onUpdate: (updated) => _updateStep(index, updated),
        );
      },
    );
  }

  Widget _buildConsole() {
    return Column(
      children: [
        // Horizontal Desktop Splitter with Drag Handle
        DesktopHorizontalSplitter(
          height: 10,
          onDrag: (dy) {
            setState(() {
              _consoleHeight = (_consoleHeight - dy).clamp(60.0, 600.0);
            });
          },
          onDoubleTap: () {
            setState(() {
              _consoleHeight = _consoleHeight > 300 ? 150.0 : 400.0;
            });
          },
        ),
        // Console Area
        Container(
          height: _consoleHeight,
          color: const Color(0xFF1E1E1E), // Terminal-like background
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Toolbar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF2D2D2D),
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EXECUTION CONSOLE',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      children: [
                        if (_isExecuting)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                              ),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.clear_all,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _consoleLogs.clear()),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Clear Console',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Logs List
              Expanded(
                child: ListView.builder(
                  controller: _consoleScrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: _consoleLogs.length,
                  itemBuilder: (context, index) {
                    final log = _consoleLogs[index];
                    Color color = Colors.white;
                    switch (log.type) {
                      case LogType.success:
                        color = Colors.greenAccent;
                        break;
                      case LogType.error:
                        color = Colors.redAccent;
                        break;
                      case LogType.system:
                        color = Colors.blueAccent;
                        break;
                      case LogType.info:
                        color = Colors.white70;
                        break;
                    }

                    return InkWell(
                      onTap: log.details != null
                          ? () => _showLogDetails(log)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('HH:mm:ss').format(log.timestamp),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                log.message,
                                style: TextStyle(
                                  color: color,
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogDetails(ConsoleLogEntry log) {
    if (log.details == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step Details',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.grey),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    log.details!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.greenAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addStep() {
    final newStep = FlowStep(
      id: _uuid.v4(),
      name: 'Step ${_selectedFlow!.steps.length + 1}',
      request: ApiRequest(
        id: _uuid.v4(),
        name: 'Request',
        url: 'https://api.example.com',
        method: HttpMethod.get,
      ),
    );
    final updated = _selectedFlow!.copyWith(
      steps: [..._selectedFlow!.steps, newStep],
      updatedAt: DateTime.now(),
    );
    _saveFlow(updated);
    setState(() => _expandedStepIndex = updated.steps.length - 1);
  }

  void _updateStep(int index, FlowStep updatedStep) {
    final steps = List<FlowStep>.from(_selectedFlow!.steps);
    steps[index] = updatedStep;
    _saveFlow(_selectedFlow!.copyWith(steps: steps));
  }

  void _deleteStep(int index) {
    final steps = List<FlowStep>.from(_selectedFlow!.steps);
    steps.removeAt(index);
    _saveFlow(_selectedFlow!.copyWith(steps: steps));
    if (_expandedStepIndex == index) {
      setState(() => _expandedStepIndex = null);
    }
  }

  Future<void> _saveFlow(entities.Flow flow) async {
    setState(() => _selectedFlow = flow);
    await ref.read(flowRepositoryProvider).saveFlow(flow);
  }

  void _showFlowContextMenu(
    BuildContext context,
    Offset position,
    entities.Flow flow,
  ) {
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
          onTap: () => FlowJsonExportDialog.show(context, flow),
          child: const Row(
            children: [
              Icon(Icons.file_download_outlined, size: 18),
              SizedBox(width: 12),
              Text('Export JSON'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => _renameFlow(flow),
          child: const Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 12),
              Text('Rename'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => _deleteFlow(flow),
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

  Future<void> _renameFlow(entities.Flow flow) async {
    final controller = TextEditingController(text: flow.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Flow'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final updated = flow.copyWith(name: newName, updatedAt: DateTime.now());
      await ref.read(flowRepositoryProvider).saveFlow(updated);
    }
  }

  Future<void> _deleteFlow(entities.Flow flow) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flow'),
        content: Text('Are you sure you want to delete "${flow.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(flowRepositoryProvider).deleteFlow(flow.id);
      if (_selectedFlow?.id == flow.id) {
        setState(() {
          _selectedFlow = null;
          _expandedStepIndex = null;
        });
      }
    }
  }

  Future<void> _showImportDialog() async {
    final result = await FlowJsonImportDialog.show(context);
    if (result != null) {
      await _saveFlow(result.flow);
      setState(() {
        _selectedFlow = result.flow;
        _expandedStepIndex = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Flow "${result.flow.name}" imported successfully!')),
        );
      }
      if (result.runImmediately) {
        _runFlow();
      }
    }
  }
}

class _StepCard extends StatelessWidget {
  final int index;
  final FlowStep step;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ValueChanged<FlowStep> onUpdate;

  const _StepCard({
    super.key,
    required this.index,
    required this.step,
    required this.isExpanded,
    required this.onToggle,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: isExpanded ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isExpanded ? colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onToggle,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: colorScheme.surfaceVariant,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            title: Text(
              step.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: !isExpanded
                ? Text(
                    '${step.request.method.toString().split('.').last.toUpperCase()} ${step.request.url}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _StepInlineEditor(step: step, onUpdate: onUpdate),
            ),
        ],
      ),
    );
  }
}

class _StepInlineEditor extends StatefulWidget {
  final FlowStep step;
  final ValueChanged<FlowStep> onUpdate;

  const _StepInlineEditor({required this.step, required this.onUpdate});

  @override
  State<_StepInlineEditor> createState() => _StepInlineEditorState();
}

class _StepInlineEditorState extends State<_StepInlineEditor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _bodyController;

  final List<MapEntry<String, String>> _headers = [];
  final List<MapEntry<String, String>> _queryParams = [];
  final List<MapEntry<String, String>> _extractors = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initFields();
  }

  void _initFields() {
    _nameController = TextEditingController(text: widget.step.name);
    _urlController = TextEditingController(text: widget.step.request.url);
    _bodyController = TextEditingController(
      text: widget.step.request.body ?? '',
    );

    _headers.clear();
    _headers.addAll(widget.step.request.headers.entries);

    _queryParams.clear();
    _queryParams.addAll(widget.step.request.queryParams.entries);

    _extractors.clear();
    _extractors.addAll(widget.step.extractors.entries);
  }

  void _notifyChange() {
    final updated = widget.step.copyWith(
      name: _nameController.text,
      request: widget.step.request.copyWith(
        url: _urlController.text,
        headers: Map.fromEntries(_headers.where((e) => e.key.isNotEmpty)),
        queryParams: Map.fromEntries(
          _queryParams.where((e) => e.key.isNotEmpty),
        ),
        body: _bodyController.text.isEmpty ? null : _bodyController.text,
      ),
      extractors: Map.fromEntries(_extractors.where((e) => e.key.isNotEmpty)),
    );
    widget.onUpdate(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Step Name',
                  isDense: true,
                ),
                onChanged: (_) => _notifyChange(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<HttpMethod>(
                value: widget.step.request.method,
                decoration: const InputDecoration(
                  labelText: 'Method',
                  isDense: true,
                ),
                items: HttpMethod.values
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    widget.onUpdate(
                      widget.step.copyWith(
                        request: widget.step.request.copyWith(method: v),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _urlController,
          decoration: const InputDecoration(labelText: 'URL', isDense: true),
          onChanged: (_) => _notifyChange(),
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Params'),
            Tab(text: 'Headers'),
            Tab(text: 'Body'),
            Tab(text: 'Extractors'),
            Tab(text: 'Assertions'),
            Tab(text: 'Settings'),
          ],
        ),
        SizedBox(
          height: 250,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildKVEditor(_queryParams, 'Param'),
              _buildKVEditor(_headers, 'Header'),
              _buildBodyEditor(),
              _buildKVEditor(
                _extractors,
                'Extractor',
                keyHint: 'Var Name',
                valueHint: 'JSONPath (\$.path)',
              ),
              _buildAssertionsEditor(),
              _buildSettingsEditor(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKVEditor(
    List<MapEntry<String, String>> list,
    String label, {
    String keyHint = 'Key',
    String valueHint = 'Value',
  }) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: list.length + 1,
            itemBuilder: (context, idx) {
              if (idx == list.length) {
                return TextButton.icon(
                  onPressed: () {
                    setState(() => list.add(const MapEntry('', '')));
                    _notifyChange();
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: Text('Add $label'),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: list[idx].key,
                        decoration: InputDecoration(
                          hintText: keyHint,
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          list[idx] = MapEntry(v, list[idx].value);
                          _notifyChange();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: list[idx].value,
                        decoration: InputDecoration(
                          hintText: valueHint,
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          list[idx] = MapEntry(list[idx].key, v);
                          _notifyChange();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() => list.removeAt(idx));
                        _notifyChange();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBodyEditor() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        controller: _bodyController,
        maxLines: 10,
        decoration: const InputDecoration(
          hintText: 'JSON Body',
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => _notifyChange(),
      ),
    );
  }

  Widget _buildAssertionsEditor() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.step.assertions.length + 1,
            itemBuilder: (context, idx) {
              if (idx == widget.step.assertions.length) {
                return TextButton.icon(
                  onPressed: () {
                    final updated = widget.step.copyWith(
                      assertions: [
                        ...widget.step.assertions,
                        const Assertion(
                          name: 'New',
                          type: AssertionType.statusCode,
                          expected: '200',
                        ),
                      ],
                    );
                    widget.onUpdate(updated);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Assertion'),
                );
              }
              final assrt = widget.step.assertions[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<AssertionType>(
                        value: assrt.type,
                        isExpanded: true,
                        items: AssertionType.values
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            final list = List<Assertion>.from(
                              widget.step.assertions,
                            );
                            list[idx] = assrt.copyWith(type: v);
                            widget.onUpdate(
                              widget.step.copyWith(assertions: list),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: assrt.expected,
                        decoration: const InputDecoration(
                          hintText: 'Expected',
                          isDense: true,
                        ),
                        onChanged: (v) {
                          final list = List<Assertion>.from(
                            widget.step.assertions,
                          );
                          list[idx] = assrt.copyWith(expected: v);
                          widget.onUpdate(
                            widget.step.copyWith(assertions: list),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        final list = List<Assertion>.from(
                          widget.step.assertions,
                        );
                        list.removeAt(idx);
                        widget.onUpdate(widget.step.copyWith(assertions: list));
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsEditor() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: Text('Stop Flow on Failure')),
              Switch(
                value: widget.step.stopOnFailure,
                onChanged: (v) {
                  widget.onUpdate(widget.step.copyWith(stopOnFailure: v));
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Text('Step Enabled')),
              Switch(
                value: widget.step.enabled,
                onChanged: (v) {
                  widget.onUpdate(widget.step.copyWith(enabled: v));
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: widget.step.thinkTimeMs.toString(),
            decoration: const InputDecoration(
              labelText: 'Think Time (ms)',
              hintText: 'Delay before next step',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final ms = int.tryParse(v) ?? 0;
              widget.onUpdate(widget.step.copyWith(thinkTimeMs: ms));
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _urlController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}

enum LogType { info, success, error, system }

class ConsoleLogEntry {
  final DateTime timestamp;
  final String message;
  final LogType type;
  final String? details;

  ConsoleLogEntry({
    required this.timestamp,
    required this.message,
    required this.type,
    this.details,
  });
}
