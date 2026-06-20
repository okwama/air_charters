import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for handling error recovery and retry mechanisms
class ErrorRecoveryService {
  static const String _errorHistoryKey = 'error_history';
  static const String _retryAttemptsKey = 'retry_attempts';
  static const int _maxRetryAttempts = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// Record an error for analysis and recovery
  static Future<void> recordError({
    required String errorType,
    required String errorMessage,
    String? context,
    Map<String, dynamic>? errorData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing error history
      final errorHistoryJson = prefs.getString(_errorHistoryKey);
      List<Map<String, dynamic>> errorHistory = [];
      
      if (errorHistoryJson != null) {
        errorHistory = (jsonDecode(errorHistoryJson) as List).cast<Map<String, dynamic>>();
      }
      
      // Add new error
      errorHistory.add({
        'errorType': errorType,
        'errorMessage': errorMessage,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
        'data': errorData ?? {},
      });
      
      // Keep only last 100 errors
      if (errorHistory.length > 100) {
        errorHistory = errorHistory.sublist(errorHistory.length - 100);
      }
      
      await prefs.setString(_errorHistoryKey, jsonEncode(errorHistory));
      
      if (kDebugMode) {
        print('ErrorRecoveryService: Recorded error - $errorType: $errorMessage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ErrorRecoveryService: Error recording error: $e');
      }
    }
  }

  /// Get retry attempts for a specific operation
  static Future<int> getRetryAttempts(String operationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final retryAttemptsJson = prefs.getString(_retryAttemptsKey);
      
      if (retryAttemptsJson != null) {
        final retryAttempts = jsonDecode(retryAttemptsJson) as Map<String, dynamic>;
        return retryAttempts[operationId] ?? 0;
      }
    } catch (e) {
      if (kDebugMode) {
        print('ErrorRecoveryService: Error getting retry attempts: $e');
      }
    }
    
