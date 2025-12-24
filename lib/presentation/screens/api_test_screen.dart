import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/api_request.dart';
import '../../domain/entities/api_response.dart';
import '../../core/providers/global_providers.dart';
import '../../core/theme/app_theme.dart';

class ApiTestScreen extends ConsumerStatefulWidget {
  const ApiTestScreen({super.key});

  @override
  ConsumerState<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends ConsumerState<ApiTestScreen>
    with SingleTickerProviderStateMixin {
  final _uuid = const Uuid();

  // Controllers
  final _urlController = TextEditingController(
    text: 'https://jsonplaceholder.typicode.com/posts/1',
  );
  final _bodyController = TextEditingController();

  // Dynamic lists for params and headers
  final List<MapEntry<String, String>> _headers = [];
  final List<MapEntry<String, String>> _queryParams = [];

  HttpMethod _selectedMethod = HttpMethod.get;
  ApiResponse? _response;
  bool _isLoading = false;
  List<ApiRequest> _history = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final historyRepo = ref.read(apiHistoryRepositoryProvider);
    final history = await historyRepo.getHistory();
    if (mounted) {
      setState(() {
        _history = history;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _bodyController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadFromHistory(ApiRequest request) {
    setState(() {
      _urlController.text = request.url;
      _selectedMethod = request.method;
      _bodyController.text = request.body ?? '';

      _headers.clear();
      _headers.addAll(request.headers.entries);

      _queryParams.clear();
      _queryParams.addAll(request.queryParams.entries);
    });
  }

  Future<void> _sendRequest() async {
    setState(() {
      _isLoading = true;
      _response = null;
    });

    try {
      final headerMap = Map.fromEntries(
        _headers.where((e) => e.key.isNotEmpty),
      );
      final paramMap = Map.fromEntries(
        _queryParams.where((e) => e.key.isNotEmpty),
      );

      final request = ApiRequest(
        id: _uuid.v4(),
        name: 'Request at ${DateTime.now().toIso8601String()}',
        url: _urlController.text,
        method: _selectedMethod,
        headers: headerMap,
        queryParams: paramMap,
        body: _bodyController.text.isEmpty ? null : _bodyController.text,
      );

      final httpService = ref.read(httpServiceProvider);
      final response = await httpService.execute(request);

      final historyRepo = ref.read(apiHistoryRepositoryProvider);
      await historyRepo.saveRequest(request);
      _loadHistory();

      if (mounted) {
        setState(() => _response = response);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Sidebar History
        Container(
          width: 250,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            border: Border(
              right: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: _buildHistorySidebar(context),
        ),

        // Main Editor
        Expanded(
          child: Column(
            children: [
              _buildUrlBar(context),
              const Divider(height: 1),
              _buildRequestConfiguration(context),
              const Divider(height: 1),
              Expanded(
                child: _response == null
                    ? _buildEmptyResponse(context)
                    : _buildResponseViewer(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySidebar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.history, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'History',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (_history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_all, size: 18),
                  tooltip: 'Clear History',
                  onPressed: () async {
                    final historyRepo = ref.read(apiHistoryRepositoryProvider);
                    await historyRepo.clearAll();
                    _loadHistory();
                  },
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 32,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No history',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final req = _history[index];
                    return ListTile(
                      dense: true,
                      leading: _methodLabel(req.method),
                      title: Text(
                        req.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => _loadFromHistory(req),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUrlBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Method Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(8),
              ),
            ),
            child: DropdownButton<HttpMethod>(
              value: _selectedMethod,
              underline: const SizedBox(),
              dropdownColor: colorScheme.surface,
              items: HttpMethod.values
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(
                        m.name.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getMethodColor(m),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedMethod = v!),
            ),
          ),
          // URL Input
          Expanded(
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'Enter API URL',
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(8),
                  ),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(8),
                  ),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send Button
          ElevatedButton(
            onPressed: _isLoading ? null : _sendRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Text(
                    'Send',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestConfiguration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Params'),
              Tab(text: 'Headers'),
              Tab(text: 'Body'),
            ],
          ),
          SizedBox(
            height: 200,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildKeyValueEditor(context, _queryParams, 'Param'),
                _buildKeyValueEditor(context, _headers, 'Header'),
                _buildBodyEditor(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValueEditor(
    BuildContext context,
    List<MapEntry<String, String>> list,
    String type,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length + 1,
            itemBuilder: (context, index) {
              if (index == list.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => list.add(const MapEntry('', ''))),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text('Add $type'),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Key',
                          contentPadding: EdgeInsets.all(8),
                          isDense: true,
                        ),
                        onChanged: (v) =>
                            list[index] = MapEntry(v, list[index].value),
                        controller: TextEditingController(text: list[index].key)
                          ..selection = TextSelection.fromPosition(
                            TextPosition(offset: list[index].key.length),
                          ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Value',
                          contentPadding: EdgeInsets.all(8),
                          isDense: true,
                        ),
                        onChanged: (v) =>
                            list[index] = MapEntry(list[index].key, v),
                        controller:
                            TextEditingController(text: list[index].value)
                              ..selection = TextSelection.fromPosition(
                                TextPosition(offset: list[index].value.length),
                              ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 16,
                        color: colorScheme.error,
                      ),
                      onPressed: () => setState(() => list.removeAt(index)),
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

  Widget _buildBodyEditor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _bodyController,
        maxLines: null,
        expands: true,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Request Body (JSON)',
          fillColor: colorScheme.surfaceVariant.withOpacity(0.1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResponse(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rocket_launch_outlined,
            size: 64,
            color: colorScheme.primary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Hit Send to see the response',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseViewer(BuildContext context) {
    final resp = _response!;
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            child: Row(
              children: [
                _StatusChip(statusCode: resp.statusCode),
                const SizedBox(width: 16),
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${resp.responseTimeMs} ms',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.storage_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${(resp.sizeBytes / 1024).toStringAsFixed(2)} KB',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            isScrollable: true,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(text: 'Body'),
              Tab(text: 'Headers'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildResponseBody(context, resp.body),
                _buildResponseHeaders(context, resp.headers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseBody(BuildContext context, String body) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (body.isEmpty) return const Center(child: Text('No body content'));

    // Attempt to format JSON
    String displayBody = body;
    try {
      final json = jsonDecode(body);
      displayBody = const JsonEncoder.withIndent('  ').convert(json);
    } catch (_) {}

    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HighlightView(
          displayBody,
          language: 'json',
          theme: isDark ? draculaTheme : githubTheme,
          padding: const EdgeInsets.all(0),
          textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildResponseHeaders(
    BuildContext context,
    Map<String, dynamic> headers,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(3)},
        children: headers.entries
            .map(
              (e) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      e.key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      e.value.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _methodLabel(HttpMethod method) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: _getMethodColor(method).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method.name.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 9,
          color: _getMethodColor(method),
        ),
      ),
    );
  }

  Color _getMethodColor(HttpMethod m) {
    switch (m) {
      case HttpMethod.get:
        return AppTheme.successColor;
      case HttpMethod.post:
        return AppTheme.warningColor;
      case HttpMethod.put:
        return AppTheme.infoColor;
      case HttpMethod.patch:
        return Colors.purple;
      case HttpMethod.delete:
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final int statusCode;
  const _StatusChip({required this.statusCode});

  @override
  Widget build(BuildContext context) {
    final color = statusCode < 300
        ? AppTheme.successColor
        : (statusCode < 400 ? AppTheme.infoColor : AppTheme.errorColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$statusCode',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
