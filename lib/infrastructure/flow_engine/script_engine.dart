import 'dart:convert';
import 'package:intl/intl.dart';
import '../../domain/entities/api_response.dart';

/// Execution result of running a test or pre-request script
class ScriptExecutionResult {
  final bool success;
  final String? errorMessage;
  final List<String> passedTests;
  final List<String> failedTests;
  final List<String> logs;
  final Map<String, dynamic> modifiedVariables;

  const ScriptExecutionResult({
    required this.success,
    this.errorMessage,
    this.passedTests = const [],
    this.failedTests = const [],
    this.logs = const [],
    this.modifiedVariables = const {},
  });
}

/// Dynamic Script Engine for executing Postman-compatible and custom scripts
/// before and after API requests.
///
/// Features supported:
/// - `pm.globals.set(k, v)`, `pm.globals.get(k)`
/// - `pm.variables.set(k, v)`, `pm.variables.get(k)`
/// - `pm.iterationData.get(k)`
/// - `pm.response.json()`, `pm.response.code`, `pm.response.reason()`
/// - `pm.test(name, fn)`
/// - `pm.expect(actual).to.eql(expected)`
/// - Dynamic date calculations (`calculateDOB(age)`)
/// - Dynamic member creation (`createMembers(familyComp)`)
/// - Arbitrary key-value assignments
class ScriptEngine {
  /// Executes a pre-request script before the HTTP request is dispatched.
  static ScriptExecutionResult executePreRequest({
    required String script,
    required Map<String, dynamic> variables,
    Map<String, dynamic>? iterationData,
  }) {
    if (script.trim().isEmpty) {
      return const ScriptExecutionResult(success: true);
    }

    final logs = <String>[];
    final modifiedVars = Map<String, dynamic>.from(variables);
    final data = iterationData ?? {};

    try {
      // 1. Process iterationData.get calls into variables
      _resolveIterationDataGetters(script, data, modifiedVars, logs);

      // 2. Process calculateDOB(age) or age-based DOB generation
      _processDateCalculations(script, modifiedVars, logs);

      // 3. Process dynamic member payload creation if present
      _processMemberPayloadGeneration(script, modifiedVars, logs);

      // 4. Process direct pm.globals.set / pm.variables.set calls
      _processVariableSetters(script, modifiedVars, logs);

      return ScriptExecutionResult(
        success: true,
        logs: logs,
        modifiedVariables: modifiedVars,
      );
    } catch (e) {
      logs.add('Script Error: $e');
      return ScriptExecutionResult(
        success: false,
        errorMessage: 'Pre-request script error: $e',
        logs: logs,
        modifiedVariables: modifiedVars,
      );
    }
  }

  /// Executes a test script after the response is received.
  static ScriptExecutionResult executeTest({
    required String script,
    required Map<String, dynamic> variables,
    required ApiResponse response,
    Map<String, dynamic>? iterationData,
  }) {
    if (script.trim().isEmpty) {
      return const ScriptExecutionResult(success: true);
    }

    final logs = <String>[];
    final passedTests = <String>[];
    final failedTests = <String>[];
    final modifiedVars = Map<String, dynamic>.from(variables);
    final data = iterationData ?? {};

    Map<String, dynamic>? responseJson;
    try {
      if (response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          responseJson = decoded;
        }
      }
    } catch (_) {
      // Body is not JSON
    }

