// Main Application Entry Point
// Initializes Hive, sets up providers, and launches the app

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/global_providers.dart';
import 'core/providers/theme_provider.dart';
import 'presentation/screens/home_screen.dart';

import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Window Manager
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1024, 768),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: TestifyProApp()));
}

class TestifyProApp extends ConsumerWidget {
  const TestifyProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize repository on first build
    ref.read(testRunRepositoryProvider);

    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Testify Pro',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
