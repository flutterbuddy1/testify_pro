import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/utils/flow_json_parser.dart';
import '../../domain/entities/flow.dart' as entities;

class FlowImportResult {
  final entities.Flow flow;
  final bool runImmediately;

  const FlowImportResult({
    required this.flow,
    this.runImmediately = false,
  });
}

/// Dialog allowing users to import a Flow from a JSON file or by pasting raw JSON
class FlowJsonImportDialog extends StatefulWidget {
  const FlowJsonImportDialog({super.key});

  static Future<FlowImportResult?> show(BuildContext context) {
    return showDialog<FlowImportResult>(
      context: context,
      builder: (context) => const FlowJsonImportDialog(),
    );
  }

  @override
  State<FlowJsonImportDialog> createState() => _FlowJsonImportDialogState();
}

class _FlowJsonImportDialogState extends State<FlowJsonImportDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _jsonController = TextEditingController();

  String? _pickedFileName;
  FlowValidationResult? _validationResult;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _jsonController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _jsonController.removeListener(_onTextChanged);
    _jsonController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      setState(() => _validationResult = null);
    } else {
      final res = FlowJsonParser.validateJson(text);
      setState(() => _validationResult = res);
    }
  }

  Future<void> _pickJsonFile() async {
    setState(() => _isProcessing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final validation = FlowJsonParser.validateJson(content);

        setState(() {
          _pickedFileName = result.files.single.name;
          _validationResult = validation;
          _jsonController.text = content;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read file: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _loadSampleTemplate() {
    final sample = FlowJsonParser.getSampleFlowJson();
    _jsonController.text = sample;
    _tabController.animateTo(1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loaded sample flow template. You can customize it or import directly.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _finishImport({required bool runImmediately}) {
    final flow = _validationResult?.flow;
    if (flow == null) return;
    Navigator.of(context).pop(
      FlowImportResult(flow: flow, runImmediately: runImmediately),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isValid = _validationResult?.isValid ?? false;
    final flow = _validationResult?.flow;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 640,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.integration_instructions_outlined, color: colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import Flow from JSON',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Upload a flow JSON file or paste your custom test scenario directly.',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _loadSampleTemplate,
                  icon: const Icon(Icons.lightbulb_outline, size: 16),
                  label: const Text('Load Sample Template', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.upload_file, size: 18), text: 'Pick JSON File'),
                Tab(icon: Icon(Icons.code, size: 18), text: 'Paste / Edit JSON'),
              ],
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFilePickerTab(colorScheme),
                  _buildPasteJsonTab(colorScheme),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Validation & Action Bar
            _buildFooter(colorScheme, isValid, flow),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePickerTab(ColorScheme colorScheme) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: _isProcessing ? null : _pickJsonFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.4),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                ),
                child: Column(
                  children: [
                    Icon(
                      _pickedFileName != null ? Icons.check_circle_outline : Icons.file_upload_outlined,
                      size: 48,
                      color: _pickedFileName != null ? Colors.green : colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _pickedFileName ?? 'Click to select a .json file',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _pickedFileName != null ? Colors.green : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Supports standard TestifyPro flow JSON format',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _pickJsonFile,
                      icon: const Icon(Icons.folder_open, size: 18),
                      label: Text(_pickedFileName != null ? 'Choose Another File' : 'Browse Files'),
                    ),
                  ],
                ),
              ),
            ),
            if (_pickedFileName != null && _validationResult?.isValid == true) ...[
              const SizedBox(height: 16),
              _buildFlowSummaryCard(colorScheme, _validationResult!.flow!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasteJsonTab(ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            ),
            child: TextField(
              controller: _jsonController,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'Paste your flow JSON scenario here, or click "Load Sample Template" above...',
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                contentPadding: const EdgeInsets.all(12),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlowSummaryCard(ColorScheme colorScheme, entities.Flow flow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flow.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${flow.steps.length} Steps • ${flow.variables.length} Variables • ${flow.tags.join(", ")}',
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ColorScheme colorScheme, bool isValid, entities.Flow? flow) {
    final hasErrors = _validationResult != null && !_validationResult!.isValid;

    return Row(
      children: [
        // Validation Status / Error message
        Expanded(
          child: hasErrors
              ? Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationResult!.errors.first,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : isValid && flow != null
                  ? Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ready: "${flow.name}" (${flow.steps.length} steps)',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Enter or upload JSON to validate',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
        ),
        const SizedBox(width: 12),

        // Action Buttons
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: isValid ? () => _finishImport(runImmediately: false) : null,
          child: const Text('Import Flow'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: isValid ? () => _finishImport(runImmediately: true) : null,
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('Import & Run 🚀'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Dialog allowing users to view and export flow JSON
class FlowJsonExportDialog extends StatelessWidget {
  final entities.Flow flow;

  const FlowJsonExportDialog({super.key, required this.flow});

  static Future<void> show(BuildContext context, entities.Flow flow) {
    return showDialog(
      context: context,
      builder: (context) => FlowJsonExportDialog(flow: flow),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final jsonString = FlowJsonParser.flowToJson(flow, pretty: true);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 720,
        height: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.file_download_outlined, color: colorScheme.secondary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Flow: ${flow.name}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Formatted JSON ready to save or use in automated pipelines.',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: SelectableText(
                  jsonString,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: jsonString));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Flow JSON copied to clipboard!')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy to Clipboard'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final safeName = flow.name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_').toLowerCase();
                      final resultPath = await FilePicker.platform.saveFile(
                        dialogTitle: 'Save Flow JSON',
                        fileName: '${safeName}_flow.json',
                        allowedExtensions: ['json'],
                        type: FileType.custom,
                      );
                      if (resultPath != null) {
                        final file = File(resultPath);
                        await file.writeAsString(jsonString);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Flow saved to $resultPath')),
                          );
                          Navigator.of(context).pop();
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to save file: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.save_alt, size: 16),
                  label: const Text('Save to File (.json)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog displaying Flow JSON format documentation and reference
class FlowJsonHelpDialog extends StatelessWidget {
  const FlowJsonHelpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const FlowJsonHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 680,
        height: 580,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: colorScheme.primary, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Flow JSON Specification Guide',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'You can write your own custom JSON file and import it directly into TestifyPro.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, '1. Core Structure'),
                  const Text(
                    '• name: Title of the flow (required)\n'
                    '• description: Optional explanation of the flow\n'
                    '• variables: Initial key-value variables (e.g. {"baseUrl": "https://api.com"})\n'
                    '• tags: Array of tags (e.g. ["smoke", "orders"])\n'
                    '• steps: Array of test steps executed in order',
                    style: TextStyle(fontSize: 12.5, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, '2. Dynamic Variables & Extractors'),
                  const Text(
                    '• In any URL, Header, or Body, use {{variableName}} to inject values dynamically.\n'
                    '• In steps, define extractors to capture values from response JSON using JSONPath:\n'
                    '    {"extractors": {"authToken": "\$.token", "userId": "\$.user.id"}}',
                    style: TextStyle(fontSize: 12.5, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, '3. Assertion Types'),
                  const Text(
                    '• statusCode: Verify response status (expected: "200" or "201")\n'
                    '• responseTime: Ensure duration <= expected in ms (expected: "1500")\n'
                    '• jsonPath: Test JSONPath expression against expected value\n'
                    '    {"type": "jsonPath", "actual": "\$.data.status", "expected": "success"}\n'
                    '• contains: Check if response body contains substring\n'
                    '• notContains: Check if response body does not contain substring',
                    style: TextStyle(fontSize: 12.5, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, '4. Request Body Handling'),
                  const Text(
                    '• You can specify body as a raw string OR directly as a JSON object:\n'
                    '    "body": {"title": "Hello", "userId": 1}\n'
                    '• The parser will automatically format and send it with Content-Type: application/json.',
                    style: TextStyle(fontSize: 12.5, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
