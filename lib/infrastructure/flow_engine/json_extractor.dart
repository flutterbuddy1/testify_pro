// JSONPath Extractor - Extract Data from API Responses
//
// PUROSE:
// - Extract values from JSON responses using JSONPath expressions
// - Store extracted values in flow context for use in subsequent steps
// - Handle extraction errors gracefully
//
// JSONPATH SYNTAX EXAMPLES:
// - $.data.token - Extract token from {"data": {"token": "abc123"}}
// - $.users[0].id - Extract first user's ID from array
// - $..price - Recursively find all price fields
//
// USAGE:
// final extractor = JsonExtractor();
// final value = extractor.extract(jsonString, '$.data.token');
// if (value != null) {
//   context.setVariable('authToken', value);
// }

import 'dart:convert';
import 'package:json_path/json_path.dart';

class JsonExtractor {
  /// Extract value from JSON string using JSONPath expression
  ///
  /// Returns the extracted value as a string, or null if extraction fails
  String? extract(String jsonString, String jsonPathExpression) {
    try {
      // Parse JSON
      final jsonData = jsonDecode(jsonString);

      // Create JSONPath expression
      final jsonPath = JsonPath(jsonPathExpression);

      // Execute query
      final matches = jsonPath.read(jsonData);

      if (matches.isEmpty) {
        return null;
      }

      // Return first match as string
      final value = matches.first.value;
      return value?.toString();
    } catch (e) {
      // Extraction failed
      print('❌ JSONPath extraction failed: $e');
      print('   Expression: $jsonPathExpression');
      return null;
    }
  }

  /// Extract multiple values using multiple JSONPath expressions
  ///
  /// Returns a map of variable names to extracted values
  Map<String, String> extractMultiple(
    String jsonString,
    Map<String, String> extractors,
  ) {
    final results = <String, String>{};

    for (final entry in extractors.entries) {
      final variableName = entry.key;
      final jsonPathExpression = entry.value;

      final value = extract(jsonString, jsonPathExpression);
      if (value != null) {
        results[variableName] = value;
      }
    }

    return results;
  }

  /// Validate JSONPath expression
  bool isValidExpression(String expression) {
    try {
      JsonPath(expression);
      return true;
    } catch (e) {
      return false;
    }
  }
}
