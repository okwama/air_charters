import 'package:flutter/foundation.dart';
import '../error/unified_error_handler.dart';
import '../error/retry_handler.dart';
import '../logging/app_logger.dart';

/// Base provider class with common functionality
abstract class BaseProvider extends ChangeNotifier {
  final AppLogger _logger = AppLogger();
  final UnifiedErrorHandler _errorHandler = UnifiedErrorHandler();
  final RetryHandler _retryHandler = RetryHandler();

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  Map<String, dynamic> _metadata = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get metadata => Map.unmodifiable(_metadata);

  /// Set loading state
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _logger.debug(
        'Loading state changed: $loading',
        context: runtimeType.toString(),
      );
      notifyListeners();
    }
  }

  /// Set error state
  void setError(String? error, {Map<String, dynamic>? metadata}) {
    _hasError = error != null;
    _errorMessage = error;
    if (metadata != null) {
      _metadata = {..._metadata, ...metadata};
    }

    _logger.log(
      'Error state set: $error',
      level: LogLevel.error,
      category: LogCategory.error,
      data: metadata,
    );

    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    if (_hasError) {
      _hasError = false;
      _errorMessage = null;
      _logger.debug(
        'Error state cleared',
        context: runtimeType.toString(),
      );
      notifyListeners();
    }
  }

  /// Set metadata
  void setMetadata(Map<String, dynamic> metadata) {
    _metadata = {..._metadata, ...metadata};
    notifyListeners();
  }

  /// Clear metadata
  void clearMetadata() {
    _metadata.clear();
    notifyListeners();
  }

  /// Execute provider operation with unified error handling
  Future<T?> executeProviderOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    RetryConfig? retryConfig,
    bool showLoading = true,
    bool clearErrorOnStart = true,
    Map<String, dynamic>? metadata,
  }) async {
    final operationName_ = operationName ?? 'PROVIDER_OPERATION';

    _logger.log(
      'Starting provider operation: $operationName_',
      level: LogLevel.info,
      category: LogCategory.user,
      data: metadata,
    );

    try {
      // Set loading state
      if (showLoading) {
        setLoading(true);
      }

      // Clear previous errors
      if (clearErrorOnStart) {
        clearError();
      }

      // Set metadata
      if (metadata != null) {
        setMetadata(metadata);
      }

      // Use retry handler if config provided
      if (retryConfig != null) {
        final result = await retryHandler.executeWithRetry(
          operation,
          config: retryConfig,
          operationName: operationName_,
        );

        if (result.success) {
          _logger.log(
            'Provider operation completed successfully: $operationName_',
            level: LogLevel.info,
            category: LogCategory.user,
          );
          return result.data;
        } else {
          final errorResult = _errorHandler.handleError(
            result.error,
            context: operationName_,
            metadata: metadata,
          );
          setError(errorResult.userMessage, metadata: metadata);
          return null;
        }
      } else {
        // Direct execution without retry
        final result = await operation();
        _logger.log(
          'Provider operation completed successfully: $operationName_',
          level: LogLevel.info,
          category: LogCategory.user,
        );
        return result;
      }
    } catch (error) {
      final errorResult = _errorHandler.handleError(
        error,
        context: operationName_,
        metadata: metadata,
      );

      _logger.log(
        'Provider operation failed: $operationName_',
        level: LogLevel.error,
        category: LogCategory.error,
        error: error,
        data: metadata,
      );

      setError(errorResult.userMessage, metadata: metadata);
      return null;
    } finally {
      // Clear loading state
      if (showLoading) {
        setLoading(false);
      }
    }
  }

  /// Execute provider operation with fallback
  Future<T?> executeWithFallback<T>(
    Future<T> Function() primaryOperation,
    Future<T> Function() fallbackOperation, {
    String? operationName,
    RetryConfig? retryConfig,
    bool showLoading = true,
    Map<String, dynamic>? metadata,
  }) async {
    final operation = operationName ?? 'PROVIDER_OPERATION_WITH_FALLBACK';

    try {
      return await executeProviderOperation<T>(
        primaryOperation,
        operationName: '${operation}_PRIMARY',
        retryConfig: retryConfig,
        showLoading: showLoading,
        metadata: {...?metadata, 'call_type': 'primary'},
      );
    } catch (error) {
      _logger.log(
        'Primary provider operation failed, trying fallback: $operation',
        level: LogLevel.warning,
        category: LogCategory.error,
        data: {...?metadata, 'fallback_triggered': true},
      );

      try {
        return await executeProviderOperation<T>(
          fallbackOperation,
          operationName: '${operation}_FALLBACK',
          retryConfig: retryConfig,
          showLoading: false, // Don't show loading for fallback
          clearErrorOnStart: false, // Don't clear error from primary
          metadata: {...?metadata, 'call_type': 'fallback'},
        );
      } catch (fallbackError) {
        _logger.log(
          'Both primary and fallback provider operations failed: $operation',
          level: LogLevel.error,
          category: LogCategory.error,
          error: fallbackError,
          data: {...?metadata, 'both_calls_failed': true},
        );
        return null;
      }
    }
  }

  /// Refresh provider data
  Future<void> refresh() async {
    _logger.log(
      'Refreshing provider data',
      level: LogLevel.info,
      category: LogCategory.user,
    );
    // Override in specific providers
  }

  /// Reset provider state
  void reset() {
    _isLoading = false;
    _hasError = false;
    _errorMessage = null;
    _metadata.clear();

    _logger.log(
      'Provider state reset',
      level: LogLevel.info,
      category: LogCategory.user,
    );

    notifyListeners();
  }

  /// Get provider health status
  Map<String, dynamic> getProviderHealth() {
    return {
      'provider': runtimeType.toString(),
      'isLoading': _isLoading,
      'hasError': _hasError,
      'errorMessage': _errorMessage,
      'metadata': _metadata,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get default retry config for this provider
  RetryConfig get defaultRetryConfig => RetryConfig.network;

  /// Get retry handler instance
  RetryHandler get retryHandler => _retryHandler;

  /// Get logger instance
  AppLogger get logger => _logger;

  /// Get error handler instance
  UnifiedErrorHandler get errorHandler => _errorHandler;

  @override
  void dispose() {
    _logger.debug(
      'Disposing provider: ${runtimeType.toString()}',
      context: runtimeType.toString(),
    );
    super.dispose();
  }
}
