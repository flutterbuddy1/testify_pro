import 'dart:convert';

/// High-performance RFC 4180-compliant CSV and JSON dataset parser
/// for data-driven iteration testing.
class CsvParser {
  /// Parses a CSV string into a list of row maps where keys are the column headers.
  ///
  /// Supports:
  /// - Double-quoted values containing commas and newlines
  /// - Escaped double quotes (`""`)
  /// - Dynamic type inference (numbers, booleans, trimmed strings)
  static List<Map<String, dynamic>> parse(String csvText) {
    if (csvText.trim().isEmpty) return [];

    final rows = _parseRows(csvText);
    if (rows.isEmpty) return [];

    // First row is headers
    final rawHeaders = rows.first;
    final headers = rawHeaders.map((h) => h.trim()).toList();

    final result = <Map<String, dynamic>>[];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      // Skip empty trailing rows
      if (row.isEmpty || (row.length == 1 && row[0].trim().isEmpty)) {
        continue;
      }

      final rowMap = <String, dynamic>{};
      for (int c = 0; c < headers.length; c++) {
        final header = headers[c];
        if (header.isEmpty) continue;

        final rawValue = (c < row.length) ? row[c].trim() : '';
        rowMap[header] = _inferType(rawValue);
      }
      result.add(rowMap);
    }

    return result;
  }

  /// Parses a JSON array of objects `[{"col1": "val1"}, ...]`
  static List<Map<String, dynamic>> parseJsonArray(String jsonText) {
    final decoded = jsonDecode(jsonText);
    if (decoded is! List) {
      throw const FormatException('Iteration dataset must be a JSON array of objects.');
    }

    final result = <Map<String, dynamic>>[];
    for (final item in decoded) {
      if (item is Map) {
        result.add(item.map((k, v) => MapEntry(k.toString(), v)));
      }
    }
    return result;
  }

  /// Automatically parses either CSV or JSON data based on content
  static List<Map<String, dynamic>> parseAuto(String text) {
    final trimmed = text.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      try {
        return parseJsonArray(trimmed);
      } catch (_) {
        // Fall back to CSV if JSON array parsing fails
      }
    }
    return parse(trimmed);
  }

  static List<List<String>> _parseRows(String text) {
    final rows = <List<String>>[];
    final currentField = StringBuffer();
    final currentRow = <String>[];
    bool inQuotes = false;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == '"') {
        if (inQuotes && i + 1 < text.length && text[i + 1] == '"') {
          // Escaped quote
          currentField.write('"');
          i++; // Skip the next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        currentRow.add(currentField.toString());
        currentField.clear();
      } else if ((char == '\n' || char == '\r') && !inQuotes) {
        // Handle CRLF or LF
        if (char == '\r' && i + 1 < text.length && text[i + 1] == '\n') {
          i++;
        }
        currentRow.add(currentField.toString());
        currentField.clear();
        rows.add(List.from(currentRow));
        currentRow.clear();
      } else {
        currentField.write(char);
      }
    }

    // Add remaining field and row
    if (currentField.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentField.toString());
      rows.add(currentRow);
    }

    return rows;
  }

  static dynamic _inferType(String val) {
    if (val.isEmpty) return '';
    if (val.toLowerCase() == 'true') return true;
    if (val.toLowerCase() == 'false') return false;
    if (val.toLowerCase() == 'null') return null;

    final intVal = int.tryParse(val);
    if (intVal != null) return intVal;

    final doubleVal = double.tryParse(val);
    if (doubleVal != null) return doubleVal;

    return val;
  }
}
