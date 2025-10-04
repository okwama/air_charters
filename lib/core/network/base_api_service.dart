import '../error/unified_error_handler.dart';
import '../error/retry_handler.dart';
import '../logging/app_logger.dart';
import 'api_client.dart';

/// Base API service with common functionality
abstract class BaseApiService {
  final ApiClient _apiClient = ApiClient();
  final UnifiedErrorHandler _errorHandler = UnifiedErrorHandler();
  final RetryHandler _retryHandler = RetryHandler();
  final AppLogger _logger = AppLogger();

  /// Execute API call with unified error handling and retry logic
  Future<T?> executeApiCall<T>(
    Future<T> Function() apiCall, {
    String? operationName,
    RetryConfig? retryConfig,
    bool logRequest = true,
    Map<String, dynamic>? metadata,
  }) async {
    final operation = operationName ?? 'API_CALL';

    if (logRequest) {
      _logger.log(
        'Starting API operation: $operation',
        level: LogLevel.info,
        category: LogCategory.network,
        data: metadata,
      );
    }

    try {
      // Use retry handler if config provided
      if (retryConfig != null) {
        final result = await _retryHandler.executeWithRetry(
          apiCall,
          config: retryConfig,
          operationName: operation,
        );

        if (result.success) {
          if (logRequest) {
            _logger.log(
              'API operation completed successfully: $operation',
              level: LogLevel.info,
              category: LogCategory.network,
            );
          }
          return result.data;
        } else {
          final errorResult = _errorHandler.handleError(
            result.error,
            context: operation,
            metadata: metadata,
          );
          _logger.log(
            'API operation failed after retries: $operation',
            level: LogLevel.error,
            category: LogCategory.network,
            error: result.error,
            data: metadata,
          );
          throw Exception(errorResult.userMessage);
        }
      } else {
        // Direct execution without retry
        final result = await apiCall();
        if (logRequest) {
          _logger.log(
            'API operation completed successfully: $operation',
            level: LogLevel.info,
            category: LogCategory.network,
          );
        }
        return result;
      }
    } catch (error) {
      final errorResult = _errorHandler.handleError(
        error,
        context: operation,
        metadata: metadata,
      );

      _logger.log(
        'API operation failed: $operation',
        level: LogLevel.error,
        category: LogCategory.network,
        error: error,
        data: metadata,
      );

      throw Exception(errorResult.userMessage);
    }
  }

  /// GET request with unified handling
  Future<T?> get<T>(
    String endpoint, {
    String? operationName,
    RetryConfig? retryConfig,
    bool logRequest = true,
    Map<String, dynamic>? metadata,
  }) async {
    return executeApiCall<T>(
      () => _apiClient.get(endpoint) as Future<T>,
      operationName: operationName ?? 'GET_$endpoint',
      retryConfig: retryConfig,
      logRequest: logRequest,
      metadata: metadata,
    );
  }

  /// POST request with unified handling
  Future<T?> post<T>(
    String endpoint,
    Map<String, dynamic> data, {
    String? operationName,
    RetryConfig? retryConfig,
    bool logRequest = true,
    Map<String, dynamic>? metadata,
  }) async {
    return executeApiCall<T>(
      () => _apiClient.post(endpoint, data) as Future<T>,
      operationName: operationName ?? 'POST_$endpoint',
      retryConfig: retryConfig,
      logRequest: logRequest,
      metadata: {...?metadata, 'data': data},
    );
  }

  /// PUT request with unified handling
  Future<T?> put<T>(
    String endpoint,
    Map<String, dynamic> data, {
    String? operationName,
    RetryConfig? retryConfig,
    bool logRequest = true,
    Map<String, dynamic>? metadata,
  }) async {
    return executeApiCall<T>(
      () => _apiClient.put(endpoint, data) as Future<T>,
      operationName: operationName ?? 'PUT_$endpoint',
      retryConfig: retryConfig,
      logRequest: logRequest,
      metadata: {...?metadata, 'data': data},
    );
  }

