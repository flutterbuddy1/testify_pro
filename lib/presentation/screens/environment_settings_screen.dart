import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/global_providers.dart';
import '../../domain/entities/environment.dart';
import '../widgets/desktop_splitter.dart';

class EnvironmentSettingsScreen extends ConsumerStatefulWidget {
  const EnvironmentSettingsScreen({super.key});

  @override
  ConsumerState<EnvironmentSettingsScreen> createState() =>
      _EnvironmentSettingsScreenState();
}

class _EnvironmentSettingsScreenState
    extends ConsumerState<EnvironmentSettingsScreen> {
  final _uuid = const Uuid();
  Environment? _selectedEnv;
  double _sidebarWidth = 260.0;

  void _createNewEnvironment() {
    final newEnv = Environment(
      id: _uuid.v4(),
      name: 'New Environment',
      variables: {'base_url': 'https://api.example.com'},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    ref.read(environmentRepositoryProvider).saveEnvironment(newEnv);
    setState(() => _selectedEnv = newEnv);
  }

  @override
  Widget build(BuildContext context) {
    final envsAsync = ref.watch(environmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Environment Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewEnvironment,
            tooltip: 'Add Environment',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: envsAsync.when(
        data: (envs) => Row(
          children: [
            // Resizable Sidebar
            SizedBox(
              width: _sidebarWidth,
              child: ListView.builder(
                itemCount: envs.length,
                itemBuilder: (context, index) {
                  final env = envs[index];
                  return ListTile(
                    selected: _selectedEnv?.id == env.id,
                    leading: Icon(
                      Icons.language,
                      color: env.isActive ? Colors.green : null,
                    ),
                    title: Text(env.name),
                    onTap: () => setState(() => _selectedEnv = env),
                    trailing: env.isActive
                        ? const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          )
                        : null,
                  );
                },
              ),
            ),
            DesktopVerticalSplitter(
              onDrag: (dx) {
                setState(() {
                  _sidebarWidth = (_sidebarWidth + dx).clamp(180.0, 450.0);
                });
              },
            ),
            // Editor
            Expanded(
              child: _selectedEnv == null
                  ? const Center(child: Text('Select an environment to edit'))
                  : _EnvironmentEditor(
                      env: _selectedEnv!,
                      onUpdate: (updated) {
                        setState(() => _selectedEnv = updated);
                        ref
                            .read(environmentRepositoryProvider)
                            .saveEnvironment(updated);
                      },
                      onDelete: () async {
                        await ref
                            .read(environmentRepositoryProvider)
                            .deleteEnvironment(_selectedEnv!.id);
                        setState(() => _selectedEnv = null);
                      },
                      onSetActive: () async {
                        await ref
                            .read(environmentRepositoryProvider)
                            .setActive(_selectedEnv!.id);
                        setState(
                          () => _selectedEnv = _selectedEnv!.copyWith(
                            isActive: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _EnvironmentEditor extends StatefulWidget {
  final Environment env;
  final ValueChanged<Environment> onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onSetActive;

  const _EnvironmentEditor({
    required this.env,
    required this.onUpdate,
    required this.onDelete,
    required this.onSetActive,
  });

  @override
  State<_EnvironmentEditor> createState() => _EnvironmentEditorState();
}

class _EnvironmentEditorState extends State<_EnvironmentEditor> {
  late TextEditingController _nameController;
  final List<TextEditingController> _keyControllers = [];
  final List<TextEditingController> _valueControllers = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.env.name);
    _initVariables();
  }

  void _initVariables() {
    _keyControllers.forEach((c) => c.dispose());
    _valueControllers.forEach((c) => c.dispose());
    _keyControllers.clear();
    _valueControllers.clear();

    widget.env.variables.forEach((key, value) {
      _keyControllers.add(TextEditingController(text: key));
      _valueControllers.add(TextEditingController(text: value));
    });
  }

  @override
  void didUpdateWidget(_EnvironmentEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.env.id != widget.env.id) {
      _nameController.text = widget.env.name;
      _initVariables();
    }
  }

  void _addVariable() {
    setState(() {
      _keyControllers.add(TextEditingController());
      _valueControllers.add(TextEditingController());
    });
  }

  void _save() {
    final Map<String, String> variables = {};
    for (int i = 0; i < _keyControllers.length; i++) {
      final key = _keyControllers[i].text.trim();
      final value = _valueControllers[i].text.trim();
      if (key.isNotEmpty) {
        variables[key] = value;
      }
    }

    widget.onUpdate(
      widget.env.copyWith(
        name: _nameController.text.trim(),
        variables: variables,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Environment Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _save(),
                ),
              ),
              const SizedBox(width: 16),
              if (!widget.env.isActive)
                ElevatedButton.icon(
                  onPressed: widget.onSetActive,
                  icon: const Icon(Icons.bolt),
                  label: const Text('Set Active'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: widget.onDelete,
                tooltip: 'Delete Environment',
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Variables',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _addVariable,
                icon: const Icon(Icons.add),
                label: const Text('Add Variable'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _keyControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _keyControllers[index],
                          decoration: const InputDecoration(
                            hintText: 'Key',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => _save(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _valueControllers[index],
                          decoration: const InputDecoration(
                            hintText: 'Value',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => _save(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        onPressed: () {
                          setState(() {
                            _keyControllers.removeAt(index);
                            _valueControllers.removeAt(index);
                            _save();
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Tip: Use these variables in your requests with double curly braces, e.g., {{base_url}}',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
