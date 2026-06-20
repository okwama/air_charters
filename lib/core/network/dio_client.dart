import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/env/app_config.dart';
import '../../shared/utils/session_manager.dart';
import '../../core/logging/app_logger.dart';
import '../telemetry/telemetry.dart';

/// Enhanced HTTP client using Dio with automatic caching and retry logic
/// Implements Stale-While-Revalidate (SWR) pattern for instant loading
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  Dio? _dio;
  CacheOptions? _cacheOptions;
  final List<RequestOptions> _replayQueue = [];
  final Uuid _uuid = Uuid();
  // Track retry attempts to prevent infinite loops
  final Map<String, int> _retryAttempts = {};

  /// Initialize Dio with interceptors
  Future<void> initialize() async {
    try {
      // Initialize telemetry (Sentry) if configured
      await Telemetry().init();
      // Configure cache options (SWR pattern)
      // Use in-memory store for Web, Hive for mobile
      CacheStore cacheStore;

      try {
        // Try to get cache directory (works on mobile/desktop)
        final cacheDir = await getTemporaryDirectory();
        cacheStore = HiveCacheStore(cacheDir.path);
        debugPrint('DioClient: Using HiveCacheStore');
      } catch (e) {
        // Fallback for Web platform
        cacheStore = MemCacheStore();
        debugPrint('DioClient: Using MemCacheStore (Web platform)');
      }

      _cacheOptions = CacheOptions(
        store: cacheStore,

        // Cache policy: Stale-While-Revalidate
        policy: CachePolicy.forceCache, // Use cache first

        // TTL: Data is considered stale after 30 seconds
        maxStale: const Duration(seconds: 30),

        // Priority: Always try cache first for instant loading
        priority: CachePriority.high,

        // Cipher: No encryption (data not sensitive)
        cipher: null,

        // Key builder: Cache by full URL + query params
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,

        // Allow null values
        allowPostMethod: false, // Don't cache POST requests
      );

      // Create Dio instance
      _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.backendUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          // 401 should trigger error handler for token refresh retry
          validateStatus: (status) => status != null && status < 500 && status != 401,
        ),
      );

      // Add interceptors (ORDER MATTERS!)
      // Interceptors run in REVERSE order for responses, but FORWARD order for requests
      // So we add them in reverse order of execution:
      
      // 3. Auth interceptor (first to execute on request - add token BEFORE cache check)
      // This ensures auth header is always added before cache interceptor sees the request
      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          try {
            final authHeader = await SessionManager().getAuthorizationHeader();
            if (authHeader != null && authHeader.isNotEmpty) {
              options.headers['Authorization'] = authHeader;
              debugPrint('[DioClient] Authorization header added to ${options.uri}');
            } else {
              debugPrint('[DioClient] No authorization header available for ${options.uri}');
            }
          } catch (e) {
            debugPrint('[DioClient] Error getting auth header: $e');
          }

          // Add idempotency key for mutating requests if not provided
          final method = options.method.toUpperCase();
          final mutatingMethods = {'POST', 'PUT', 'PATCH', 'DELETE'};
          if (mutatingMethods.contains(method)) {
            if (options.headers['Idempotency-Key'] == null) {
              final idKey = _uuid.v4();
              options.headers['Idempotency-Key'] = idKey;
              debugPrint('[DioClient] Added Idempotency-Key: $idKey for ${options.uri}');
            }
          }

          debugPrint('[DioClient] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
              '[DioClient] Response ${response.statusCode}: ${response.requestOptions.uri}');
          
          // Don't cache error responses (403, 404, 500, etc.)
          // Note: 401 is handled in onError for token refresh retry
          if (response.statusCode != null && response.statusCode! >= 400 && response.statusCode != 401) {
            debugPrint('[DioClient] Error response - invalidating cache for ${response.requestOptions.uri}');
            // Invalidate cache for this URL
            invalidateCache(response.requestOptions.path);
          }
          
          return handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
              '[DioClient] Error ${error.response?.statusCode}: ${error.requestOptions.uri}');
          debugPrint('[DioClient] Error message: ${error.message}');
          
          // Handle 401 errors - attempt single-flight token refresh ONCE per request
          if (error.response?.statusCode == 401) {
            final requestKey = error.requestOptions.uri.toString();
            final retryCount = _retryAttempts[requestKey] ?? 0;
            
            // Prevent infinite loops - only retry once per request
            if (retryCount >= 1) {
              debugPrint('[DioClient] Already retried this request, stopping to prevent loop');
              _retryAttempts.remove(requestKey);
              return handler.next(error);
            }
            
            debugPrint('[DioClient] Invalidating cache for 401 error: ${error.requestOptions.uri}');
            invalidateCache(error.requestOptions.path);
            
            try {
              debugPrint('[DioClient] 401 Unauthorized - attempting single-flight token refresh');
              final sessionManager = SessionManager();
              final authData = await sessionManager.getStoredAuthData();

              if (authData != null && authData.refreshToken.isNotEmpty) {
                // Use single-flight refresh to avoid race conditions
                final refreshedAuth = await sessionManager.refreshTokenOnce();

                if (refreshedAuth != null) {
                  final refreshed = refreshedAuth.authorizationHeader;
                  debugPrint('[DioClient] Token refreshed silently, retrying request once');

                  // Prevent auto-replay for non-idempotent methods
                  final method = error.requestOptions.method.toUpperCase();
                  final safeMethods = {'GET', 'HEAD', 'OPTIONS'};
                  if (!safeMethods.contains(method)) {
                    debugPrint('[DioClient] Request method $method is non-idempotent - queuing for manual replay');
                    // Queue the request for later replay (requires backend idempotency support)
                    try {
                      _replayQueue.add(error.requestOptions);
                      AppLogger().logNetwork('Queued non-idempotent request for replay', data: {
                        'url': error.requestOptions.uri.toString(),
                        'idempotencyKey': error.requestOptions.headers['Idempotency-Key']
                      });
                    } catch (e) {
                      debugPrint('[DioClient] Failed to queue request: $e');
                    }

                    // Notify caller of auth error (they can call replayQueuedRequests later)
                    return handler.next(error);
                  }

                  // Mark this request as retried
                  _retryAttempts[requestKey] = retryCount + 1;

                  // Update request with new token
                  error.requestOptions.headers['Authorization'] = refreshed;
                  // Force no cache for retry
                  error.requestOptions.extra['cache'] = false;

                  try {
                    final response = await _dio!.fetch(error.requestOptions);
                    // Success - remove retry counter
                    _retryAttempts.remove(requestKey);
                    AppLogger().logApiResponse(method, error.requestOptions.uri.toString(), response.statusCode ?? 0, data: response.data);
                    return handler.resolve(response);
                  } catch (retryError) {
                    // Retry also failed - remove counter and let error propagate
                    _retryAttempts.remove(requestKey);
                    AppLogger().logNetwork('Retry after refresh failed', data: {'error': retryError.toString()});
                    return handler.next(error);
                  }
                } else {
                  debugPrint('[DioClient] Token refresh returned null - refresh may have failed');
                }
              } else {
                debugPrint('[DioClient] No refresh token available - user needs to login');
              }

              debugPrint('[DioClient] Token refresh failed or not possible - stopping retry');
            } catch (refreshError) {
              debugPrint('[DioClient] Error during token refresh: $refreshError');
            }
            
            // Remove retry counter if we're not retrying
            _retryAttempts.remove(requestKey);
          }
          
          return handler.next(error);
        },
      ));

      // 2. Retry interceptor (second to execute)
      _dio!.interceptors.add(
        RetryInterceptor(
          dio: _dio!,
          retries: 3,
          retryDelays: const [
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
          ],
          retryableExtraStatuses: {408, 429, 503, 504},
        ),
      );

      // 1. Cache interceptor (last to execute - checks cache AFTER auth is added)
      // Configure cache to NOT cache error responses
      final cacheOptionsWithFilter = CacheOptions(
        store: _cacheOptions!.store,
        policy: _cacheOptions!.policy,
        maxStale: _cacheOptions!.maxStale,
        priority: _cacheOptions!.priority,
        cipher: _cacheOptions!.cipher,
        keyBuilder: _cacheOptions!.keyBuilder,
        allowPostMethod: _cacheOptions!.allowPostMethod,
        // Don't cache error responses
        hitCacheOnErrorExcept: [401, 403, 404, 500, 502, 503, 504],
      );
      _dio!.interceptors.add(DioCacheInterceptor(options: cacheOptionsWithFilter));

      debugPrint('DioClient: Initialized with caching and retry');
    } catch (e) {
      debugPrint('DioClient: Initialization error: $e');
      rethrow;
    }
  }

  /// GET request with automatic caching
  /// Returns Map<String, dynamic> to match ApiClient behavior
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    if (_dio == null) await initialize();

    try {
      final cacheOptions = forceRefresh
          ? Options(
              extra: {CacheOptions.defaultCacheKeyBuilder: CachePolicy.refresh}
                  .cast<String, dynamic>())
          : options;

      final response = await _dio!.get(
        path,
        queryParameters: queryParameters,
        options: cacheOptions,
        cancelToken: cancelToken,
      );

      // Return data as Map (same as ApiClient)
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        return jsonDecode(response.data);
      }
      return {'data': response.data};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request (not cached)
  /// Returns Map<String, dynamic> to match ApiClient behavior
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (_dio == null) await initialize();

    try {
      final response = await _dio!.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      // Return data as Map (same as ApiClient)
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        return jsonDecode(response.data);
      }
      return {'data': response.data};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request (invalidates cache)
  /// Returns Map<String, dynamic> to match ApiClient behavior
  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (_dio == null) await initialize();

    try {
      final response = await _dio!.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      // Invalidate related cache after mutation
      await invalidateCache(path);

      // Return data as Map (same as ApiClient)
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        return jsonDecode(response.data);
      }
      return {'data': response.data};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request (invalidates cache)
  /// Returns Map<String, dynamic> to match ApiClient behavior
  Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (_dio == null) await initialize();

    try {
      final response = await _dio!.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      // Invalidate related cache after mutation
      await invalidateCache(path);

      // Return data as Map (same as ApiClient)
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        return jsonDecode(response.data);
      }
      return {'data': response.data};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Invalidate cache for a specific path
  Future<void> invalidateCache(String path) async {
    try {
      final cacheStore = _cacheOptions?.store;
      if (cacheStore != null) {
        await cacheStore.clean();
        debugPrint('[DioClient] Cache invalidated');
      }
    } catch (e) {
      debugPrint('[DioClient] Error invalidating cache: $e');
    }
  }

  /// Clear all HTTP cache
  Future<void> clearCache() async {
    try {
      final cacheStore = _cacheOptions?.store;
      if (cacheStore != null) {
        await cacheStore.clean();
        debugPrint('[DioClient] All HTTP cache cleared');
      }
    } catch (e) {
      debugPrint('[DioClient] Error clearing cache: $e');
    }
  }

  /// Handle Dio errors
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
            'Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';
        return Exception('Server error ($statusCode): $message');

      case DioExceptionType.cancel:
        return Exception('Request cancelled');

      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');

      default:
        return Exception('Network error: ${error.message}');
    }
  }

  /// Get underlying Dio instance (for advanced usage)
  Dio get dio => _dio!;

  /// Replay queued non-idempotent requests (requires backend idempotency support)
  Future<void> replayQueuedRequests() async {
    if (_dio == null) await initialize();
    if (_replayQueue.isEmpty) return;

    final queued = List<RequestOptions>.from(_replayQueue);
    _replayQueue.clear();

    for (final req in queued) {
      try {
        AppLogger().logNetwork('Replaying queued request', data: {'url': req.uri.toString()});
        final response = await _dio!.fetch(req);
        AppLogger().logApiResponse(req.method, req.uri.toString(), response.statusCode ?? 0, data: response.data);
      } catch (e) {
        AppLogger().logNetwork('Queued request replay failed', data: {'error': e.toString(), 'url': req.uri.toString()});
      }
    }
  }
}
