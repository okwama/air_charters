import 'package:flutter/foundation.dart';
import 'package:air_charters/core/routes/app_routes.dart';
import 'package:air_charters/core/routes/route_observer.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  final NavigationAnalytics _analytics = NavigationAnalytics();
  final List<String> _navigationHistory = [];
  String? _currentRoute;

  int get currentIndex => _currentIndex;
  NavigationAnalytics get analytics => _analytics;
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);
  String? get currentRoute => _currentRoute;

  void setCurrentIndex(int index) {
    // Validate index bounds
    final validIndex = index.clamp(0, 3); // 4 tabs: 0-3
    
    if (_currentIndex != validIndex) {
      final previousRoute = getCurrentRouteName();
      
      if (kDebugMode) {
        print('NavigationProvider: Changing index from $_currentIndex to $validIndex');
      }
      
      _currentIndex = validIndex;
      final newRoute = getCurrentRouteName();
      
      // Record navigation analytics
      _recordNavigation(previousRoute, newRoute);
      
      notifyListeners();
    }
  }

  void navigateToTab(int index) {
    setCurrentIndex(index);
  }

  // Initialize the correct tab index for each screen
  void initializeForScreen(String routeName) {
    if (kDebugMode) {
      print('NavigationProvider: Initializing for route: $routeName');
    }
    
    switch (routeName) {
      case '/home':
        setCurrentIndex(0);
        break;
      case '/direct-charter':
        setCurrentIndex(1);
        break;
      case '/trips':
        setCurrentIndex(2);
        break;
      case '/settings':
      case '/profile':
        setCurrentIndex(3);
        break;
      default:
        // Default to home if route is not recognized
        setCurrentIndex(0);
        break;
    }
  }

  // Reset to home tab
  void resetToHome() {
    setCurrentIndex(0);
  }

  // Get the current route name based on index
  String getCurrentRouteName() {
    switch (_currentIndex) {
      case 0:
        return AppRoutes.home;
      case 1:
        return AppRoutes.directCharter;
      case 2:
        return AppRoutes.trips;
      case 3:
        return AppRoutes.settings;
      default:
        return AppRoutes.home;
    }
  }

  // Record navigation for analytics
  void _recordNavigation(String previousRoute, String newRoute) {
    _currentRoute = newRoute;
    _navigationHistory.add(newRoute);
    
    // Record in analytics
    _analytics.recordNavigation(
      routeName: newRoute,
      previousRoute: previousRoute,
      metadata: {
        'tabIndex': _currentIndex,
        'isTabNavigation': true,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    
    if (kDebugMode) {
      print('NavigationProvider: Recorded navigation from $previousRoute to $newRoute');
    }
  }

  // Record external navigation (from other parts of the app)
  void recordExternalNavigation(String routeName, {String? previousRoute, Map<String, dynamic>? metadata}) {
    _currentRoute = routeName;
    _navigationHistory.add(routeName);
    
    _analytics.recordNavigation(
      routeName: routeName,
      previousRoute: previousRoute,
      metadata: metadata,
    );
    
    if (kDebugMode) {
      print('NavigationProvider: Recorded external navigation to $routeName');
    }
  }

  // Get navigation statistics
  Map<String, dynamic> getNavigationStats() {
    return {
      'currentRoute': _currentRoute,
      'currentIndex': _currentIndex,
      'navigationHistory': _navigationHistory,
      'analytics': {
        'totalNavigations': _analytics.navigationHistory.length,
        'uniqueRoutes': _analytics.routeVisitCounts.length,
        'mostVisitedRoutes': _analytics.getMostVisitedRoutes(limit: 5),
        'patterns': _analytics.getNavigationPatterns(),
      },
    };
  }

  // Get most visited routes
  List<MapEntry<String, int>> getMostVisitedRoutes({int limit = 5}) {
    return _analytics.getMostVisitedRoutes(limit: limit);
  }

  // Get navigation patterns
  Map<String, dynamic> getNavigationPatterns() {
    return _analytics.getNavigationPatterns();
  }

  // Clear navigation history
  void clearNavigationHistory() {
    _navigationHistory.clear();
    _analytics.clearData();
    
    if (kDebugMode) {
      print('NavigationProvider: Navigation history cleared');
    }
  }

  // Export navigation data
  Map<String, dynamic> exportNavigationData() {
    return {
      'provider': {
        'currentRoute': _currentRoute,
        'currentIndex': _currentIndex,
        'navigationHistory': _navigationHistory,
      },
      'analytics': _analytics.exportData(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
}