    try {
      // 1. Extract values from response via script instructions (e.g. actualValue = response.data.total_net_premium)
      _extractResponseValues(script, responseJson, modifiedVars, logs);

      // 2. Check status code assertions in script
      _evaluateStatusCodeAssertions(script, response, passedTests, failedTests, logs);

      // 3. Check expectedValue comparisons (e.g. pm.expect(actualValue).to.eql(expectedValue))
      _evaluateValueAssertions(script, responseJson, modifiedVars, data, passedTests, failedTests, logs);

      // 4. Process variable setters in test script
      _processVariableSetters(script, modifiedVars, logs);

      final isSuccess = failedTests.isEmpty;
      return ScriptExecutionResult(
        success: isSuccess,
        errorMessage: isSuccess ? null : failedTests.join('; '),
        passedTests: passedTests,
        failedTests: failedTests,
        logs: logs,
        modifiedVariables: modifiedVars,
      );
    } catch (e) {
      logs.add('Test script execution error: $e');
      return ScriptExecutionResult(
        success: false,
        errorMessage: 'Test script error: $e',
        failedTests: ['Script execution exception: $e'],
        logs: logs,
        modifiedVariables: modifiedVars,
      );
    }
  }

  // =================== IMPLEMENTATION HELPERS =================== //

  static void _resolveIterationDataGetters(
    String script,
    Map<String, dynamic> iterationData,
    Map<String, dynamic> variables,
    List<String> logs,
  ) {
    // Matches: pm.iterationData.get("key") or pm.iterationData.get('key')
    final pattern = RegExp(r'pm\.iterationData\.get\(\s*["\x27]([^"\x27]+)["\x27]\s*\)');
    for (final m in pattern.allMatches(script)) {
      final key = m.group(1)!.trim();
      if (iterationData.containsKey(key)) {
        final val = iterationData[key];
        variables[key] = val?.toString() ?? '';
        logs.add('pm.iterationData.get("$key") = $val');
      }
    }
  }

  static void _processDateCalculations(
    String script,
    Map<String, dynamic> variables,
    List<String> logs,
  ) {
    // Check if script has calculateDOB function or let age = X
    final ageMatch = RegExp(r'(?:let|var|const)\s+age\s*=\s*(\d+)').firstMatch(script);
    if (ageMatch != null) {
      final age = int.tryParse(ageMatch.group(1)!) ?? 30;
      final now = DateTime.now();
      final birthYear = now.year - age;
      final dob = DateFormat('yyyy-MM-dd').format(DateTime(birthYear, now.month, now.day));

      variables['age'] = age.toString();
      variables['DOB'] = dob;
      logs.add('Calculated DOB for age $age: $dob');
    }
  }

  static void _processMemberPayloadGeneration(
    String script,
    Map<String, dynamic> variables,
    List<String> logs,
  ) {
    if (!script.contains('createMembers') && !script.contains('membersPayload')) {
      return;
    }

    final familyComp = (variables['familyComp'] ?? variables['Family Composition'] ?? '1A').toString().trim();
    final sumInsured = (variables['sumInsured'] ?? variables['Sum Insured'] ?? '500000').toString();
    final dob = (variables['DOB'] ?? '1990-01-01').toString();
    const staticChildDob = '2015-01-01';

    final members = <Map<String, dynamic>>[];

    if (familyComp.contains('P')) {
      // Parents composition: e.g. "1P", "2P"
      final pMatch = RegExp(r'(\d+)P').firstMatch(familyComp);
      final numParents = pMatch != null ? int.tryParse(pMatch.group(1)!) ?? 1 : 1;

      final isParentInLaw = script.contains('MOTHER_IN_LAW') || script.contains('FATHER_IN_LAW');

      if (numParents >= 1) {
        members.add({
          'firstName': 'mother',
          'lastName': 'last',
          'sumInsured': sumInsured,
          'dateOfBirth': dob,
          'relationship': isParentInLaw ? 'MOTHER_IN_LAW' : 'MOTHER',
          'loader_premium': '0',
        });
      }
      if (numParents >= 2) {
        members.add({
          'firstName': 'father',
          'lastName': 'last',
          'sumInsured': sumInsured,
          'dateOfBirth': dob,
          'relationship': isParentInLaw ? 'FATHER_IN_LAW' : 'FATHER',
          'loader_premium': '0',
        });
      }
    } else {
      // Adults + Children composition: e.g. "1A", "2A", "1A+1C", "2A+2C"
      final match = RegExp(r'(\d+)A(?:\+(\d+)C)?').firstMatch(familyComp);
      final numAdults = match != null ? (int.tryParse(match.group(1)!) ?? 1) : 1;
      final numChildren = match != null && match.group(2) != null ? (int.tryParse(match.group(2)!) ?? 0) : 0;

      final fnMatch = RegExp(r'["\x27]firstName["\x27]\s*:\s*["\x27]([^"\x27]+)["\x27]').firstMatch(script);
      final lnMatch = RegExp(r'["\x27]lastName["\x27]\s*:\s*["\x27]([^"\x27]+)["\x27]').firstMatch(script);
      final selfFirst = fnMatch?.group(1) ?? 'Primary';
      final selfLast = lnMatch?.group(1) ?? 'Member';

      if (numAdults >= 1) {
        members.add({
          'firstName': selfFirst,
          'lastName': selfLast,
          'sumInsured': sumInsured,
          'dateOfBirth': dob,
          'relationship': 'SELF',
          'loader_premium': '0',
        });
      }
      if (numAdults >= 2) {
        members.add({
          'firstName': 'Spouse',
          'lastName': 'Member',
          'sumInsured': sumInsured,
          'dateOfBirth': dob,
          'relationship': 'SPOUSE',
          'loader_premium': '0',
        });
      }
      for (int i = 0; i < numChildren; i++) {
        members.add({
          'firstName': 'Child${i + 1}',
          'lastName': 'Member',
          'sumInsured': sumInsured,
          'dateOfBirth': staticChildDob,
          'relationship': 'SON',
          'loader_premium': '0',
        });
      }
    }

    final payloadString = const JsonEncoder.withIndent('  ').convert(members);
    variables['membersPayload'] = payloadString;
    logs.add('Generated ${members.length} members for familyComp "$familyComp"');
  }

  static void _processVariableSetters(
    String script,
    Map<String, dynamic> variables,
    List<String> logs,
  ) {
    // Matches: pm.globals.set("key", "val") or pm.globals.set("key", varName)
    final setRegex = RegExp(r'pm\.(?:globals|variables|environment)\.set\(\s*["\x27]([^"\x27]+)["\x27]\s*,\s*([^,\)\n]+)\)');
    for (final m in setRegex.allMatches(script)) {
      final key = m.group(1)!.trim();
      var rawVal = m.group(2)!.trim();

      // Check if rawVal is a quoted string
      if ((rawVal.startsWith('"') && rawVal.endsWith('"')) ||
          (rawVal.startsWith("'") && rawVal.endsWith("'"))) {
        variables[key] = rawVal.substring(1, rawVal.length - 1);
        logs.add('pm.globals.set("$key", "${variables[key]}")');
      } else if (variables.containsKey(rawVal)) {
        // Variable lookup
        variables[key] = variables[rawVal];
        logs.add('pm.globals.set("$key", "${variables[key]}")');
      }
    }
  }

  static void _extractResponseValues(
    String script,
    Map<String, dynamic>? responseJson,
    Map<String, dynamic> variables,
    List<String> logs,
  ) {
    if (responseJson == null) return;

    // Matches: const actualValue = response.data.total_net_premium;
    final extractRegex = RegExp(r'(?:const|let|var)\s+([a-zA-Z0-9_]+)\s*=\s*response\.([a-zA-Z0-9_\.]+)');
    for (final m in extractRegex.allMatches(script)) {
      final varName = m.group(1)!.trim();
      final pathParts = m.group(2)!.trim().split('.');

      dynamic current = responseJson;
      for (final part in pathParts) {
        if (current is Map) {
          current = current[part];
        } else {
          current = null;
          break;
        }
      }

      if (current != null) {
        variables[varName] = current;
        logs.add('Extracted "$varName" = $current from response');
      }
    }
  }

  static void _evaluateStatusCodeAssertions(
    String script,
    ApiResponse response,
    List<String> passedTests,
    List<String> failedTests,
    List<String> logs,
  ) {
    final statusMatch = RegExp(r'pm\.response\.(?:code\s*[!=]==?\s*|to\.have\.status\()\s*(\d{3})').firstMatch(script);
    if (statusMatch != null) {
      final expectedCode = int.tryParse(statusMatch.group(1)!) ?? 200;
      final testName = 'Verify API Status $expectedCode';
      if (response.statusCode == expectedCode) {
        passedTests.add(testName);
        logs.add('✓ $testName (Status: ${response.statusCode})');
      } else {
        final err = '$testName failed: Expected $expectedCode, got ${response.statusCode}';
        failedTests.add(err);
        logs.add('✗ $err');
      }
    }
  }

  static void _evaluateValueAssertions(
    String script,
    Map<String, dynamic>? responseJson,
    Map<String, dynamic> variables,
    Map<String, dynamic> iterationData,
    List<String> passedTests,
    List<String> failedTests,
    List<String> logs,
  ) {
    // Check if test script has: pm.expect(Number(actualValue)).to.eql(Number(expectedValue))
    if (!script.contains('expect') || !script.contains('to.eql')) {
      return;
    }

    // Identify expectedValue getter (e.g., pm.iterationData.get("20Yrs"))
    final iterMatch = RegExp(r'pm\.iterationData\.get\(\s*["\x27]([^"\x27]+)["\x27]\s*\)').firstMatch(script);
    dynamic expectedVal;
    String expectedLabel = 'expected';

    if (iterMatch != null) {
      final colName = iterMatch.group(1)!.trim();
      expectedLabel = colName;
      expectedVal = iterationData[colName] ?? variables[colName];
    } else {
      final eqlMatch = RegExp(r'to\.eql\((?:Number\()?([^)]+)\)?\)').firstMatch(script);
      if (eqlMatch != null) {
        var rawTarget = eqlMatch.group(1)!.trim();
        if ((rawTarget.startsWith('"') && rawTarget.endsWith('"')) ||
            (rawTarget.startsWith("'") && rawTarget.endsWith("'"))) {
          expectedVal = rawTarget.substring(1, rawTarget.length - 1);
        } else {
          final literalNum = num.tryParse(rawTarget);
          if (literalNum != null) {
            expectedVal = literalNum;
          } else {
            expectedVal = iterationData[rawTarget] ??
                variables[rawTarget] ??
                iterationData['expected'] ??
                variables['expected'];
            expectedLabel = rawTarget;
          }
        }
      }
    }

    // Actual value from variables (like actualValue)
    final actualVal = variables['actualValue'];

    if (actualVal != null && expectedVal != null) {
      final actualNum = num.tryParse(actualVal.toString());
      final expectedNum = num.tryParse(expectedVal.toString());

      final testTitle = 'Premium value validation ($expectedLabel)';

      if (actualNum != null && expectedNum != null) {
        if (actualNum == expectedNum) {
          passedTests.add(testTitle);
          logs.add('✓ $testTitle: Actual ($actualNum) == Expected ($expectedNum)');
        } else {
          final err = '$testTitle: Actual ($actualNum) != Expected ($expectedNum)';
          failedTests.add(err);
          logs.add('✗ $err');
        }
      } else {
        if (actualVal.toString().trim() == expectedVal.toString().trim()) {
          passedTests.add(testTitle);
          logs.add('✓ $testTitle: Matched');
        } else {
          final err = '$testTitle: Actual "$actualVal" != Expected "$expectedVal"';
          failedTests.add(err);
          logs.add('✗ $err');
        }
      }
    }
  }
}
