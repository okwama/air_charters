import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, DateTime> _timers = {};
  final List<PerformanceMetric> _metrics = [];

  /// Start timing an operation
  void startTimer(String operation) {
    if (kDebugMode) {
      _timers[operation] = DateTime.now();
      dev.log('⏱️  Started: $operation', name: 'Performance');
    }
  }

  /// End timing an operation
  void endTimer(String operation) {
    if (kDebugMode && _timers.containsKey(operation)) {
      final duration = DateTime.now().difference(_timers[operation]!);
      _metrics.add(PerformanceMetric(
        operation: operation,
        duration: duration,
        timestamp: DateTime.now(),
      ));
      
      dev.log('✅ Completed: $operation (${duration.inMilliseconds}ms)', 
          name: 'Performance');
      
      _timers.remove(operation);
    }
  }

  /// Log a custom metric
  void logMetric(String name, dynamic value, {String? unit}) {
    if (kDebugMode) {
      final metric = PerformanceMetric(
        operation: name,
        duration: Duration.zero,
        timestamp: DateTime.now(),
        customValue: value,
        unit: unit,
      );
      
      _metrics.add(metric);
      dev.log('📊 Metric: $name = $value${unit ?? ''}', name: 'Performance');
    }
  }

  /// Track widget build time
  T trackWidgetBuild<T>(String widgetName, T Function() buildFunction) {
    startTimer('Widget Build: $widgetName');
    final result = buildFunction();
    endTimer('Widget Build: $widgetName');
    return result;
  }

  /// Track async operations
  Future<T> trackAsyncOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTimer(operationName);
    try {
      final result = await operation();
      endTimer(operationName);
      return result;
    } catch (e) {
      endTimer(operationName);
      logMetric('Error: $operationName', e.toString());
      rethrow;
    }
  }

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    if (!kDebugMode) return {};

    final now = DateTime.now();
    final recent = _metrics.where((m) => 
        now.difference(m.timestamp).inMinutes < 5).toList();

    return {
      'total_metrics': _metrics.length,
      'recent_metrics': recent.length,
      'average_duration': _calculateAverageDuration(recent),
      'slowest_operations': _getSlowestOperations(recent),
      'memory_warnings': _getMemoryWarnings(),
    };
  }

  Duration _calculateAverageDuration(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return Duration.zero;
    
    final totalMs = metrics
        .map((m) => m.duration.inMilliseconds)
        .reduce((a, b) => a + b);
    
    return Duration(milliseconds: totalMs ~/ metrics.length);
  }

  List<Map<String, dynamic>> _getSlowestOperations(
      List<PerformanceMetric> metrics) {
    return metrics
        .where((m) => m.duration.inMilliseconds > 100)
        .map((m) => {
              'operation': m.operation,
              'duration_ms': m.duration.inMilliseconds,
              'timestamp': m.timestamp.toIso8601String(),
            })
        .toList()
      ..sort((a, b) => b['duration_ms'].compareTo(a['duration_ms']));
  }

  List<String> _getMemoryWarnings() {
    // This would need platform-specific implementation
    // For now, return empty list
    return [];
  }

  /// Clear old metrics to prevent memory leaks
  void cleanup() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    _metrics.removeWhere((m) => m.timestamp.isBefore(cutoff));
  }

  /// Log app startup metrics
  void logAppStartup() {
    if (kDebugMode) {
      logMetric('App Startup', 'Completed');
      dev.log('🚀 App startup complete', name: 'Performance');
    }
  }

  /// Log navigation events
  void logNavigation(String from, String to) {
    if (kDebugMode) {
      logMetric('Navigation', '$from -> $to');
    }
  }

  /// Track frame render times
  void trackFrameMetrics() {
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // This would require more sophisticated frame timing
        // For now, just log that we're tracking
        dev.log('📱 Frame rendered', name: 'Performance');
      });
    }
  }
}

class PerformanceMetric {
  final String operation;
  final Duration duration;
  final DateTime timestamp;
  final dynamic customValue;
  final String? unit;

  PerformanceMetric({
    required this.operation,
    required this.duration,
    required this.timestamp,
    this.customValue,
    this.unit,
  });
}

/// Widget wrapper for performance monitoring
class PerformanceWrapper extends StatelessWidget {
  final Widget child;
  final String operationName;

  const PerformanceWrapper({
    super.key,
    required this.child,
    required this.operationName,
  });

  @override
  Widget build(BuildContext context) {
    return PerformanceMonitor().trackWidgetBuild(
      operationName,
      () => child,
    );
  }
}

/// Mixin for tracking widget performance
mixin PerformanceTracking<T extends StatefulWidget> on State<T> {
  late final PerformanceMonitor _monitor = PerformanceMonitor();

  @override
  void initState() {
    super.initState();
    _monitor.startTimer('${widget.runtimeType} Init');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _monitor.endTimer('${widget.runtimeType} Init');
  }

  @override
  void dispose() {
    _monitor.logMetric('${widget.runtimeType}', 'Disposed');
    super.dispose();
  }

  void trackOperation(String name, VoidCallback operation) {
    _monitor.startTimer(name);
    operation();
    _monitor.endTimer(name);
  }

  Future<T> trackAsyncOperation<T>(
    String name,
    Future<T> Function() operation,
  ) {
    return _monitor.trackAsyncOperation(name, operation);
  }
}