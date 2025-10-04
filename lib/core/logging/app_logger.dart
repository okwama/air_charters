import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Log levels for different types of messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Log categories for organizing logs
enum LogCategory {
  auth,
  booking,
  payment,
  network,
  navigation,
  validation,
  pricing,
  error,
  performance,
  user,
}

/// Comprehensive logging service for the application
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  /// Log a message with specified level and category
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    LogCategory category = LogCategory.error,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
    String? userId,
    String? sessionId,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelString = level.name.toUpperCase();
    final categoryString = category.name.toUpperCase();

    // Create log entry
    final logEntry = {
      'timestamp': timestamp,
      'level': levelString,
      'category': categoryString,
      'message': message,
      if (userId != null) 'userId': userId,
      if (sessionId != null) 'sessionId': sessionId,
      if (data != null) 'data': data,
      if (error != null) 'error': error.toString(),
    };

    // Format log message
    final formattedMessage = _formatLogMessage(logEntry);

    // Log to console in debug mode
    if (kDebugMode) {
      _logToConsole(formattedMessage, level, error, stackTrace);
    }

    // Log to developer console
    developer.log(
      formattedMessage,
      name: 'AirCharters',
      level: _getDeveloperLogLevel(level),
      error: error,
      stackTrace: stackTrace,
    );

    // In production, you might want to send logs to a remote service
    if (kReleaseMode) {
      _logToRemoteService(logEntry);
    }
  }

  /// Log debug message
  void debug(String message,
      {LogCategory category = LogCategory.error, Map<String, dynamic>? data, required String context}) {
    log(message, level: LogLevel.debug, category: category, data: data);
  }

  /// Log info message
  void info(String message,
      {LogCategory category = LogCategory.error, Map<String, dynamic>? data, required String context}) {
    log(message, level: LogLevel.info, category: category, data: data);
  }

  /// Log warning message
  void warning(String message,
      {LogCategory category = LogCategory.error, Map<String, dynamic>? data}) {
    log(message, level: LogLevel.warning, category: category, data: data);
  }

  /// Log error message
  void error(String message,
      {LogCategory category = LogCategory.error,
      Object? error,
      StackTrace? stackTrace,
      Map<String, dynamic>? data,
      required String context,
      Map<String, dynamic>? metadata}) {
    log(message,
        level: LogLevel.error,
        category: category,
        error: error,
        stackTrace: stackTrace,
        data: data);
  }

  /// Log critical message
  void critical(String message,
      {LogCategory category = LogCategory.error,
      Object? error,
      StackTrace? stackTrace,
      Map<String, dynamic>? data,
      required String context}) {
    log(message,
        level: LogLevel.critical,
        category: category,
        error: error,
        stackTrace: stackTrace,
        data: data);
  }

  /// Log booking-related events
  void logBooking(String message,
      {LogLevel level = LogLevel.info,
      Map<String, dynamic>? data,
      String? userId}) {
    log(message,
        level: level,
        category: LogCategory.booking,
        data: data,
        userId: userId);
  }

  /// Log payment-related events
  void logPayment(String message,
      {LogLevel level = LogLevel.info,
      Map<String, dynamic>? data,
      String? userId}) {
    log(message,
        level: level,
        category: LogCategory.payment,
        data: data,
        userId: userId);
  }

  /// Log authentication events
  void logAuth(String message,
      {LogLevel level = LogLevel.info,
      Map<String, dynamic>? data,
      String? userId}) {
    log(message,
        level: level, category: LogCategory.auth, data: data, userId: userId);
  }

  /// Log network events
  void logNetwork(String message,
      {LogLevel level = LogLevel.info, Map<String, dynamic>? data}) {
    log(message, level: level, category: LogCategory.network, data: data);
  }

  /// Log performance metrics
  void logPerformance(String message, {Map<String, dynamic>? data}) {
    log(message,
        level: LogLevel.info, category: LogCategory.performance, data: data);
  }

  /// Log user actions
  void logUserAction(String action,
      {Map<String, dynamic>? data, String? userId}) {
    log('User action: $action',
        level: LogLevel.info,
        category: LogCategory.user,
        data: data,
        userId: userId);
  }

  /// Format log message for console output
  String _formatLogMessage(Map<String, dynamic> logEntry) {
    final buffer = StringBuffer();
    buffer.write('[${logEntry['timestamp']}] ');
    buffer.write('${logEntry['level']} ');
    buffer.write('${logEntry['category']}: ');
    buffer.write(logEntry['message']);

    if (logEntry['userId'] != null) {
      buffer.write(' | User: ${logEntry['userId']}');
    }

    if (logEntry['data'] != null) {
      buffer.write(' | Data: ${logEntry['data']}');
    }

    return buffer.toString();
  }

  /// Log to console with appropriate formatting
  void _logToConsole(
      String message, LogLevel level, Object? error, StackTrace? stackTrace) {
    switch (level) {
      case LogLevel.debug:
        print('🐛 $message');
        break;
      case LogLevel.info:
        print('ℹ️ $message');
        break;
      case LogLevel.warning:
        print('⚠️ $message');
        break;
      case LogLevel.error:
        print('❌ $message');
        if (error != null) print('Error: $error');
        if (stackTrace != null) print('Stack: $stackTrace');
        break;
      case LogLevel.critical:
        print('🚨 $message');
        if (error != null) print('Error: $error');
        if (stackTrace != null) print('Stack: $stackTrace');
        break;
    }
  }

  /// Convert LogLevel to developer log level
  int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }

  /// Log to remote service (implement based on your needs)
  void _logToRemoteService(Map<String, dynamic> logEntry) {
    // In production, you might want to send logs to:
    // - Firebase Crashlytics
    // - Sentry
    // - Custom logging service
    // - CloudWatch
    // etc.

    // For now, we'll just store locally or send to a simple endpoint
    _storeLogLocally(logEntry);
  }

  /// Store log locally (for debugging or offline scenarios)
  void _storeLogLocally(Map<String, dynamic> logEntry) {
    // You could implement local storage here
    // For example, using shared_preferences or a local database
    // This is useful for debugging issues that occur offline
  }

  /// Log API request
  void logApiRequest(String method, String url,
      {Map<String, dynamic>? headers, Map<String, dynamic>? body}) {
    logNetwork('API Request: $method $url', data: {
      'method': method,
      'url': url,
      if (headers != null) 'headers': headers,
      if (body != null) 'body': body,
    });
  }

  /// Log API response
  void logApiResponse(String method, String url, int statusCode,
      {Map<String, dynamic>? data, Duration? duration}) {
    final level = statusCode >= 400 ? LogLevel.error : LogLevel.info;
    logNetwork('API Response: $method $url - $statusCode', level: level, data: {
      'method': method,
      'url': url,
      'statusCode': statusCode,
      if (data != null) 'responseData': data,
      if (duration != null) 'duration': duration.inMilliseconds,
    });
  }

  /// Log performance timing
  void logTiming(String operation, Duration duration,
      {Map<String, dynamic>? data}) {
    logPerformance('$operation took ${duration.inMilliseconds}ms', data: {
      'operation': operation,
      'duration': duration.inMilliseconds,
      if (data != null) ...data,
    });
  }

  /// Log error with context
  void logErrorWithContext(String message, Object error, StackTrace stackTrace,
      {Map<String, dynamic>? context}) {
    critical(message,
        error: error,
        stackTrace: stackTrace,
        data: context,
        context: 'ErrorContext');
  }
}

/// Extension to add logging to any class
extension LoggingExtension on Object {
  AppLogger get logger => AppLogger();
}

/// Performance timer for measuring operation duration
class PerformanceTimer {
  final String operation;
  final DateTime startTime;
  final Map<String, dynamic>? data;

  PerformanceTimer(this.operation, {this.data}) : startTime = DateTime.now();

  /// End the timer and log the duration
  void end() {
    final duration = DateTime.now().difference(startTime);
    AppLogger().logTiming(operation, duration, data: data);
  }
}

/// Helper function to measure performance
T measurePerformance<T>(String operation, T Function() function,
    {Map<String, dynamic>? data}) {
  final timer = PerformanceTimer(operation, data: data);
  try {
    final result = function();
    timer.end();
    return result;
  } catch (e) {
    timer.end();
    rethrow;
  }
}