    return 0;
  }

  /// Increment retry attempts for a specific operation
  static Future<int> incrementRetryAttempts(String operationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final retryAttemptsJson = prefs.getString(_retryAttemptsKey);
      
      Map<String, dynamic> retryAttempts = {};
      if (retryAttemptsJson != null) {
        retryAttempts = jsonDecode(retryAttemptsJson) as Map<String, dynamic>;
      }
      
      final currentAttempts = (retryAttempts[operationId] ?? 0) + 1;
      retryAttempts[operationId] = currentAttempts;
      
      await prefs.setString(_retryAttemptsKey, jsonEncode(retryAttempts));
      
      if (kDebugMode) {
        print('ErrorRecoveryService: Incremented retry attempts for $operationId: $currentAttempts');
      }
      
      return currentAttempts;
    } catch (e) {
      if (kDebugMode) {
        print('ErrorRecoveryService: Error incrementing retry attempts: $e');
      }
      return 0;
    }
  }

  /// Clear retry attempts for a specific operation
  static Future<void> clearRetryAttempts(String operationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final retryAttemptsJson = prefs.getString(_retryAttemptsKey);
      
      if (retryAttemptsJson != null) {
        final retryAttempts = jsonDecode(retryAttemptsJson) as Map<String, dynamic>;
        retryAttempts.remove(operationId);
        await prefs.setString(_retryAttemptsKey, jsonEncode(retryAttempts));
        
        if (kDebugMode) {
          print('ErrorRecoveryService: Cleared retry attempts for $operationId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('ErrorRecoveryService: Error clearing retry attempts: $e');
      }
    }
  }

  /// Check if operation should be retried
  static Future<bool> shouldRetry(String operationId) async {
    final attempts = await getRetryAttempts(operationId);
    return attempts < _maxRetryAttempts;
  }

  /// Get retry delay with exponential backoff
  static Duration getRetryDelay(int attemptNumber) {
    return Duration(seconds: _retryDelay.inSeconds * (attemptNumber + 1));
  }

  /// Execute operation with retry logic
  static Future<T> executeWithRetry<T>(
    String operationId,
    Future<T> Function() operation, {
    String? errorContext,
    bool Function(dynamic error)? shouldRetryOnError,
  }) async {
    int attempts = 0;
    
    while (attempts < _maxRetryAttempts) {
      try {
        final result = await operation();
        
        // Clear retry attempts on success
        await clearRetryAttempts(operationId);
        
        if (kDebugMode) {
          print('ErrorRecoveryService: Operation $operationId succeeded after $attempts attempts');
        }
        
        return result;
      } catch (error) {
        attempts++;
        
        // Record the error
        await recordError(
          errorType: 'operation_retry',
          errorMessage: error.toString(),
          context: errorContext,
          errorData: {
            'operationId': operationId,
            'attempt': attempts,
            'maxAttempts': _maxRetryAttempts,
          },
        );
        
        // Check if we should retry this specific error
        if (shouldRetryOnError != null && !shouldRetryOnError(error)) {
          if (kDebugMode) {
            print('ErrorRecoveryService: Not retrying $operationId due to error type');
          }
          rethrow;
        }
        
        // Check if we've exceeded max attempts
        if (attempts >= _maxRetryAttempts) {
          if (kDebugMode) {
            print('ErrorRecoveryService: Max retry attempts reached for $operationId');
          }
          rethrow;
        }
        
        // Wait before retry with exponential backoff
        final delay = getRetryDelay(attempts - 1);
        if (kDebugMode) {
          print('ErrorRecoveryService: Retrying $operationId in ${delay.inSeconds}s (attempt $attempts)');
        }
        
        await Future.delayed(delay);
      }
    }
    
    throw Exception('Max retry attempts exceeded for $operationId');
  }

  /// Get error statistics
  static Future<ErrorStatistics> getErrorStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final errorHistoryJson = prefs.getString(_errorHistoryKey);
      
      if (errorHistoryJson == null) {
        return ErrorStatistics.empty();
      }
      
      final errorHistory = (jsonDecode(errorHistoryJson) as List).cast<Map<String, dynamic>>();
      
      // Calculate statistics
      final errorCounts = <String, int>{};
      final contextCounts = <String, int>{};
      final recentErrors = <Map<String, dynamic>>[];
      
      final now = DateTime.now();
      final last24Hours = now.subtract(const Duration(hours: 24));
      
      for (final error in errorHistory) {
        final errorType = error['errorType'] as String;
        final context = error['context'] as String? ?? 'unknown';
        final timestamp = DateTime.tryParse(error['timestamp'] ?? '');
        
        errorCounts[errorType] = (errorCounts[errorType] ?? 0) + 1;
        contextCounts[context] = (contextCounts[context] ?? 0) + 1;
        
        if (timestamp != null && timestamp.isAfter(last24Hours)) {
          recentErrors.add(error);
        }
      }
      
      return ErrorStatistics(
        totalErrors: errorHistory.length,
        recentErrors: recentErrors.length,
        errorTypeCounts: errorCounts,
        contextCounts: contextCounts,
        lastError: errorHistory.isNotEmpty ? errorHistory.last : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('ErrorRecoveryService: Error getting statistics: $e');
      }
      return ErrorStatistics.empty();
    }
  }

  /// Clear all error data
  static Future<void> clearAllErrorData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_errorHistoryKey);
      await prefs.remove(_retryAttemptsKey);
      
      if (kDebugMode) {
        print('ErrorRecoveryService: Cleared all error data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ErrorRecoveryService: Error clearing error data: $e');
      }
    }
  }
}

/// Data class for error statistics
class ErrorStatistics {
  final int totalErrors;
  final int recentErrors;
  final Map<String, int> errorTypeCounts;
  final Map<String, int> contextCounts;
  final Map<String, dynamic>? lastError;

  const ErrorStatistics({
    required this.totalErrors,
    required this.recentErrors,
    required this.errorTypeCounts,
    required this.contextCounts,
    this.lastError,
  });

  factory ErrorStatistics.empty() {
    return const ErrorStatistics(
      totalErrors: 0,
      recentErrors: 0,
      errorTypeCounts: {},
      contextCounts: {},
    );
  }

  /// Get most common error type
  String? get mostCommonErrorType {
    if (errorTypeCounts.isEmpty) return null;
    
    return errorTypeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get most common error context
  String? get mostCommonErrorContext {
    if (contextCounts.isEmpty) return null;
    
    return contextCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get error rate (errors per day)
  double get errorRate {
    if (totalErrors == 0) return 0.0;
    
    // Assuming errors are tracked over the last 30 days
    return totalErrors / 30.0;
  }
}



