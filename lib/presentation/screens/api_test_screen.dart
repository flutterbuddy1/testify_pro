import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/api_request.dart';
import '../../domain/entities/api_response.dart';
import '../../core/providers/global_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../infrastructure/flow_engine/variable_injector.dart';
import '../widgets/desktop_splitter.dart';

/// Managed Key-Value pair for request headers and query parameters
class _KeyValueItem {
  final Key key;
  final TextEditingController keyController;
  final TextEditingController valueController;

  _KeyValueItem({String k = '', String v = ''})
      : key = UniqueKey(),
        keyController = TextEditingController(text: k),
        valueController = TextEditingController(text: v);

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

enum _PanelFocus { none, request, response }

class ApiTestScreen extends ConsumerStatefulWidget {
  const ApiTestScreen({super.key});

  @override
  ConsumerState<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends ConsumerState<ApiTestScreen>
    with TickerProviderStateMixin {
  final _uuid = const Uuid();

  // Controllers
  final _urlController = TextEditingController(
    text: 'https://jsonplaceholder.typicode.com/posts/1',
  );
  final _bodyController = TextEditingController();
  final _headerSearchController = TextEditingController();

  // Dynamic lists for params and headers
  final List<_KeyValueItem> _headers = [];
  final List<_KeyValueItem> _queryParams = [];

  HttpMethod _selectedMethod = HttpMethod.get;
  ApiResponse? _response;
  bool _isLoading = false;
  List<ApiRequest> _history = [];

  // Layout & Resizing States
  double _sidebarWidth = 250.0;
  bool _isSidebarCollapsed = false;

  bool _isSideBySide = false;
  double _requestPaneHeight = 280.0;
  double _requestPaneWidth = 520.0;
  _PanelFocus _panelFocus = _PanelFocus.none;

  late TabController _requestTabController;
  late TabController _responseTabController;

  String _headerSearchQuery = '';
  String _responseViewMode = 'pretty'; // 'pretty' or 'raw'

  @override
  void initState() {
    super.initState();
    _requestTabController = TabController(length: 3, vsync: this);
    _responseTabController = TabController(length: 2, vsync: this);

    _headerSearchController.addListener(() {
      setState(() {
        _headerSearchQuery = _headerSearchController.text;
      });
    });

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
    _headerSearchController.dispose();
    _requestTabController.dispose();
    _responseTabController.dispose();
    for (final item in _headers) {
      item.dispose();
    }
    for (final item in _queryParams) {
      item.dispose();
    }
    super.dispose();
  }

  void _loadFromHistory(ApiRequest request) {
    setState(() {
      _urlController.text = request.url;
      _selectedMethod = request.method;
      _bodyController.text = request.body ?? '';

      for (final item in _headers) {
        item.dispose();
      }
      _headers.clear();
      for (final e in request.headers.entries) {
        _headers.add(_KeyValueItem(k: e.key, v: e.value));
      }

      for (final item in _queryParams) {
        item.dispose();
      }
      _queryParams.clear();
      for (final e in request.queryParams.entries) {
        _queryParams.add(_KeyValueItem(k: e.key, v: e.value));
      }
    });
  }

  Map<String, String> _buildMapFromItems(List<_KeyValueItem> items) {
    final map = <String, String>{};
    for (final item in items) {
      final k = item.keyController.text.trim();
      if (k.isNotEmpty) {
        map[k] = item.valueController.text.trim();
      }
    }
    return map;
  }

  Future<void> _sendRequest() async {
    setState(() {
      _isLoading = true;
      _response = null;
    });

    try {
      final headerMap = _buildMapFromItems(_headers);
      final paramMap = _buildMapFromItems(_queryParams);

      // Support active environment variable injection
      final activeEnv = ref.read(activeEnvironmentProvider);
      String targetUrl = _urlController.text.trim();
      String? targetBody =
          _bodyController.text.isEmpty ? null : _bodyController.text;
      Map<String, String> finalHeaders = Map.from(headerMap);

      if (activeEnv != null && activeEnv.variables.isNotEmpty) {
        final injector = VariableInjector(activeEnv.variables);
        targetUrl = injector.inject(targetUrl);
        if (targetBody != null) {
          targetBody = injector.inject(targetBody);
        }
        finalHeaders = finalHeaders.map(
          (k, v) => MapEntry(k, injector.inject(v)),
        );
      }

      final request = ApiRequest(
        id: _uuid.v4(),
        name: 'Request at ${DateTime.now().toIso8601String()}',
        url: targetUrl,
        method: _selectedMethod,
        headers: finalHeaders,
        queryParams: paramMap,
        body: targetBody,
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
        // Sidebar History (Collapsible and Resizable)
        if (!_isSidebarCollapsed) ...[
          SizedBox(
            width: _sidebarWidth,
            child: _buildHistorySidebar(context),
          ),
          DesktopVerticalSplitter(
            onDrag: (dx) {
              setState(() {
                _sidebarWidth = (_sidebarWidth + dx).clamp(180.0, 500.0);
              });
            },
            onDoubleTap: () {
              setState(() {
                _isSidebarCollapsed = true;
              });
            },
          ),
        ] else ...[
          // Collapsed sidebar tab
          Container(
            width: 42,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border(
                right: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                IconButton(
                  icon: const Icon(Icons.history, size: 20),
                  tooltip: 'Expand History Sidebar',
                  onPressed: () {
                    setState(() {
                      _isSidebarCollapsed = false;
                    });
                  },
                ),
                const SizedBox(height: 8),
                RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'History (${_history.length})',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Main Editor & Workspace
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _buildUrlBar(context),
                  const Divider(height: 1),
                  Expanded(
                    child: _isSideBySide
                        ? _buildSideBySideLayout(constraints)
                        : _buildStackedLayout(constraints),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Horizontal Split layout: Top (Request Config) + Bottom (Response)
  Widget _buildStackedLayout(BoxConstraints constraints) {
    if (_panelFocus == _PanelFocus.request) {
      return Column(
        children: [
          _buildPanelHeader(
            title: 'Request Configuration',
            isMaximized: true,
            onRestore: () => setState(() => _panelFocus = _PanelFocus.none),
          ),
          Expanded(child: _buildRequestConfiguration(context)),
        ],
      );
    }

    if (_panelFocus == _PanelFocus.response) {
      return Column(
        children: [
          _buildPanelHeader(
            title: 'Response Details',
            isMaximized: true,
            onRestore: () => setState(() => _panelFocus = _PanelFocus.none),
          ),
          Expanded(
            child: _response == null
                ? _buildEmptyResponse(context)
                : _buildResponseViewer(context),
          ),
        ],
      );
    }

    final maxHeight = constraints.maxHeight;
    final clampedHeight = _requestPaneHeight.clamp(140.0, maxHeight - 140.0);

    return Column(
      children: [
        // Request Pane
        SizedBox(
          height: clampedHeight,
          child: _buildRequestConfiguration(context),
        ),

        // Draggable Resizer with Quick Action Buttons
        DesktopHorizontalSplitter(
          onDrag: (dy) {
            setState(() {
              _requestPaneHeight =
                  (_requestPaneHeight + dy).clamp(140.0, maxHeight - 140.0);
            });
          },
          onDoubleTap: () {
            setState(() {
              _requestPaneHeight = maxHeight * 0.45;
            });
          },
          trailingActions: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up, size: 16),
                tooltip: 'Maximize Request',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 20),
                onPressed: () {
                  setState(() => _panelFocus = _PanelFocus.request);
                },
              ),
              IconButton(
                icon: const Icon(Icons.unfold_more, size: 14),
                tooltip: 'Reset 50/50 Split',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 20),
                onPressed: () {
                  setState(() {
                    _requestPaneHeight = maxHeight * 0.45;
                    _panelFocus = _PanelFocus.none;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                tooltip: 'Maximize Response',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 20),
                onPressed: () {
                  setState(() => _panelFocus = _PanelFocus.response);
                },
              ),
            ],
          ),
        ),

        // Response Pane
        Expanded(
          child: _response == null
              ? _buildEmptyResponse(context)
              : _buildResponseViewer(context),
        ),
      ],
    );
  }

  /// Vertical Split layout: Left (Request Config) + Right (Response)
  Widget _buildSideBySideLayout(BoxConstraints constraints) {
    if (_panelFocus == _PanelFocus.request) {
      return Column(
        children: [
          _buildPanelHeader(
            title: 'Request Configuration',
            isMaximized: true,
            onRestore: () => setState(() => _panelFocus = _PanelFocus.none),
          ),
          Expanded(child: _buildRequestConfiguration(context)),
        ],
      );
    }

    if (_panelFocus == _PanelFocus.response) {
      return Column(
        children: [
          _buildPanelHeader(
            title: 'Response Details',
            isMaximized: true,
            onRestore: () => setState(() => _panelFocus = _PanelFocus.none),
          ),
          Expanded(
            child: _response == null
                ? _buildEmptyResponse(context)
                : _buildResponseViewer(context),
          ),
        ],
      );
    }

    final maxWidth = constraints.maxWidth;
    final clampedWidth = _requestPaneWidth.clamp(280.0, maxWidth - 300.0);

    return Row(
      children: [
        // Left: Request Pane
        SizedBox(
          width: clampedWidth,
          child: _buildRequestConfiguration(context),
        ),

        // Draggable Vertical Splitter
        DesktopVerticalSplitter(
          onDrag: (dx) {
            setState(() {
              _requestPaneWidth =
                  (_requestPaneWidth + dx).clamp(280.0, maxWidth - 300.0);
            });
          },
          onDoubleTap: () {
            setState(() {
              _requestPaneWidth = maxWidth * 0.5;
            });
          },
        ),

        // Right: Response Pane
        Expanded(
          child: _response == null
              ? _buildEmptyResponse(context)
              : _buildResponseViewer(context),
        ),
      ],
    );
  }

  Widget _buildPanelHeader({
    required String title,
    required bool isMaximized,
    required VoidCallback onRestore,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: colorScheme.primary,
            ),
          ),
          TextButton.icon(
            onPressed: onRestore,
            icon: const Icon(Icons.fullscreen_exit, size: 16),
            label: const Text('Restore Split', style: TextStyle(fontSize: 11)),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySidebar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.history, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'History (${_history.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_all, size: 18),
                  tooltip: 'Clear History',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () async {
                    final historyRepo = ref.read(apiHistoryRepositoryProvider);
                    await historyRepo.clearAll();
                    _loadHistory();
                  },
                ),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                tooltip: 'Collapse sidebar',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: () {
                  setState(() => _isSidebarCollapsed = true);
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
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No history',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
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
    final activeEnv = ref.watch(activeEnvironmentProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (activeEnv != null)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language, size: 12, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        activeEnv.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              // Layout Mode Toggle Button (Side-by-side vs Stacked)
              Tooltip(
                message: _isSideBySide
                    ? 'Switch to Stacked View (Top/Bottom)'
                    : 'Switch to Side-by-Side View (Left/Right)',
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    setState(() {
                      _isSideBySide = !_isSideBySide;
                      _panelFocus = _PanelFocus.none;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isSideBySide
                              ? Icons.view_agenda_outlined
                              : Icons.view_sidebar_outlined,
                          size: 15,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isSideBySide ? 'Stacked' : 'Side-by-Side',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
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
                    hintText:
                        'Enter API URL (e.g. https://api.example.com/posts)',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.2),
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
                      borderSide:
                          BorderSide(color: colorScheme.primary, width: 2),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
                    : const Row(
                        children: [
                          Icon(Icons.send, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Send',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ],
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
            controller: _requestTabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Params (${_queryParams.length})'),
              Tab(text: 'Headers (${_headers.length})'),
              const Tab(text: 'Body'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _requestTabController,
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
    List<_KeyValueItem> list,
    String type,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                '${list.length} ${type.toLowerCase()}${list.length == 1 ? '' : 's'} configured',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (type == 'Header') ...[
                    PopupMenuButton<String>(
                      tooltip: 'Add Header Preset',
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bookmark_add_outlined,
                                size: 15, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Presets',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onSelected: (preset) {
                        setState(() {
                          if (preset == 'json') {
                            list.add(_KeyValueItem(
                                k: 'Content-Type', v: 'application/json'));
                          } else if (preset == 'auth_bearer') {
                            list.add(
                                _KeyValueItem(k: 'Authorization', v: 'Bearer '));
                          } else if (preset == 'accept_json') {
                            list.add(_KeyValueItem(
                                k: 'Accept', v: 'application/json'));
                          } else if (preset == 'cache_control') {
                            list.add(_KeyValueItem(
                                k: 'Cache-Control', v: 'no-cache'));
                          }
                        });
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'json',
                          child: Text('Content-Type: application/json'),
                        ),
                        PopupMenuItem(
                          value: 'auth_bearer',
                          child: Text('Authorization: Bearer <token>'),
                        ),
                        PopupMenuItem(
                          value: 'accept_json',
                          child: Text('Accept: application/json'),
                        ),
                        PopupMenuItem(
                          value: 'cache_control',
                          child: Text('Cache-Control: no-cache'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        list.add(_KeyValueItem());
                      });
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text('Add $type'),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                  ),
                  if (list.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (final item in list) {
                            item.dispose();
                          }
                          list.clear();
                        });
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(color: colorScheme.error, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text(
                    'No $type configured. Click "+ Add $type" to create one.',
                    style: TextStyle(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Padding(
                      key: item.key,
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: item.keyController,
                              decoration: InputDecoration(
                                hintText: '$type Name (Key)',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: item.valueController,
                              decoration: InputDecoration(
                                hintText: 'Value',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            tooltip: 'Remove $type',
                            onPressed: () {
                              setState(() {
                                final removed = list.removeAt(index);
                                removed.dispose();
                              });
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

  Widget _buildBodyEditor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          TextField(
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
              fillColor:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: ElevatedButton.icon(
              onPressed: () {
                final text = _bodyController.text.trim();
                if (text.isEmpty) return;
                try {
                  final json = jsonDecode(text);
                  final pretty =
                      const JsonEncoder.withIndent('  ').convert(json);
                  _bodyController.text = pretty;
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid JSON format: $e'),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.format_align_left, size: 14),
              label: const Text('Format JSON', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
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
            color: colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Hit Send to see the response',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseViewer(BuildContext context) {
    final resp = _response!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Row(
            children: [
              _buildStatusChip(resp),
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
                      fontWeight: FontWeight.w600,
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
                resp.sizeBytes > 1024
                    ? '${(resp.sizeBytes / 1024).toStringAsFixed(2)} KB'
                    : '${resp.sizeBytes} B',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: resp.body));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Response body copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 14),
                label: const Text('Copy Body', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),

        // Error banner if any error occurred
        if (resp.error != null && resp.error!.isNotEmpty)
          _buildErrorBanner(context, resp.error!),

        // Response Tab Bar
        TabBar(
          controller: _responseTabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: [
            const Tab(text: 'Body'),
            Tab(text: 'Headers (${resp.headers.length})'),
          ],
        ),

        // Response Tab Content
        Expanded(
          child: TabBarView(
            controller: _responseTabController,
            children: [
              _buildResponseBody(context, resp.body),
              _buildResponseHeaders(context, resp.headers),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ApiResponse resp) {
    final code = resp.statusCode;
    final isError = code == 0 || resp.error != null || code >= 400;
    final color = code == 0
        ? AppTheme.errorColor
        : (code < 300
            ? AppTheme.successColor
            : (code < 400 ? AppTheme.warningColor : AppTheme.errorColor));

    final label = code == 0
        ? (resp.statusMessage.isNotEmpty && resp.statusMessage != 'Error'
            ? resp.statusMessage
            : 'Connection Failed')
        : '$code ${resp.statusMessage}'.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String errorMessage) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request Error Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onErrorContainer,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onErrorContainer.withValues(alpha: 0.9),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            tooltip: 'Copy Error',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: errorMessage));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResponseBody(BuildContext context, String body) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (body.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 40,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No body content returned',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // Format JSON if applicable
    String prettyBody = body;
    bool isJson = false;
    try {
      final json = jsonDecode(body);
      prettyBody = const JsonEncoder.withIndent('  ').convert(json);
      isJson = true;
    } catch (_) {}

    final displayContent = _responseViewMode == 'pretty' ? prettyBody : body;

    return Column(
      children: [
        // View mode selector toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
          child: Row(
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'pretty',
                    label: Text('Pretty', style: TextStyle(fontSize: 11)),
                    icon: Icon(Icons.code, size: 14),
                  ),
                  ButtonSegment(
                    value: 'raw',
                    label: Text('Raw', style: TextStyle(fontSize: 11)),
                    icon: Icon(Icons.text_snippet, size: 14),
                  ),
                ],
                selected: {_responseViewMode},
                onSelectionChanged: (set) {
                  setState(() {
                    _responseViewMode = set.first;
                  });
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                tooltip: 'Copy Body',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: displayContent));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied response body to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Body Content
        Expanded(
          child: Container(
            width: double.infinity,
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _responseViewMode == 'pretty' && isJson
                  ? HighlightView(
                      displayContent,
                      language: 'json',
                      theme: isDark ? draculaTheme : githubTheme,
                      padding: const EdgeInsets.all(0),
                      textStyle: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.4,
                      ),
                    )
                  : SelectableText(
                      displayContent,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponseHeaders(
    BuildContext context,
    Map<String, dynamic> headers,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (headers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt_outlined,
              size: 40,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No response headers received',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final query = _headerSearchQuery.toLowerCase().trim();
    final filteredHeaders = headers.entries.where((e) {
      if (query.isEmpty) return true;
      return e.key.toLowerCase().contains(query) ||
          e.value.toString().toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // Header Search & Actions Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _headerSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search response headers...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _headerSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () => _headerSearchController.clear(),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  final text = headers.entries
                      .map((e) => '${e.key}: ${e.value}')
                      .join('\n');
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All headers copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_all, size: 16),
                label: const Text('Copy All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Headers List
        Expanded(
          child: filteredHeaders.isEmpty
              ? Center(
                  child: Text(
                    'No headers match "$_headerSearchQuery"',
                    style: TextStyle(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredHeaders.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final e = filteredHeaders[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: SelectableText(
                              e.key,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: SelectableText(
                              e.value.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 14),
                            tooltip: 'Copy ${e.key}',
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: e.value.toString()),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied ${e.key} value'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
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

  Widget _methodLabel(HttpMethod method) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: _getMethodColor(method).withValues(alpha: 0.1),
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
