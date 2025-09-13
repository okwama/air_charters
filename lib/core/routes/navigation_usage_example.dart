import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/core/providers/navigation_provider.dart';
import 'package:air_charters/core/routes/app_routes.dart';
import 'package:air_charters/main.dart';

/// Example usage of the new navigation tracking system
/// This file demonstrates how to use the enhanced navigation features
class NavigationUsageExample {
  
  /// Example 1: Navigate using route constants
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.login);
  }

  /// Example 2: Navigate with arguments
  static void navigateToBookingDetail(BuildContext context, dynamic deal) {
    Navigator.of(context).pushNamed(
      AppRoutes.bookingDetail,
      arguments: deal,
    );
  }

  /// Example 3: Record external navigation for analytics
  static void recordCustomNavigation(BuildContext context, String routeName) {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.recordExternalNavigation(
      routeName,
      metadata: {
        'source': 'custom_navigation',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Example 4: Get navigation statistics
  static Map<String, dynamic> getNavigationStats(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    return navigationProvider.getNavigationStats();
  }

  /// Example 5: Get most visited routes
  static List<MapEntry<String, int>> getMostVisitedRoutes(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    return navigationProvider.getMostVisitedRoutes(limit: 10);
  }

  /// Example 6: Access route observer analytics
  static Map<String, dynamic> getRouteObserverStats() {
    final routeObserver = MyApp.routeObserver;
    return routeObserver.getNavigationStats();
  }

  /// Example 7: Check if route exists
  static bool isRouteValid(String routeName) {
    return AppRoutes.routeExists(routeName);
  }

  /// Example 8: Get route category
  static String getRouteCategory(String routeName) {
    return AppRoutes.getRouteCategory(routeName);
  }

  /// Example 9: Export navigation data
  static Map<String, dynamic> exportAllNavigationData(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    return navigationProvider.exportNavigationData();
  }

  /// Example 10: Clear navigation history
  static void clearNavigationHistory(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.clearNavigationHistory();
  }
}

/// Example widget that demonstrates navigation tracking
class NavigationTrackingExample extends StatelessWidget {
  const NavigationTrackingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        final stats = navigationProvider.getNavigationStats();
        final mostVisited = navigationProvider.getMostVisitedRoutes(limit: 5);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Navigation Tracking'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Route: ${stats['currentRoute'] ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Navigation History:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: navigationProvider.navigationHistory.length,
                    itemBuilder: (context, index) {
                      final route = navigationProvider.navigationHistory[index];
                      return ListTile(
                        title: Text(AppRoutes.getRouteDisplayName(route)),
                        subtitle: Text(route),
                        trailing: Text(AppRoutes.getRouteCategory(route)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Most Visited Routes:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...mostVisited.map((entry) => ListTile(
                  title: Text(AppRoutes.getRouteDisplayName(entry.key)),
                  subtitle: Text('${entry.value} visits'),
                  trailing: Text(AppRoutes.getRouteCategory(entry.key)),
                )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final data = NavigationUsageExample.exportAllNavigationData(context);
                          // You can save this data or send it to analytics
                          print('Navigation data: $data');
                        },
                        child: const Text('Export Data'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          NavigationUsageExample.clearNavigationHistory(context);
                        },
                        child: const Text('Clear History'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
