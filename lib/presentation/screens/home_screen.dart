// Home Screen - Main Application Shell
// Navigation rail with different testing modes

import 'package:flutter/material.dart';

import '../screens/api_test_screen.dart';
import '../screens/flow_designer_screen.dart';
import '../screens/load_test_screen.dart';
import '../screens/metrics_dashboard_screen.dart';
import '../screens/history_screen.dart';
import '../screens/environment_settings_screen.dart';
import '../../core/constants/app_constants.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<_NavigationItem> _items = [
    _NavigationItem(
      icon: Icons.api,
      label: 'API Testing',
      screen: const ApiTestScreen(),
    ),
    _NavigationItem(
      icon: Icons.account_tree,
      label: 'Flow Designer',
      screen: const FlowDesignerScreen(),
    ),
    _NavigationItem(
      icon: Icons.speed,
      label: 'Load Testing',
      screen: const LoadTestScreen(),
    ),
    _NavigationItem(
      icon: Icons.analytics,
      label: 'Metrics',
      screen: const MetricsDashboardScreen(),
    ),
    _NavigationItem(
      icon: Icons.history,
      label: 'History',
      screen: const HistoryScreen(),
    ),
    _NavigationItem(
      icon: Icons.language,
      label: 'Environments',
      screen: const EnvironmentSettingsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.science, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text(AppConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: _items
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),

          const VerticalDivider(thickness: 1, width: 1),

          // Main content
          Expanded(child: _items[_selectedIndex].screen),
        ],
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;

  _NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
