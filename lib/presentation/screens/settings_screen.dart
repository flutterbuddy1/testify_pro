import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../core/providers/global_providers.dart';
import '../../core/providers/theme_provider.dart';
import '../../domain/entities/environment.dart';
import '../../domain/entities/flow.dart' as entities;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Version info
  final String _appVersion = '1.0.0+1';

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme for the application'),
            value: isDark,
            onChanged: (val) {
              ref.read(themeProvider.notifier).toggleTheme(val);
            },
            secondary: const Icon(Icons.dark_mode),
          ),

          const Divider(),
          _buildSectionHeader('Data Management'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export All Data'),
            subtitle: const Text(
              'Backup flows and environments to a JSON file',
            ),
            onTap: _exportAllData,
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import Data'),
            subtitle: const Text('Restore data from a backup file'),
            onTap: _importData,
          ),

          const Divider(),
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: Text(_appVersion),
            trailing: const Text('Testify Pro'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Developed by'),
            subtitle: const Text(
              'Mayank Diwakar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('GitHub'),
            subtitle: const Text(
              'https://github.com/flutterbuddy1',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            onTap: () => _launchUrl('https://github.com/flutterbuddy1'),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('LinkedIn'),
            subtitle: const Text(
              'https://www.linkedin.com/in/mayankdiwakar-innovator/',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            onTap: () => _launchUrl(
              'https://www.linkedin.com/in/mayankdiwakar-innovator/',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $url: $e')));
      }
    }
  }

  Future<void> _exportAllData() async {
    try {
      // 1. Gather Data
      final flows = await ref.read(flowRepositoryProvider).getAllFlows();
      final envs = await ref
          .read(environmentRepositoryProvider)
          .getAllEnvironments();

      final exportData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'flows': flows.map((f) => f.toJson()).toList(),
        'environments': envs.map((e) => e.toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // 2. Pick File
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Backup',
        fileName:
            'testify_backup_${DateFormat('yyyyMMdd').format(DateTime.now())}.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data exported to $outputFile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importData() async {
    try {
      // 1. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;

        // 2. Restore Data
        int flowsCount = 0;
        int envsCount = 0;

        // Import Flows
        if (data.containsKey('flows')) {
          final flowsList = data['flows'] as List;
          final flowRepo = ref.read(flowRepositoryProvider);
          for (var item in flowsList) {
            try {
              final flow = entities.Flow.fromJson(item);
              await flowRepo.saveFlow(flow);
              flowsCount++;
            } catch (_) {}
          }
        }

        // Import Environments
        if (data.containsKey('environments')) {
          final envsList = data['environments'] as List;
          final envRepo = ref.read(environmentRepositoryProvider);
          for (var item in envsList) {
            try {
              final env = Environment.fromJson(item);
              await envRepo.saveEnvironment(env);
              envsCount++;
            } catch (_) {}
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Imported $flowsCount flows and $envsCount environments',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
