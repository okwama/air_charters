import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:air_charters/core/routes/app_routes.dart';

/// Navigation analytics data model
class NavigationEvent {
  final String routeName;
  final String routeCategory;
  final String routeDisplayName;
  final DateTime timestamp;
  final String? previousRoute;
  final Map<String, dynamic>? metadata;

  const NavigationEvent({
    required this.routeName,
    required this.routeCategory,
    required this.routeDisplayName,
    required this.timestamp,
    this.previousRoute,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'routeName': routeName,
    'routeCategory': routeCategory,
    'routeDisplayName': routeDisplayName,
    'timestamp': timestamp.toIso8601String(),
    'previousRoute': previousRoute,
    'metadata': metadata,
  };

  @override
  String toString() {
    return 'NavigationEvent(route: $routeName, category: $routeCategory, time: $timestamp)';
  }
}

/// Navigation analytics service
class NavigationAnalytics {
  static final NavigationAnalytics _instance = NavigationAnalytics._internal();
  factory NavigationAnalytics() => _instance;
  NavigationAnalytics._internal();

  final List<NavigationEvent> _navigationHistory = [];
  final Map<String, int> _routeVisitCounts = {};
  final Map<String, DateTime> _routeFirstVisit = {};
  final Map<String, DateTime> _routeLastVisit = {};

  // Getters
  List<NavigationEvent> get navigationHistory => List.unmodifiable(_navigationHistory);
  Map<String, int> get routeVisitCounts => Map.unmodifiable(_routeVisitCounts);
  Map<String, DateTime> get routeFirstVisit => Map.unmodifiable(_routeFirstVisit);
  Map<String, DateTime> get routeLastVisit => Map.unmodifiable(_routeLastVisit);

  /// Record a navigation event
  void recordNavigation({
    required String routeName,
    String? previousRoute,
    Map<String, dynamic>? metadata,
  }) {
    final event = NavigationEvent(
      routeName: routeName,
      routeCategory: AppRoutes.getRouteCategory(routeName),
      routeDisplayName: AppRoutes.getRouteDisplayName(routeName),
      timestamp: DateTime.now(),
      previousRoute: previousRoute,
      metadata: metadata,
    );

    _navigationHistory.add(event);
    _updateRouteStats(routeName);

    if (kDebugMode) {
      dev.log('Navigation recorded: ${event.toString()}', name: 'NavigationAnalytics');
    }
  }

  /// Update route statistics
  void _updateRouteStats(String routeName) {
    final now = DateTime.now();
    
    // Update visit count
    _routeVisitCounts[routeName] = (_routeVisitCounts[routeName] ?? 0) + 1;
    
    // Update first visit
    if (!_routeFirstVisit.containsKey(routeName)) {
      _routeFirstVisit[routeName] = now;
    }
    
    // Update last visit
    _routeLastVisit[routeName] = now;
  }

  /// Get most visited routes
  List<MapEntry<String, int>> getMostVisitedRoutes({int limit = 10}) {
    final entries = _routeVisitCounts.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  /// Get navigation flow (sequence of routes)
  List<String> getNavigationFlow({int limit = 20}) {
    return _navigationHistory
        .take(limit)
        .map((event) => event.routeName)
        .toList();
  }

  /// Get time spent on each route (approximate)
  Map<String, Duration> getTimeSpentOnRoutes() {
    final Map<String, Duration> timeSpent = {};
    
    for (int i = 0; i < _navigationHistory.length - 1; i++) {
      final currentEvent = _navigationHistory[i];
      final nextEvent = _navigationHistory[i + 1];
      
      final duration = nextEvent.timestamp.difference(currentEvent.timestamp);
      timeSpent[currentEvent.routeName] = (timeSpent[currentEvent.routeName] ?? Duration.zero) + duration;
    }
    
    return timeSpent;
  }

  /// Get navigation patterns
  Map<String, dynamic> getNavigationPatterns() {
    final patterns = <String, dynamic>{};
    
    // Most common navigation sequences
    final sequences = <String, int>{};
    for (int i = 0; i < _navigationHistory.length - 1; i++) {
      final current = _navigationHistory[i].routeName;
      final next = _navigationHistory[i + 1].routeName;
      final sequence = '$current -> $next';
      sequences[sequence] = (sequences[sequence] ?? 0) + 1;
    }
    
    patterns['commonSequences'] = sequences.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    
    // Route categories visited
    final categories = <String, int>{};
    for (final event in _navigationHistory) {
      categories[event.routeCategory] = (categories[event.routeCategory] ?? 0) + 1;
    }
    patterns['categories'] = categories;
    
    // Session duration (if we can determine it)
    if (_navigationHistory.isNotEmpty) {
      final firstVisit = _navigationHistory.first.timestamp;
      final lastVisit = _navigationHistory.last.timestamp;
      patterns['sessionDuration'] = lastVisit.difference(firstVisit).inSeconds;
    }
    
    return patterns;
  }

  /// Clear all analytics data
  void clearData() {
    _navigationHistory.clear();
    _routeVisitCounts.clear();
    _routeFirstVisit.clear();
    _routeLastVisit.clear();
    
    if (kDebugMode) {
      dev.log('Navigation analytics data cleared', name: 'NavigationAnalytics');
    }
  }

  /// Export analytics data
  Map<String, dynamic> exportData() {
    return {
      'navigationHistory': _navigationHistory.map((e) => e.toJson()).toList(),
      'routeVisitCounts': _routeVisitCounts,
      'routeFirstVisit': _routeFirstVisit.map((k, v) => MapEntry(k, v.toIso8601String())),
      'routeLastVisit': _routeLastVisit.map((k, v) => MapEntry(k, v.toIso8601String())),
      'patterns': getNavigationPatterns(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
}

/// Custom route observer for tracking navigation events
class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final NavigationAnalytics _analytics = NavigationAnalytics();
  String? _currentRoute;

  NavigationAnalytics get analytics => _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleRouteChange(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _handleRouteChange(newRoute, oldRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _handleRouteChange(previousRoute, route);
    }
  }

  void _handleRouteChange(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = route.settings.name ?? 'unknown';
    final previousRouteName = previousRoute?.settings.name;
    
    // Skip if it's the same route
    if (routeName == _currentRoute) return;
    
    _currentRoute = routeName;
    
    // Record navigation event
    _analytics.recordNavigation(
      routeName: routeName,
      previousRoute: previousRouteName,
      metadata: {
        'routeType': route.runtimeType.toString(),
        'isFirstRoute': previousRoute == null,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    
    if (kDebugMode) {
      dev.log('Route changed: ${previousRouteName ?? 'none'} -> $routeName', 
          name: 'AppRouteObserver');
    }
  }

  /// Get current route name
  String? get currentRoute => _currentRoute;

  /// Get navigation statistics
  Map<String, dynamic> getNavigationStats() {
    return {
      'totalNavigations': _analytics.navigationHistory.length,
      'uniqueRoutes': _analytics.routeVisitCounts.length,
      'mostVisitedRoutes': _analytics.getMostVisitedRoutes(limit: 5),
      'currentRoute': _currentRoute,
      'navigationFlow': _analytics.getNavigationFlow(limit: 10),
    };
  }
}
