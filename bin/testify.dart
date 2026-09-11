import 'dart:io';
import 'dart:convert';
import '../lib/core/utils/flow_json_parser.dart';
import '../lib/core/utils/csv_parser.dart';
import '../lib/data/services/http_service.dart';
import '../lib/infrastructure/flow_engine/flow_executor.dart';
import '../lib/infrastructure/flow_engine/iteration_runner.dart';
import '../lib/domain/entities/flow.dart' as entities;

// ANSI Terminal Colors
const String cReset = '\x1B[0m';
const String cBold = '\x1B[1m';
const String cGreen = '\x1B[32m';
const String cRed = '\x1B[31m';
const String cYellow = '\x1B[33m';
const String cBlue = '\x1B[34m';
const String cCyan = '\x1B[36m';
const String cDim = '\x1B[2m';

void main(List<String> args) async {
  if (args.isEmpty || args.contains('--help') || args.contains('-h') || args[0] == 'help') {
    _printHelp();
    exit(0);
  }

  final command = args[0].toLowerCase();

  switch (command) {
    case 'run':
      await _runFlow(args.sublist(1));
      break;
    case 'validate':
      _validateFlow(args.sublist(1));
      break;
    default:
      print('${cRed}Unknown command: $command$cReset');
      _printHelp();
      exit(1);
  }
}

void _printHelp() {
  print('''
${cBold}${cCyan}🚀 TestifyPro Headless CLI Runner${cReset}
Run API Flows and Postman Collections in Terminal and CI/CD pipelines (Newman-compatible).

${cBold}USAGE:${cReset}
  dart run bin/testify.dart run <flow.json> [options]
  dart run bin/testify.dart validate <flow.json>

${cBold}COMMANDS:${cReset}
  run <file>         Execute a Flow JSON or Postman Collection
  validate <file>    Validate syntax and structure of a Flow or Postman file
  help               Show this help message

${cBold}OPTIONS FOR RUN:${cReset}
  -d, --data <file>         Attach CSV or JSON dataset for data-driven iterations
  -e, --env <file>          Load environment variables JSON file
  -n, --iterations <count>  Override number of iterations to execute
  --delay <ms>              Delay between requests in milliseconds (default: 0)
  --bail                    Halt entire execution on first step failure
  -o, --output <file>       Export detailed test run report to JSON file
  -v, --verbose             Display detailed request/response payloads

${cBold}EXAMPLES:${cReset}
  dart run bin/testify.dart run example/sample_flow.json
  dart run bin/testify.dart run example/rate_chart_automation_collection.json --data data.csv
  dart run bin/testify.dart run flow.json --bail --output report.json
''');
}

void _validateFlow(List<String> args) {
  if (args.isEmpty) {
    print('${cRed}Error: Please specify the path to a Flow JSON file.$cReset');
    exit(1);
  }

  final filePath = args[0];
  final file = File(filePath);
  if (!file.existsSync()) {
    print('${cRed}Error: File not found: $filePath$cReset');
    exit(1);
  }

  print('${cBold}Validating $filePath...$cReset');
  final content = file.readAsStringSync();
  final result = FlowJsonParser.validateJson(content);

  if (result.isValid && result.flow != null) {
    final flow = result.flow!;
    print('${cGreen}✓ Valid Flow File!$cReset');
    print('  Flow Name : ${flow.name}');
    print('  Steps     : ${flow.steps.length}');
    print('  Variables : ${flow.variables.keys.join(", ")}');
    exit(0);
  } else {
    print('${cRed}✗ Invalid Flow File:${cReset}');
    for (final err in result.errors) {
      print('  - $err');
    }
    exit(1);
  }
}

