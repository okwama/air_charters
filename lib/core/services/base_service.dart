import '../network/base_api_service.dart';
import '../error/unified_error_handler.dart';
import '../error/retry_handler.dart';
import '../logging/app_logger.dart';

/// Base service class with common functionality
abstract class BaseService extends BaseApiService {
  final AppLogger _logger = AppLogger();
  final UnifiedErrorHandler _errorHandler = UnifiedErrorHandler();
  final RetryHandler _retryHandler = RetryHandler();

  /// Execute service operation with unified error handling
  Future executeServiceOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    RetryConfig? retryConfig,
    bool logOperation = true,
    Map<String, dynamic>? metadata,
  }) async {
    final operationName_ = operationName ?? 'SERVICE_OPERATION';

    if (logOperation) {
      _logger.log(
        'Starting service operation: $operationName_',
        level: LogLevel.info,
        category: LogCategory.network,
        data: metadata,
      );
    }

    try {
      // Use retry handler if config provided
      if (retryConfig != null) {
        final result = await retryHandler.executeWithRetry(
          operation,
          config: retryConfig,
          operationName: operationName_,
        );

        if (result.success) {
          if (logOperation) {
            _logger.log(
              'Service operation completed successfully: $operationName_',
              level: LogLevel.info,
              category: LogCategory.network,
            );
          }
          return result.data;
        } else {
          final errorResult = _errorHandler.handleError(
            result.error,
            context: operationName_,
            metadata: metadata,
          );
          _logger.log(
            'Service operation failed after retries: $operationName_',
            level: LogLevel.error,
            category: LogCategory.network,
            error: result.error,
            data: metadata,
          );
          throw Exception(errorResult.userMessage);
        }
      } else {
        // Direct execution without retry
        final result = await operation();
        if (logOperation) {
          _logger.log(
            'Service operation completed successfully: $operationName_',
            level: LogLevel.info,
            category: LogCategory.network,
          );
        }
        return result;
      }
    } catch (error) {
      final errorResult = _errorHandler.handleError(
        error,
        context: operationName_,
        metadata: metadata,
      );

      _logger.log(
        'Service operation failed: $operationName_',
        level: LogLevel.error,
        category: LogCategory.network,
        error: error,
        data: metadata,
      );

      throw Exception(errorResult.userMessage);
    }
  }

  /// Validate service input data
  bool validateInput(Map<String, dynamic> data, {String? operationName}) {
    if (data.isEmpty) {
      _logger.log(
        'Empty input data for operation: ${operationName ?? 'UNKNOWN'}',
        level: LogLevel.warning,
        category: LogCategory.validation,
      );
      return false;
    }
    return true;
  }

  /// Transform service response data
  Map<String, dynamic> transformResponse(
    Map<String, dynamic> response, {
    String? operationName,
  }) {
    // Default transformation - services can override
    return response;
  }

  /// Cache service data (implement in specific services)
  Future<void> cacheData(String key, dynamic data, {Duration? ttl}) async {
    // Default implementation - services can override
    _logger.debug(
      'Caching data for key: $key',
      context: runtimeType.toString(),
    );
  }

  /// Get cached service data (implement in specific services)
  Future<T?> getCachedData<T>(String key) async {
    // Default implementation - services can override
    _logger.debug(
      'Getting cached data for key: $key',
      context: runtimeType.toString(),
    );
    return null;
  }

  /// Clear service cache (implement in specific services)
  Future<void> clearCache({String? key}) async {
    // Default implementation - services can override
    _logger.debug(
      'Clearing cache${key != null ? ' for key: $key' : ''}',
      context: runtimeType.toString(),
    );
  }

  /// Check if service is available
  bool get isServiceAvailable => true;

  /// Get service health status
  Map<String, dynamic> getServiceHealth() {
    return {
      'service': runtimeType.toString(),
      'available': isServiceAvailable,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get default retry config for this service
  @override
  RetryConfig get defaultRetryConfig => RetryConfig.network;

  /// Get retry handler instance
  RetryHandler get retryHandler => _retryHandler;

  /// Get logger instance
  AppLogger get logger => _logger;

  /// Get error handler instance
  @override
  UnifiedErrorHandler get errorHandler => _errorHandler;
}