  /// DELETE request with unified handling
  Future<T?> delete<T>(
    String endpoint, {
    String? operationName,
    RetryConfig? retryConfig,
    bool logRequest = true,
    Map<String, dynamic>? metadata,
  }) async {
    return executeApiCall<T>(
      () => _apiClient.delete(endpoint) as Future<T>,
      operationName: operationName ?? 'DELETE_$endpoint',
      retryConfig: retryConfig,
      logRequest: logRequest,
      metadata: metadata,
    );
  }

  /// Batch API calls with unified error handling
  Future<List<T?>> executeBatchApiCalls<T>(
    List<Future<T> Function()> apiCalls, {
    String? operationName,
    RetryConfig? retryConfig,
    bool failFast = false,
    Map<String, dynamic>? metadata,
  }) async {
    final operation = operationName ?? 'BATCH_API_CALLS';
    final results = <T?>[];

    _logger.log(
      'Starting batch API operation: $operation (${apiCalls.length} calls)',
      level: LogLevel.info,
      category: LogCategory.network,
      data: metadata,
    );

    for (int i = 0; i < apiCalls.length; i++) {
      try {
        final result = await executeApiCall<T>(
          apiCalls[i],
          operationName: '${operation}_$i',
          retryConfig: retryConfig,
          logRequest: false,
          metadata: {...?metadata, 'batch_index': i},
        );
        results.add(result);

        if (failFast && result == null) {
          _logger.log(
            'Batch operation failed at index $i (failFast enabled)',
            level: LogLevel.warning,
            category: LogCategory.network,
            data: {...?metadata, 'failed_index': i},
          );
          break;
        }
      } catch (error) {
        _logger.log(
          'Batch operation failed at index $i',
          level: LogLevel.error,
          category: LogCategory.network,
          error: error,
          data: {...?metadata, 'failed_index': i},
        );

        if (failFast) {
          rethrow;
        }
        results.add(null);
      }
    }

    _logger.log(
      'Batch API operation completed: $operation (${results.length} results)',
      level: LogLevel.info,
      category: LogCategory.network,
      data: {...?metadata, 'results_count': results.length},
    );

    return results;
  }

  /// Execute API call with fallback
  Future<T?> executeWithFallback<T>(
    Future<T> Function() primaryCall,
    Future<T> Function() fallbackCall, {
    String? operationName,
    RetryConfig? retryConfig,
    Map<String, dynamic>? metadata,
  }) async {
    final operation = operationName ?? 'API_CALL_WITH_FALLBACK';

    try {
      return await executeApiCall<T>(
        primaryCall,
        operationName: '${operation}_PRIMARY',
        retryConfig: retryConfig,
        metadata: {...?metadata, 'call_type': 'primary'},
      );
    } catch (error) {
      _logger.log(
        'Primary API call failed, trying fallback: $operation',
        level: LogLevel.warning,
        category: LogCategory.network,
        data: {...?metadata, 'fallback_triggered': true},
      );

      try {
        return await executeApiCall<T>(
          fallbackCall,
          operationName: '${operation}_FALLBACK',
          retryConfig: retryConfig,
          metadata: {...?metadata, 'call_type': 'fallback'},
        );
      } catch (fallbackError) {
        _logger.log(
          'Both primary and fallback API calls failed: $operation',
          level: LogLevel.error,
          category: LogCategory.network,
          error: fallbackError,
          data: {...?metadata, 'both_calls_failed': true},
        );
        rethrow;
      }
    }
  }

  /// Validate API response
  bool validateApiResponse<T>(T? response, {String? operationName}) {
    if (response == null) {
      _logger.log(
        'API response is null: ${operationName ?? 'UNKNOWN'}',
        level: LogLevel.warning,
        category: LogCategory.network,
      );
      return false;
    }
    return true;
  }

  /// Get default retry config for this service
  RetryConfig get defaultRetryConfig => RetryConfig.network;

  /// Get API client instance (for advanced usage)
  ApiClient get apiClient => _apiClient;

  /// Get error handler instance
  UnifiedErrorHandler get errorHandler => _errorHandler;
}