Future<void> _runFlow(List<String> args) async {
  if (args.isEmpty) {
    print('${cRed}Error: Please specify the Flow file to run.$cReset');
    print('Usage: dart run bin/testify.dart run <flow.json> [options]');
    exit(1);
  }

  String? flowPath;
  String? dataPath;
  String? envPath;
  String? outputPath;
  int? maxIterations;
  int delayMs = 0;
  bool bail = false;
  bool verbose = false;

  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '-d' || arg == '--data') {
      if (i + 1 < args.length) dataPath = args[++i];
    } else if (arg == '-e' || arg == '--env') {
      if (i + 1 < args.length) envPath = args[++i];
    } else if (arg == '-o' || arg == '--output') {
      if (i + 1 < args.length) outputPath = args[++i];
    } else if (arg == '-n' || arg == '--iterations') {
      if (i + 1 < args.length) maxIterations = int.tryParse(args[++i]);
    } else if (arg == '--delay') {
      if (i + 1 < args.length) delayMs = int.tryParse(args[++i]) ?? 0;
    } else if (arg == '--bail') {
      bail = true;
    } else if (arg == '-v' || arg == '--verbose') {
      verbose = true;
    } else if (!arg.startsWith('-') && flowPath == null) {
      flowPath = arg;
    }
  }

  if (flowPath == null) {
    print('${cRed}Error: Missing flow file argument.$cReset');
    exit(1);
  }

  final flowFile = File(flowPath);
  if (!flowFile.existsSync()) {
    print('${cRed}Error: Flow file not found: $flowPath$cReset');
    exit(1);
  }

  // Parse flow
  final flowContent = flowFile.readAsStringSync();
  final validation = FlowJsonParser.validateJson(flowContent);
  if (!validation.isValid || validation.flow == null) {
    print('${cRed}Error: Failed to parse flow: ${validation.errors.join("; ")}$cReset');
    exit(1);
  }

  var flow = validation.flow!;

  // Load environment variables if specified
  if (envPath != null) {
    final envFile = File(envPath);
    if (!envFile.existsSync()) {
      print('${cRed}Error: Environment file not found: $envPath$cReset');
      exit(1);
    }
    try {
      final envContent = jsonDecode(envFile.readAsStringSync());
      final envVars = <String, String>{};
      if (envContent is Map) {
        if (envContent['values'] is List) {
          for (final v in envContent['values'] as List) {
            if (v is Map && v['key'] != null) {
              envVars[v['key'].toString()] = v['value']?.toString() ?? '';
            }
          }
        } else {
          envContent.forEach((k, v) => envVars[k.toString()] = v?.toString() ?? '');
        }
      }
      final merged = Map<String, String>.from(flow.variables)..addAll(envVars);
      flow = flow.copyWith(variables: merged);
      print('${cDim}Loaded ${envVars.length} environment variables from $envPath$cReset');
    } catch (e) {
      print('${cYellow}Warning: Failed to load environment file: $e$cReset');
    }
  }

  // Load iteration dataset if specified
  List<Map<String, dynamic>> iterationData = [];
  if (dataPath != null) {
    final dataFile = File(dataPath);
    if (!dataFile.existsSync()) {
      print('${cRed}Error: Data file not found: $dataPath$cReset');
      exit(1);
    }
    try {
      final dataContent = dataFile.readAsStringSync();
      iterationData = CsvParser.parseAuto(dataContent);
      print('${cDim}Loaded ${iterationData.length} iteration rows from $dataPath$cReset');
    } catch (e) {
      print('${cRed}Error: Failed to parse data file: $e$cReset');
      exit(1);
    }
  }

  // Banner
  final totalIter = iterationData.isNotEmpty
      ? (maxIterations != null && maxIterations < iterationData.length ? maxIterations : iterationData.length)
      : 1;

  print('\n${cBold}${cBlue}=======================================================================$cReset');
  print('${cBold}${cCyan}🚀 TestifyPro CLI Runner$cReset');
  print('Flow       : ${cBold}${flow.name}$cReset');
  print('Steps      : ${flow.steps.length}');
  print('Iterations : $totalIter${iterationData.isNotEmpty ? " (data-driven)" : ""}');
  print('${cBold}${cBlue}=======================================================================$cReset\n');

  final httpService = HttpService();
  final flowExecutor = FlowExecutor(httpService);
  final iterationRunner = IterationRunner(flowExecutor);

  bool allPassed = true;
  int totalRequests = 0;
  int totalPassedSteps = 0;
  int totalFailedSteps = 0;
  final stopwatch = Stopwatch()..start();
  final resultsList = <Map<String, dynamic>>[];

  if (iterationData.isNotEmpty) {
    // Run with IterationRunner
    final summary = await iterationRunner.runWithData(
      flow: flow,
      iterationData: iterationData,
      maxIterations: maxIterations,
      delayBetweenIterationsMs: delayMs,
      stopOnFailure: bail,
      onIterationComplete: (iterResult) {
        final passIcon = iterResult.success ? '${cGreen}✓ PASS$cReset' : '${cRed}✗ FAIL$cReset';
        print('${cBold}Iteration ${iterResult.iterationNumber}/$totalIter $passIcon (${iterResult.durationMs}ms)$cReset');

        for (final stepRes in iterResult.flowResult.stepResults) {
          totalRequests++;
          final code = stepRes.response?.statusCode ?? 0;
          final statusStr = code > 0 ? '$code' : 'ERR';
          final icon = stepRes.success ? '${cGreen}✓$cReset' : '${cRed}✗$cReset';
          final duration = stepRes.endTime.difference(stepRes.startTime).inMilliseconds;

          print('  $icon [$statusStr] ${duration}ms - ${stepRes.stepName}');

          if (!stepRes.success && stepRes.errorMessage != null) {
            print('    ${cRed}↳ ${stepRes.errorMessage}$cReset');
            totalFailedSteps++;
          } else {
            totalPassedSteps++;
          }
        }

        if (!iterResult.success) {
          allPassed = false;
        }
        print('');
      },
    );

    allPassed = summary.allPassed;
  } else {
    // Single iteration run
    final flowResult = await flowExecutor.executeWithTracking(
      flow,
      onStepComplete: (stepRes) {
        totalRequests++;
        final code = stepRes.response?.statusCode ?? 0;
        final statusStr = code > 0 ? '$code' : 'ERR';
        final icon = stepRes.success ? '${cGreen}✓$cReset' : '${cRed}✗$cReset';
        final duration = stepRes.endTime.difference(stepRes.startTime).inMilliseconds;

        print('  $icon [$statusStr] ${duration}ms - ${stepRes.stepName}');

        if (verbose && stepRes.request != null) {
          print('    ${cDim}URL: ${stepRes.request!.url}$cReset');
        }

        if (!stepRes.success && stepRes.errorMessage != null) {
          print('    ${cRed}↳ ${stepRes.errorMessage}$cReset');
          totalFailedSteps++;
        } else {
          totalPassedSteps++;
        }
      },
    );

    allPassed = flowResult.success;
    resultsList.add({
      'iteration': 1,
      'success': flowResult.success,
      'error': flowResult.errorMessage,
      'steps': flowResult.stepResults.map((s) => {
        'name': s.stepName,
        'success': s.success,
        'status': s.response?.statusCode,
        'durationMs': s.endTime.difference(s.startTime).inMilliseconds,
      }).toList(),
    });
  }

  stopwatch.stop();

  // Print Summary Table
  print('${cBold}┌─────────────────────────────────────────────────────────────┐$cReset');
  print('${cBold}│ ${cCyan}TestifyPro Execution Summary${cReset}                                │');
  print('${cBold}├────────────────────────────────────────┬────────────────────┤$cReset');
  _printRow('Total Iterations', '$totalIter');
  _printRow('Overall Outcome', allPassed ? '${cGreen}PASSED$cReset' : '${cRed}FAILED$cReset');
  _printRow('Total Requests Executed', '$totalRequests');
  _printRow('Passed Steps', '${cGreen}$totalPassedSteps$cReset');
  _printRow('Failed Steps', totalFailedSteps > 0 ? '${cRed}$totalFailedSteps$cReset' : '0');
  _printRow('Total Duration', '${stopwatch.elapsedMilliseconds} ms');
  if (totalRequests > 0) {
    _printRow('Avg Request Latency', '${(stopwatch.elapsedMilliseconds / totalRequests).toStringAsFixed(1)} ms');
  }
  print('${cBold}└────────────────────────────────────────┴────────────────────┘$cReset\n');

  // Save report if requested
  if (outputPath != null) {
    try {
      final report = {
        'flow': flow.name,
        'timestamp': DateTime.now().toIso8601String(),
        'passed': allPassed,
        'totalIterations': totalIter,
        'totalRequests': totalRequests,
        'passedSteps': totalPassedSteps,
        'failedSteps': totalFailedSteps,
        'durationMs': stopwatch.elapsedMilliseconds,
      };
      File(outputPath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
      print('${cGreen}✓ Report saved to $outputPath$cReset\n');
    } catch (e) {
      print('${cYellow}Warning: Failed to write output report: $e$cReset\n');
    }
  }

  exit(allPassed ? 0 : 1);
}

void _printRow(String label, String value) {
  final cleanLabel = label.padRight(38);
  print('│ $cleanLabel │ ${value.padLeft(18)} │');
}
