import 'dart:async';
import 'network_error_handler.dart';

/// Retry configuration for different types of operations
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final List<NetworkErrorType> retryableErrors;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.retryableErrors = const [
      NetworkErrorType.connectionRefused,
      NetworkErrorType.connectionFailed,
      NetworkErrorType.timeout,
      NetworkErrorType.serverError,
    ],
  });

  /// Default retry config for network operations
  static const RetryConfig network = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 10),
    backoffMultiplier: 2.0,
  );

  /// Retry config for payment operations (more conservative)
  static const RetryConfig payment = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 2),
    maxDelay: Duration(seconds: 15),
    backoffMultiplier: 1.5,
  );

  /// Retry config for booking operations (conservative)
  static const RetryConfig booking = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 8),
    backoffMultiplier: 2.0,
  );
}

/// Result of a retry operation
class RetryResult<T> {
  final T? data;
  final bool success;
  final int attempts;
  final String? error;
  final NetworkErrorType? errorType;

  RetryResult({
    this.data,
    required this.success,
    required this.attempts,
    this.error,
    this.errorType,
  });

  factory RetryResult.success(T data, int attempts) {
    return RetryResult(
      data: data,
      success: true,
      attempts: attempts,
    );
  }

  factory RetryResult.failure(
      String error, int attempts, NetworkErrorType? errorType) {
    return RetryResult(
      success: false,
      attempts: attempts,
      error: error,
      errorType: errorType,
    );
  }
}

/// Handles retry logic for network operations
class RetryHandler {
  static final RetryHandler _instance = RetryHandler._internal();
  factory RetryHandler() => _instance;
  RetryHandler._internal();

  final NetworkErrorHandler _errorHandler = NetworkErrorHandler.instance;

  /// Execute a function with retry logic
  Future<RetryResult<T>> executeWithRetry<T>(
    Future<T> Function() operation, {
    RetryConfig config = RetryConfig.network,
    String? operationName,
  }) async {
    int attempts = 0;
    Duration delay = config.initialDelay;

    while (attempts < config.maxAttempts) {
      attempts++;

      try {
        final result = await operation();
        return RetryResult.success(result, attempts);
      } catch (error) {
        final errorType = _errorHandler.handleNetworkError(error);

        // Check if this error is retryable
        if (!config.retryableErrors.contains(errorType) ||
            attempts >= config.maxAttempts) {
          return RetryResult.failure(
            error.toString(),
            attempts,
            errorType,
          );
        }

        // Log retry attempt
        print(
            'Retry attempt $attempts/${config.maxAttempts} for ${operationName ?? 'operation'}: ${error.toString()}');

        // Wait before retrying
        await Future.delayed(delay);

        // Increase delay for next attempt (exponential backoff)
        final nextDelayMs =
            (delay.inMilliseconds * config.backoffMultiplier).toInt();
        delay = Duration(
          milliseconds: nextDelayMs.clamp(
            config.initialDelay.inMilliseconds,
            config.maxDelay.inMilliseconds,
          ),
        );
      }
    }

    return RetryResult.failure(
      'Max retry attempts exceeded',
      attempts,
      NetworkErrorType.unknown,
    );
  }

  /// Execute a function with retry logic and custom error handling
  Future<T?> executeWithRetryAndFallback<T>(
    Future<T> Function() operation, {
    RetryConfig config = RetryConfig.network,
    T? Function()? fallback,
    String? operationName,
  }) async {
    final result = await executeWithRetry(
      operation,
      config: config,
      operationName: operationName,
    );

    if (result.success) {
      return result.data;
    }

    // Try fallback if available
    if (fallback != null) {
      try {
        return fallback();
      } catch (e) {
        print('Fallback also failed: $e');
      }
    }

    return null;
  }

  /// Check if an error is retryable
  bool isRetryableError(dynamic error, RetryConfig config) {
    final errorType = _errorHandler.handleNetworkError(error);
    return config.retryableErrors.contains(errorType);
  }

  /// Get retry delay for a given attempt
  Duration getRetryDelay(int attempt, RetryConfig config) {
    if (attempt <= 1) return config.initialDelay;

    final delay = config.initialDelay.inMilliseconds *
        (config.backoffMultiplier * (attempt - 1));

    return Duration(
      milliseconds: delay
          .clamp(
            config.initialDelay.inMilliseconds,
            config.maxDelay.inMilliseconds,
          )
          .toInt(),
    );
  }
}
