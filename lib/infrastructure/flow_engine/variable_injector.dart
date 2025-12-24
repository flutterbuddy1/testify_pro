// Variable Injector - Replace Placeholders with Actual Values
//
// PURPOSE:
// - Replaces placeholders in requests with actual values
// - Supports variables extracted from previous steps
// - Supports environment variables
// - Supports built-in functions (e.g., {{$timestamp}}, {{$uuid}})
//
// PLACEHOLDER SYNTAX:
// - {{variableName}} - Replaced with variable value
// - {{$timestamp}} - Current Unix timestamp
// - {{$uuid}} - Random UUID
// - {{$randomInt}} - Random integer
//
// USAGE:
// final injector = VariableInjector(context);
// final url = injector.inject('https://api.com/users/{{userId}}');
// final body = injector.inject('{"token": "{{authToken}}"}');

import 'package:uuid/uuid.dart';
import 'dart:math';

class VariableInjector {
  final Map<String, String> _variables;
  final _uuid = const Uuid();
  final _random = Random();

  VariableInjector(this._variables);

  /// Inject variables into a string
  ///
  /// Replaces all {{placeholder}} with actual values
  String inject(String input) {
    String result = input;

    // Pattern to match {{variableName}}
    final pattern = RegExp(r'\{\{([^}]+)\}\}');

    final matches = pattern.allMatches(input);

    for (final match in matches) {
      final placeholder = match.group(0)!; // {{variableName}}
      final variableName = match.group(1)!; // variableName

      final value = _resolveVariable(variableName);
      if (value != null) {
        result = result.replaceAll(placeholder, value);
      }
    }

    return result;
  }

  /// Inject variables into API request
  ///
  /// Returns a new ApiRequest with variables injected
  Map<String, dynamic> injectIntoRequest(Map<String, dynamic> request) {
    return {
      'url': inject(request['url'] ?? ''),
      'method': request['method'],
      'headers': _injectIntoMap(request['headers'] ?? {}),
      'queryParams': _injectIntoMap(request['queryParams'] ?? {}),
      'body': request['body'] != null ? inject(request['body']) : null,
    };
  }

  /// Inject variables into a map (headers, query params)
  Map<String, String> _injectIntoMap(Map<String, dynamic> map) {
    return map.map(
      (key, value) => MapEntry(inject(key), inject(value.toString())),
    );
  }

  /// Resolve a variable name to its value
  String? _resolveVariable(String variableName) {
    // Check for built-in functions
    if (variableName.startsWith('\$')) {
      return _resolveBuiltIn(variableName);
    }

    // Check user variables
    return _variables[variableName];
  }

  /// Resolve built-in functions
  String? _resolveBuiltIn(String functionName) {
    switch (functionName) {
      case '\$timestamp':
        return DateTime.now().millisecondsSinceEpoch.toString();

      case '\$uuid':
        return _uuid.v4();

      case '\$randomInt':
        return _random.nextInt(1000000).toString();

      case '\$randomString':
        return _uuid.v4().replaceAll('-', '').substring(0, 16);

      case '\$date':
        return DateTime.now().toIso8601String().split('T')[0];

      case '\$datetime':
        return DateTime.now().toIso8601String();

      default:
        return null;
    }
  }

  /// Get all available variables
  Map<String, String> get variables => Map.from(_variables);
}
