// Core Constants
// Application-wide configuration and constants

class AppConstants {
  // Application Info
  static const String appName = 'Testify Pro';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Production-grade API Testing & Load Testing Tool';

  // HTTP Configuration
  static const int defaultTimeoutMs = 30000;
  static const int maxTimeoutMs = 300000; // 5 minutes
  static const int minTimeoutMs = 1000; // 1 second

  // Load Testing Limits
  static const int maxVirtualUsers = 1000000;
  static const int minVirtualUsers = 1;
  static const int maxDurationSeconds = 86400; // 24 hours
  static const int minDurationSeconds = 1;

  // Worker Pool Configuration
  static const int minWorkers = 2;
  static const int maxWorkers = 16;
  static const int defaultWorkers = 4;

  // Metrics Configuration
  static const int metricsUpdateIntervalMs = 1000; // Update every 1 second
  static const int maxHistoryDataPoints =
      300; // Keep last 5 minutes at 1s intervals

  // Storage
  static const String requestsBoxName = 'requests';
  static const String flowsBoxName = 'flows';
  static const String testRunsBoxName = 'test_runs';
  static const String settingsBoxName = 'settings';

  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;

  // Chart Configuration
  static const int maxChartDataPoints = 60; // Show last 60 seconds

  // Colors (Material 3 will override most of these)
  static const int primaryColorValue = 0xFF6750A4;
  static const int successColorValue = 0xFF4CAF50;
  static const int errorColorValue = 0xFFF44336;
  static const int warningColorValue = 0xFFFF9800;
}
