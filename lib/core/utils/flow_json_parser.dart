import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../domain/entities/flow.dart' as entities;
import '../../domain/entities/flow_step.dart';
import '../../domain/entities/api_request.dart';

class FlowValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final entities.Flow? flow;

  const FlowValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.flow,
  });
}

class FlowJsonParser {
  static const _uuid = Uuid();

  /// Validates a raw JSON string and returns structured result with errors/warnings
  static FlowValidationResult validateJson(String jsonString) {
    if (jsonString.trim().isEmpty) {
      return const FlowValidationResult(
        isValid: false,
        errors: ['JSON content is empty.'],
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (e) {
      return FlowValidationResult(
        isValid: false,
        errors: ['Invalid JSON syntax: $e'],
      );
    }

    if (decoded is! Map<String, dynamic>) {
      return const FlowValidationResult(
        isValid: false,
        errors: ['Root JSON element must be an object/map.'],
      );
    }

    if (isPostmanCollection(decoded)) {
      try {
        final flow = parsePostmanCollection(decoded);
        return FlowValidationResult(
          isValid: true,
          errors: [],
          warnings: [
            'Detected Postman Collection format ("${flow.name}"). Imported ${flow.steps.length} requests.',
          ],
          flow: flow,
        );
      } catch (e) {
        return FlowValidationResult(
          isValid: false,
          errors: ['Failed to parse Postman collection: $e'],
        );
      }
    }

    final errors = <String>[];
    final warnings = <String>[];

    final name = decoded['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      errors.add('Flow "name" is required and cannot be empty.');
    }

    final stepsRaw = decoded['steps'];
    if (stepsRaw == null || stepsRaw is! List || stepsRaw.isEmpty) {
      errors.add('Flow must contain a non-empty "steps" array.');
    } else {
      for (int i = 0; i < stepsRaw.length; i++) {
        final stepItem = stepsRaw[i];
        if (stepItem is! Map<String, dynamic>) {
          errors.add('Step ${i + 1} must be an object.');
          continue;
        }

        final stepName = stepItem['name']?.toString().trim() ?? 'Step ${i + 1}';
        final requestRaw = stepItem['request'];

        if (requestRaw == null || requestRaw is! Map<String, dynamic>) {
          errors.add('Step "$stepName" (${i + 1}) is missing a valid "request" object.');
        } else {
          final url = requestRaw['url']?.toString().trim();
          if (url == null || url.isEmpty) {
            errors.add('Step "$stepName" (${i + 1}) request must specify a "url".');
          }

          final method = requestRaw['method']?.toString().trim().toUpperCase();
          if (method != null && !['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS'].contains(method)) {
            warnings.add('Step "$stepName" (${i + 1}) specifies unrecognized HTTP method "$method". Defaulting to GET.');
          }
        }

        final assertionsRaw = stepItem['assertions'];
        if (assertionsRaw != null && assertionsRaw is List) {
          for (int a = 0; a < assertionsRaw.length; a++) {
            final assertion = assertionsRaw[a];
            if (assertion is Map<String, dynamic>) {
              final typeStr = assertion['type']?.toString();
              if (typeStr == 'jsonPath' && (assertion['actual'] == null || assertion['actual'].toString().isEmpty)) {
                warnings.add('Step "$stepName" assertion #${a + 1} uses "jsonPath" but "actual" JSONPath is not specified.');
              }
            }
          }
        }
      }
    }

    if (errors.isNotEmpty) {
      return FlowValidationResult(
        isValid: false,
        errors: errors,
        warnings: warnings,
      );
    }

    try {
      final flow = parseFlowFromMap(decoded);
      return FlowValidationResult(
        isValid: true,
        errors: [],
        warnings: warnings,
        flow: flow,
      );
    } catch (e) {
      return FlowValidationResult(
        isValid: false,
        errors: ['Failed to construct flow from JSON: $e'],
        warnings: warnings,
      );
    }
  }

  /// Parses a JSON string into a Flow entity
  static entities.Flow parseFlow(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected root JSON object');
    }
    if (isPostmanCollection(decoded)) {
      return parsePostmanCollection(decoded);
    }
    return parseFlowFromMap(decoded);
  }

  /// Parses a Map into a Flow entity with smart defaults
  static entities.Flow parseFlowFromMap(Map<String, dynamic> json) {
    final now = DateTime.now();

    final id = json['id']?.toString().isNotEmpty == true
        ? json['id'].toString()
        : _uuid.v4();

    final name = json['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      throw const FormatException('Flow "name" is required');
    }

    final description = json['description']?.toString();

    // Variables map
    final variables = <String, String>{};
    if (json['variables'] is Map) {
      (json['variables'] as Map).forEach((k, v) {
        if (k != null) variables[k.toString()] = v?.toString() ?? '';
      });
    }

    // Tags list
    final tags = <String>[];
    if (json['tags'] is List) {
      for (final t in json['tags'] as List) {
        if (t != null) tags.add(t.toString());
      }
    }

    // Steps list
    final stepsRaw = json['steps'] as List? ?? [];
    if (stepsRaw.isEmpty) {
      throw const FormatException('Flow must contain at least one step in "steps"');
    }

    final steps = <FlowStep>[];
    for (int i = 0; i < stepsRaw.length; i++) {
      final stepJson = stepsRaw[i];
      if (stepJson is Map<String, dynamic>) {
        steps.add(_parseStep(stepJson, i));
      }
    }

    DateTime createdAt = now;
    if (json['createdAt'] != null) {
      createdAt = DateTime.tryParse(json['createdAt'].toString()) ?? now;
    }

    DateTime updatedAt = now;
    if (json['updatedAt'] != null) {
      updatedAt = DateTime.tryParse(json['updatedAt'].toString()) ?? now;
    }

    return entities.Flow(
      id: id,
      name: name,
      description: description,
      variables: variables,
      tags: tags,
      steps: steps,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static FlowStep _parseStep(Map<String, dynamic> json, int index) {
    final stepId = json['id']?.toString().isNotEmpty == true
        ? json['id'].toString()
        : _uuid.v4();

    final stepName = json['name']?.toString().trim().isNotEmpty == true
        ? json['name'].toString().trim()
        : 'Step ${index + 1}';

    // Parse request
    final requestJson = (json['request'] is Map<String, dynamic>)
        ? json['request'] as Map<String, dynamic>
        : <String, dynamic>{};

    final request = _parseRequest(requestJson, stepName);

    // Parse extractors
    final extractors = <String, String>{};
    if (json['extractors'] is Map) {
      (json['extractors'] as Map).forEach((k, v) {
        if (k != null && v != null) {
          extractors[k.toString()] = v.toString();
        }
      });
    }

    // Parse assertions
    final assertions = <Assertion>[];
    if (json['assertions'] is List) {
      for (final a in json['assertions'] as List) {
        if (a is Map<String, dynamic>) {
          assertions.add(_parseAssertion(a));
        }
      }
    }

    final thinkTimeMs = (json['thinkTimeMs'] as num?)?.toInt() ?? 0;
    final stopOnFailure = json['stopOnFailure'] as bool? ?? true;
    final enabled = json['enabled'] as bool? ?? true;
    final preRequestScript = json['preRequestScript']?.toString();
    final testScript = json['testScript']?.toString();

    return FlowStep(
      id: stepId,
      name: stepName,
      request: request,
      extractors: extractors,
      assertions: assertions,
      thinkTimeMs: thinkTimeMs,
      stopOnFailure: stopOnFailure,
      enabled: enabled,
      preRequestScript: preRequestScript,
      testScript: testScript,
    );
  }

  static ApiRequest _parseRequest(Map<String, dynamic> json, String fallbackName) {
    final reqId = json['id']?.toString().isNotEmpty == true
        ? json['id'].toString()
        : _uuid.v4();

    final reqName = json['name']?.toString().isNotEmpty == true
        ? json['name'].toString()
        : fallbackName;

    final url = json['url']?.toString().trim() ?? '';
    if (url.isEmpty) {
      throw FormatException('Step "$fallbackName" is missing request "url"');
    }

    final method = _parseHttpMethod(json['method']?.toString());

    // Headers
    final headers = <String, String>{};
    if (json['headers'] is Map) {
      (json['headers'] as Map).forEach((k, v) {
        if (k != null) headers[k.toString()] = v?.toString() ?? '';
      });
    }

    // Query params
    final queryParams = <String, String>{};
    if (json['queryParams'] is Map) {
      (json['queryParams'] as Map).forEach((k, v) {
        if (k != null) queryParams[k.toString()] = v?.toString() ?? '';
      });
    }

    // Body: String or Map/List converted to JSON string
    String? body;
    if (json['body'] != null) {
      if (json['body'] is String) {
        body = json['body'] as String;
      } else if (json['body'] is Map || json['body'] is List) {
        body = const JsonEncoder.withIndent('  ').convert(json['body']);
      } else {
        body = json['body'].toString();
      }
    }

    // Auth config
    AuthConfig? auth;
    if (json['auth'] is Map<String, dynamic>) {
      auth = _parseAuthConfig(json['auth'] as Map<String, dynamic>);
    }

    final timeoutMs = (json['timeoutMs'] as num?)?.toInt() ?? 30000;

    return ApiRequest(
      id: reqId,
      name: reqName,
      url: url,
      method: method,
      headers: headers,
      queryParams: queryParams,
      body: body,
      auth: auth,
      timeoutMs: timeoutMs,
    );
  }

  static HttpMethod _parseHttpMethod(String? methodStr) {
    if (methodStr == null) return HttpMethod.get;
    final normalized = methodStr.trim().toLowerCase();
    switch (normalized) {
      case 'post':
        return HttpMethod.post;
      case 'put':
        return HttpMethod.put;
      case 'patch':
        return HttpMethod.patch;
      case 'delete':
        return HttpMethod.delete;
      case 'head':
        return HttpMethod.head;
      case 'options':
        return HttpMethod.options;
      case 'get':
      default:
        return HttpMethod.get;
    }
  }

  static Assertion _parseAssertion(Map<String, dynamic> json) {
    final name = json['name']?.toString().isNotEmpty == true
        ? json['name'].toString()
        : 'Assertion';

    final type = _parseAssertionType(json['type']?.toString());
    final expected = json['expected']?.toString() ?? '';
    final actual = json['actual']?.toString();

    return Assertion(
      name: name,
      type: type,
      expected: expected,
      actual: actual,
    );
  }

  static AssertionType _parseAssertionType(String? typeStr) {
    if (typeStr == null) return AssertionType.statusCode;
    final normalized = typeStr.trim().toLowerCase().replaceAll('_', '');
    switch (normalized) {
      case 'responsetime':
      case 'time':
      case 'duration':
        return AssertionType.responseTime;
      case 'jsonpath':
      case 'json':
        return AssertionType.jsonPath;
      case 'contains':
        return AssertionType.contains;
      case 'notcontains':
        return AssertionType.notContains;
      case 'statuscode':
      case 'status':
      default:
        return AssertionType.statusCode;
    }
  }

  static AuthConfig? _parseAuthConfig(Map<String, dynamic> json) {
    final type = (json['type'] ?? json['runtimeType'] ?? '').toString().toLowerCase();
    if (type == 'bearer') {
      return AuthConfig.bearer(token: json['token']?.toString() ?? '');
    } else if (type == 'basic') {
      return AuthConfig.basic(
        username: json['username']?.toString() ?? '',
        password: json['password']?.toString() ?? '',
      );
    } else if (type == 'apikey' || type == 'api_key') {
      final locStr = json['location']?.toString().toLowerCase();
      return AuthConfig.apiKey(
        key: json['key']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
        location: locStr == 'query' ? ApiKeyLocation.query : ApiKeyLocation.header,
      );
    }
    return null;
  }

  /// Converts a Flow entity into a clean, human-readable JSON string for export
  static String flowToJson(entities.Flow flow, {bool pretty = true, bool exportClean = true}) {
    final map = <String, dynamic>{
      '\$schema': 'https://testifypro.dev/schemas/flow.v1.json',
      'name': flow.name,
    };

    if (flow.description != null && flow.description!.isNotEmpty) {
      map['description'] = flow.description;
    }

    if (flow.variables.isNotEmpty) {
      map['variables'] = flow.variables;
    }

    if (flow.tags.isNotEmpty) {
      map['tags'] = flow.tags;
    }

    map['steps'] = flow.steps.map((step) {
      final stepMap = <String, dynamic>{
        'name': step.name,
        'enabled': step.enabled,
        'stopOnFailure': step.stopOnFailure,
      };

      if (step.thinkTimeMs > 0) {
        stepMap['thinkTimeMs'] = step.thinkTimeMs;
      }

      final req = step.request;
      final reqMap = <String, dynamic>{
        'url': req.url,
        'method': req.method.name.toUpperCase(),
      };

      if (req.headers.isNotEmpty) {
        reqMap['headers'] = req.headers;
      }
      if (req.queryParams.isNotEmpty) {
        reqMap['queryParams'] = req.queryParams;
      }

      if (req.body != null && req.body!.isNotEmpty) {
        // If body is valid JSON, format as native JSON object in export for readability
        try {
          final parsed = jsonDecode(req.body!);
          reqMap['body'] = parsed;
        } catch (_) {
          reqMap['body'] = req.body;
        }
      }

      if (req.auth != null) {
        req.auth!.when(
          bearer: (token) => reqMap['auth'] = {'type': 'bearer', 'token': token},
          basic: (username, password) => reqMap['auth'] = {
            'type': 'basic',
            'username': username,
            'password': password,
          },
          apiKey: (key, value, location) => reqMap['auth'] = {
            'type': 'apiKey',
            'key': key,
            'value': value,
            'location': location.name,
          },
        );
      }

      if (req.timeoutMs != 30000) {
        reqMap['timeoutMs'] = req.timeoutMs;
      }

      stepMap['request'] = reqMap;

      if (step.extractors.isNotEmpty) {
        stepMap['extractors'] = step.extractors;
      }

      if (step.assertions.isNotEmpty) {
        stepMap['assertions'] = step.assertions.map((a) {
          final aMap = <String, dynamic>{
            'name': a.name,
            'type': a.type.name,
            'expected': a.expected,
          };
          if (a.actual != null) {
            aMap['actual'] = a.actual;
          }
          return aMap;
        }).toList();
      }

      if (step.preRequestScript != null && step.preRequestScript!.isNotEmpty) {
        stepMap['preRequestScript'] = step.preRequestScript;
      }
      if (step.testScript != null && step.testScript!.isNotEmpty) {
        stepMap['testScript'] = step.testScript;
      }

      return stepMap;
    }).toList();

    return pretty
        ? const JsonEncoder.withIndent('  ').convert(map)
        : jsonEncode(map);
  }

  /// Returns a full, working sample flow JSON template
  static String getSampleFlowJson() {
    return '''{
  "\$schema": "https://testifypro.dev/schemas/flow.v1.json",
  "name": "Sample Flow: Create & Verify Post",
  "description": "Multi-step automated flow test with dynamic JSONPath extraction and assertions",
  "variables": {
    "baseUrl": "https://jsonplaceholder.typicode.com",
    "authorEmail": "tester@testifypro.dev"
  },
  "tags": [
    "demo",
    "smoke-test"
  ],
  "steps": [
    {
      "name": "1. Create New Post",
      "enabled": true,
      "stopOnFailure": true,
      "thinkTimeMs": 300,
      "request": {
        "url": "{{baseUrl}}/posts",
        "method": "POST",
        "headers": {
          "Content-Type": "application/json; charset=UTF-8"
        },
        "body": {
          "title": "Post by {{authorEmail}}",
          "body": "This request was triggered from custom JSON flow test.",
          "userId": 1
        }
      },
      "extractors": {
        "createdPostId": "\$.id",
        "createdTitle": "\$.title"
      },
      "assertions": [
        {
          "name": "Verify Status 201 Created",
          "type": "statusCode",
          "expected": "201"
        },
        {
          "name": "Response under 3000ms",
          "type": "responseTime",
          "expected": "3000"
        },
        {
          "name": "Verify Created ID matches 101",
          "type": "jsonPath",
          "actual": "\$.id",
          "expected": "101"
        }
      ]
    },
    {
      "name": "2. Get Post Details",
      "enabled": true,
      "stopOnFailure": true,
      "thinkTimeMs": 200,
      "request": {
        "url": "{{baseUrl}}/posts/1",
        "method": "GET",
        "headers": {
          "Accept": "application/json"
        }
      },
      "assertions": [
        {
          "name": "Verify Status 200 OK",
          "type": "statusCode",
          "expected": "200"
        },
        {
          "name": "Body contains userId",
          "type": "contains",
          "expected": "userId"
        }
      ]
    }
  ]
}''';
  }

  /// Checks if a JSON map represents a Postman Collection (v2.0 or v2.1)
  static bool isPostmanCollection(Map<String, dynamic> json) {
    if (json['info'] is Map) {
      final info = json['info'] as Map;
      if (info['schema']?.toString().contains('getpostman.com') == true ||
          info.containsKey('_postman_id') ||
          json.containsKey('item')) {
        return true;
      }
    }
    return false;
  }

  /// Parses a Postman collection JSON map into a Flow entity
  static entities.Flow parsePostmanCollection(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>? ?? {};
    final name = info['name']?.toString().trim().isNotEmpty == true
        ? info['name'].toString().trim()
        : 'Postman Collection Flow';
    final description = info['description']?.toString();

    // Collection variables
    final variables = <String, String>{};
    if (json['variable'] is List) {
      for (final v in json['variable'] as List) {
        if (v is Map && v['key'] != null) {
          variables[v['key'].toString()] = v['value']?.toString() ?? '';
        }
      }
    }

    // Recursively collect steps from items
    final steps = <FlowStep>[];
    final itemsRaw = json['item'] as List? ?? [];
    _flattenPostmanItems(itemsRaw, steps, folderPrefix: '');

    if (steps.isEmpty) {
      throw const FormatException('Postman collection has no valid requests in "item".');
    }

    // Auto-discover {{variable}} usages across all requests
    _discoverReferencedVariables(steps, variables);

    return entities.Flow(
      id: _uuid.v4(),
      name: name,
      description: description,
      variables: variables,
      tags: ['postman-collection'],
      steps: steps,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static void _flattenPostmanItems(
    List items,
    List<FlowStep> steps, {
    required String folderPrefix,
  }) {
    for (final raw in items) {
      if (raw is! Map<String, dynamic>) continue;
      final itemName = raw['name']?.toString().trim() ?? 'Request';
      final currentPath = folderPrefix.isEmpty ? itemName : '$folderPrefix / $itemName';

      // If item has nested 'item', it's a folder: recurse
      if (raw['item'] is List) {
        _flattenPostmanItems(
          raw['item'] as List,
          steps,
          folderPrefix: currentPath,
        );
      } else if (raw['request'] != null) {
        // It's a request item
        final step = _convertPostmanRequestToStep(raw, currentPath, steps.length);
        if (step != null) {
          steps.add(step);
        }
      }
    }
  }

  static FlowStep? _convertPostmanRequestToStep(
    Map<String, dynamic> item,
    String stepName,
    int index,
  ) {
    final reqRaw = item['request'];
    if (reqRaw is! Map<String, dynamic>) return null;

    final stepId = item['id']?.toString().isNotEmpty == true
        ? item['id'].toString()
        : _uuid.v4();

    // URL & query params
    String urlStr = '';
    final queryParams = <String, String>{};
    final urlRaw = reqRaw['url'];
    if (urlRaw is String) {
      urlStr = urlRaw;
    } else if (urlRaw is Map) {
      urlStr = urlRaw['raw']?.toString() ?? '';
      if (urlStr.isEmpty) {
        final host = (urlRaw['host'] as List?)?.join('.') ?? '';
        final path = (urlRaw['path'] as List?)?.join('/') ?? '';
        final protocol = urlRaw['protocol']?.toString() ?? 'https';
        urlStr = '$protocol://$host/$path';
      }
      if (urlRaw['query'] is List) {
        for (final q in urlRaw['query'] as List) {
          if (q is Map && q['key'] != null) {
            queryParams[q['key'].toString()] = q['value']?.toString() ?? '';
          }
        }
      }
    }

    if (urlStr.isEmpty) {
      urlStr = 'https://example.com';
    }

    // Method
    final method = _parseHttpMethod(reqRaw['method']?.toString());

    // Headers
    final headers = <String, String>{};
    if (reqRaw['header'] is List) {
      for (final h in reqRaw['header'] as List) {
        if (h is Map && h['key'] != null) {
          if (h['disabled'] != true) {
            headers[h['key'].toString()] = h['value']?.toString() ?? '';
          }
        }
      }
    } else if (reqRaw['header'] is Map) {
      (reqRaw['header'] as Map).forEach((k, v) {
        if (k != null) headers[k.toString()] = v?.toString() ?? '';
      });
    }

    // Body
    String? body;
    final bodyRaw = reqRaw['body'];
    if (bodyRaw is Map) {
      final mode = bodyRaw['mode']?.toString();
      if (mode == 'raw' && bodyRaw['raw'] != null) {
        body = bodyRaw['raw'].toString();
      } else if (mode == 'urlencoded' && bodyRaw['urlencoded'] is List) {
        final pairs = <String>[];
        for (final f in bodyRaw['urlencoded'] as List) {
          if (f is Map && f['key'] != null) {
            pairs.add('${Uri.encodeQueryComponent(f['key'].toString())}=${Uri.encodeQueryComponent(f['value']?.toString() ?? '')}');
          }
        }
        body = pairs.join('&');
      } else if (bodyRaw['raw'] != null) {
        body = bodyRaw['raw'].toString();
      }
    } else if (bodyRaw is String) {
      body = bodyRaw;
    }

    // Auth
    AuthConfig? auth;
    final authRaw = reqRaw['auth'];
    if (authRaw is Map<String, dynamic>) {
      final type = authRaw['type']?.toString();
      if (type == 'bearer' && authRaw['bearer'] is List) {
        for (final b in authRaw['bearer'] as List) {
          if (b is Map && b['key'] == 'token') {
            auth = AuthConfig.bearer(token: b['value']?.toString() ?? '');
          }
        }
      } else if (type == 'basic' && authRaw['basic'] is List) {
        String u = '';
        String p = '';
        for (final b in authRaw['basic'] as List) {
          if (b is Map) {
            if (b['key'] == 'username') u = b['value']?.toString() ?? '';
            if (b['key'] == 'password') p = b['value']?.toString() ?? '';
          }
        }
        auth = AuthConfig.basic(username: u, password: p);
      } else if (type == 'apikey' && authRaw['apikey'] is List) {
        String k = '';
        String v = '';
        ApiKeyLocation loc = ApiKeyLocation.header;
        for (final b in authRaw['apikey'] as List) {
          if (b is Map) {
            if (b['key'] == 'key') k = b['value']?.toString() ?? '';
            if (b['key'] == 'value') v = b['value']?.toString() ?? '';
            if (b['key'] == 'in' && b['value'] == 'query') loc = ApiKeyLocation.query;
          }
        }
        auth = AuthConfig.apiKey(key: k, value: v, location: loc);
      }
    }

    // Extractors & Assertions from events
    final extractors = <String, String>{};
    final assertions = <Assertion>[];
    final events = item['event'] as List? ?? [];
    _extractPostmanAssertionsAndExtractors(events, extractors, assertions);

    String? preRequestScript;
    String? testScript;
    for (final ev in events) {
      if (ev is Map<String, dynamic>) {
        final listen = ev['listen']?.toString();
        final exec = ev['script']?['exec'];
        final scriptText = (exec is List) ? exec.join('\n') : (exec?.toString() ?? '');
        if (listen == 'prerequest') {
          preRequestScript = scriptText;
        } else if (listen == 'test') {
          testScript = scriptText;
        }
      }
    }

    final request = ApiRequest(
      id: _uuid.v4(),
      name: stepName,
      url: urlStr,
      method: method,
      headers: headers,
      queryParams: queryParams,
      body: body,
      auth: auth,
      timeoutMs: 30000,
    );

    return FlowStep(
      id: stepId,
      name: stepName,
      request: request,
      extractors: extractors,
      assertions: assertions,
      thinkTimeMs: 0,
      stopOnFailure: true,
      enabled: true,
      preRequestScript: preRequestScript,
      testScript: testScript,
    );
  }

  static void _extractPostmanAssertionsAndExtractors(
    List events,
    Map<String, String> extractors,
    List<Assertion> assertions,
  ) {
    for (final ev in events) {
      if (ev is! Map<String, dynamic>) continue;
      if (ev['listen'] != 'test') continue;

      final script = ev['script'];
      if (script is! Map<String, dynamic>) continue;
      final exec = script['exec'];
      final scriptText = (exec is List) ? exec.join('\n') : (exec?.toString() ?? '');

      // Check status code assertions: e.g. pm.response.code !== 200 or status(200)
      final statusMatch = RegExp(r'pm\.response\.(?:code\s*[!=]==?\s*|to\.have\.status\()\s*(\d{3})').firstMatch(scriptText);
      if (statusMatch != null) {
        final code = statusMatch.group(1)!;
        assertions.add(Assertion(
          name: 'Status is $code',
          type: AssertionType.statusCode,
          expected: code,
        ));
      }

      // Check extractors: pm.globals.set("actualValue", actualValue) + const actualValue = response.data.total_net_premium;
      final setVarMatches = RegExp(r'pm\.(?:globals|environment|collectionVariables)\.set\(\s*["\x27]([^"\x27]+)["\x27]\s*,\s*([^,\)\n]+)\)').allMatches(scriptText);
      for (final m in setVarMatches) {
        final varName = m.group(1)!.trim();
        final rawValExpr = m.group(2)!.trim();

        if (rawValExpr.startsWith('response.')) {
          extractors[varName] = rawValExpr.replaceFirst('response.', '\$.');
        } else {
          final pathMatch = RegExp('const\\s+${RegExp.escape(rawValExpr)}\\s*=\\s*response\\.([a-zA-Z0-9_\\.]+)').firstMatch(scriptText);
          if (pathMatch != null) {
            extractors[varName] = '\$.${pathMatch.group(1)}';
          }
        }
      }
    }

    if (assertions.isEmpty) {
      assertions.add(const Assertion(
        name: 'Status is 200 OK',
        type: AssertionType.statusCode,
        expected: '200',
      ));
    }
  }

  static void _discoverReferencedVariables(List<FlowStep> steps, Map<String, String> variables) {
    final varRegex = RegExp(r'\{\{([a-zA-Z0-9_\-\s]+)\}\}');
    for (final step in steps) {
      final textToScan = '${step.request.url} ${step.request.headers} ${step.request.body ?? ''}';
      for (final m in varRegex.allMatches(textToScan)) {
        final v = m.group(1)!.trim();
        if (!variables.containsKey(v)) {
          variables[v] = '';
        }
      }
    }
  }
}
