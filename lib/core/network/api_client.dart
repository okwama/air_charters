import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart' as dio;
import '../models/auth_model.dart';
import '../error/app_exceptions.dart';
import '../../config/env/app_config.dart';
import '../../shared/utils/session_manager.dart';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'dio_client.dart';

class ApiClient {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  String get _baseUrl => AppConfig.backendUrl;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // 🚀 NEW: Use DioClient for caching and performance
  final DioClient _dioClient = DioClient();

  // ✅ PERFORMANCE FIX: Persistent HTTP client for connection pooling (fallback)
  final http.Client _client = http.Client();

  // Flag to enable/disable DioClient (for gradual migration)
  final bool _useDioClient = true;

  // Headers
  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, String>> get _authHeaders async {
    final headers = Map<String, String>.from(_defaultHeaders);

    // Use SessionManager for token retrieval (standardized approach)
    final sessionManager = SessionManager();
    final authHeader = await sessionManager.getAuthorizationHeader();

    if (authHeader != null) {
      headers['Authorization'] = authHeader;
      if (kDebugMode) {
        dev.log('ApiClient: Authorization header added from SessionManager',
            name: 'api_client');
      }
    } else {
      if (kDebugMode) {
        dev.log('ApiClient: No Authorization header added (no valid token)',
            name: 'api_client');
      }
    }

    return headers;
  }

  // GET Request with retry logic
  Future<dynamic> get(String endpoint, {int maxRetries = 3, Map<String, String>? queryParams}) async {
    // 🚀 Use DioClient for caching and performance
    if (_useDioClient) {
      try {
        if (kDebugMode) {
          dev.log('Making GET request via DioClient to $endpoint',
              name: 'api_client');
        }
        final response = await _dioClient.get(endpoint, queryParameters: queryParams);
        return response;
      } on dio.DioException catch (e) {
        // Convert DioException to ApiClient exceptions
        throw _handleDioError(e);
      } catch (e) {
        throw _handleError(e);
      }
    }

    // Fallback to old http client
    return await _retryRequest(() async {
      if (kDebugMode) {
        dev.log('Making GET request to $_baseUrl$endpoint', name: 'api_client');
      }

      final headers = await _authHeaders;

      if (kDebugMode) {
        dev.log('Headers: ${headers.keys.join(", ")}', name: 'api_client');
      }

      // ✅ PERFORMANCE FIX: Optimized timeout for auth endpoints
      final timeout = _getTimeoutForEndpoint(endpoint);
        final uri = queryParams != null && queryParams.isNotEmpty
          ? Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams)
          : Uri.parse('$_baseUrl$endpoint');

        final response = await _client
          .get(uri, headers: headers)
          .timeout(timeout);

      if (kDebugMode) {
        dev.log('Response status: ${response.statusCode}', name: 'api_client');
      }

      return _handleResponse(response);
    }, maxRetries: maxRetries);
  }

  // POST Request with retry logic
  Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      {int maxRetries = 3}) async {
    // 🚀 Use DioClient for retry logic and performance
    if (_useDioClient) {
      try {
        if (kDebugMode) {
          dev.log('Making POST request via DioClient to $endpoint',
              name: 'api_client');
        }
        final response = await _dioClient.post(endpoint, data: data);
        return response;
      } on dio.DioException catch (e) {
        // Convert DioException to ApiClient exceptions
        throw _handleDioError(e);
      } catch (e) {
        throw _handleError(e);
      }
    }

    // Fallback to old http client
    return await _retryRequest(() async {
      if (kDebugMode) {
        dev.log('ApiClient: Making POST request to $_baseUrl$endpoint',
            name: 'api_client');
      }

      final headers = await _authHeaders;
      final jsonBody = jsonEncode(data);

      // ✅ PERFORMANCE FIX: Optimized timeout
      final timeout = _getTimeoutForEndpoint(endpoint);
      final response = await _client
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: jsonBody,
          )
          .timeout(timeout);

      if (kDebugMode) {
        dev.log('ApiClient: POST Response status: ${response.statusCode}',
            name: 'api_client');
      }

      return _handleResponse(response);
    }, maxRetries: maxRetries);
  }

  // PUT Request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    // 🚀 Use DioClient
    if (_useDioClient) {
      try {
        final response = await _dioClient.put(endpoint, data: data);
        return response;
      } on dio.DioException catch (e) {
        throw _handleDioError(e);
      } catch (e) {
        throw _handleError(e);
      }
    }

    // Fallback
    try {
      final headers = await _authHeaders;

      // ✅ PERFORMANCE FIX: Optimized timeout
      final timeout = _getTimeoutForEndpoint(endpoint);
      final response = await _client
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<dynamic> delete(String endpoint, Map<String, String?> map) async {
    // 🚀 Use DioClient
    if (_useDioClient) {
      try {
        final response = await _dioClient.delete(endpoint);
        return response;
      } on dio.DioException catch (e) {
        throw _handleDioError(e);
      } catch (e) {
        throw _handleError(e);
      }
    }

    // Fallback
    try {
      final headers = await _authHeaders;

      // ✅ PERFORMANCE FIX: Optimized timeout
      final timeout = _getTimeoutForEndpoint(endpoint);
      final response = await _client
          .delete(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request with body
  Future<dynamic> deleteWithBody(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _authHeaders;
      final request = http.Request('DELETE', Uri.parse('$_baseUrl$endpoint'));
      request.headers.addAll(headers);
      request.body = jsonEncode(data);

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle Response
  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 401:
        // Enhanced authentication error handling with retry logic
        return _handleAuthenticationError(response, body);
      case 403:
        final errorMessage = body['message'] ??
            'Access denied. You don\'t have permission to perform this action.';
        throw AuthException(errorMessage);
      case 404:
        final errorMessage = body['message'] ?? 'Resource not found.';
        throw ServerException(errorMessage);
      case 400:
        final errorMessage =
            body['message'] ?? 'Bad request. Please check your input.';
        throw ServerException(errorMessage);
      case 422:
        throw ValidationException(body['message'] ?? 'Validation failed.');
      case 500:
        final errorMessage =
            body['message'] ?? 'Internal server error. Please try again later.';
        throw ServerException(errorMessage);
      default:
        throw ServerException(
            body['message'] ?? 'An unexpected error occurred.');
    }
  }

  // Enhanced authentication error handling with retry logic
  Future<dynamic> _handleAuthenticationError(
      http.Response response, Map<String, dynamic> body) async {
    final sessionManager = SessionManager();
    final errorMessage =
        body['message'] ?? 'Authentication failed. Please login again.';

    if (kDebugMode) {
      dev.log('ApiClient: Handling 401 authentication error: $errorMessage',
          name: 'api_client');
    }

    // Use SessionManager to handle the authentication error
    final errorHandling =
        await sessionManager.handleAuthError(401, errorMessage);

    if (errorHandling.shouldRetry) {
      if (kDebugMode) {
        dev.log(
            'ApiClient: Token refreshed, but retry not implemented for this request type',
            name: 'api_client');
      }

      // For now, we'll throw the auth exception since retrying with body data is complex
      // In a production app, you might want to implement a request queue or store request details
      throw AuthException(
          '${errorHandling.message} (Retry not available for this request type)');
    } else {
      // No retry possible, throw authentication exception
      if (kDebugMode) {
        dev.log('ApiClient: No retry possible, throwing auth exception',
            name: 'api_client');
      }
      throw AuthException(errorHandling.message);
    }
  }

  // ✅ PERFORMANCE FIX: Optimized timeout based on endpoint type
  Duration _getTimeoutForEndpoint(String endpoint) {
    if (endpoint.contains('/auth/')) return const Duration(seconds: 8);
    if (endpoint.contains('/profile')) return const Duration(seconds: 10);
    if (endpoint.contains('/payment')) return const Duration(seconds: 30);
    return const Duration(seconds: 15); // Default
  }

  // Retry logic with exponential backoff
  Future<dynamic> _retryRequest(Future<dynamic> Function() request,
      {int maxRetries = 3}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await request();
      } catch (e) {
        if (kDebugMode) {
          dev.log('Attempt ${attempt + 1}/$maxRetries failed: $e',
              name: 'api_client');
        }

        if (attempt == maxRetries - 1) {
          if (kDebugMode) {
            dev.log('All retry attempts failed, throwing error',
                name: 'api_client');
          }
          throw _handleError(e);
        }

        // Exponential backoff: 1s, 2s, 4s
        final delay = Duration(seconds: 1 << attempt);
        if (kDebugMode) {
          dev.log('Waiting ${delay.inSeconds}s before retry...',
              name: 'api_client');
        }
        await Future.delayed(delay);
      }
    }
  }

  // Handle Errors
  Exception _handleError(dynamic error) {
    if (error is SocketException) {
      return NetworkException(
          'No internet connection. Please check your network.');
    } else if (error is FormatException) {
      return ServerException('Invalid response format from server.');
    } else if (error is Exception) {
      return error;
    } else {
      return ServerException('An unexpected error occurred: $error');
    }
  }

  // Token Management - Use SessionManager for consistency
  Future<void> _storeAuth(AuthModel auth) async {
    final sessionManager = SessionManager();
    await sessionManager.storeAuthData(auth);
  }

  Future<AuthModel?> _getStoredAuth() async {
    final sessionManager = SessionManager();
    return await sessionManager.getStoredAuthData();
  }

  Future<void> _clearStoredAuth() async {
    final sessionManager = SessionManager();
    await sessionManager.clearStoredAuthData();
  }

  // Public methods for auth management
  Future<void> saveAuth(AuthModel auth) async {
    await _storeAuth(auth);
  }

  Future<AuthModel?> getAuth() async {
    return await _getStoredAuth();
  }

  Future<void> clearAuth() async {
    await _clearStoredAuth();
  }

  Future<bool> isAuthenticated() async {
    final auth = await _getStoredAuth();
    return auth != null && !auth.isExpired;
  }

  // Token Refresh
  Future<AuthModel?> refreshToken() async {
    try {
      final currentAuth = await _getStoredAuth();
      if (currentAuth == null) return null;

        final response = await _client
            .post(
              Uri.parse('$_baseUrl/api/auth/refresh'),
              headers: _defaultHeaders,
              body: jsonEncode({
                'refreshToken': currentAuth.refreshToken,
              }),
            )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final newAuth = AuthModel.fromJson(body);
        await _storeAuth(newAuth);
        return newAuth;
      } else {
        await _clearStoredAuth();
        return null;
      }
    } catch (e) {
      await _clearStoredAuth();
      return null;
    }
  }

  // Health check method to test backend connectivity
  Future<bool> checkBackendHealth() async {
    try {
      dev.log('Attempting backend health check to: $_baseUrl/api/health',
          name: 'ApiClient-DEBUG');
      final response = await _client
          .get(Uri.parse('$_baseUrl/api/health'))
          .timeout(const Duration(seconds: 10));

      dev.log('Backend health check status: ${response.statusCode}',
          name: 'ApiClient');
      dev.log('Backend health check response: ${response.body}',
          name: 'ApiClient-DEBUG');
      return response.statusCode == 200;
    } catch (e) {
      dev.log('Backend health check failed: $e', name: 'ApiClient-ERROR');
      dev.log('Error type: ${e.runtimeType}', name: 'ApiClient-ERROR');
      return false;
    }
  }

  // Authentication Methods
  Future<AuthModel> authenticateWithBackend(String token) async {
    try {
      dev.log('Authenticating with backend using token...', name: 'ApiClient');
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/auth/verify'),
            headers: _defaultHeaders,
            body: jsonEncode({
              'token': token,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final authModel = AuthModel.fromJson(body);
        await _storeAuth(authModel);
        dev.log('Authentication successful', name: 'ApiClient');
        return authModel;
      } else {
        dev.log('Authentication failed with status: ${response.statusCode}',
            name: 'ApiClient-ERROR');
        throw AuthException('Authentication failed. Invalid token.');
      }
    } catch (e) {
      dev.log('Error during authentication: $e', name: 'ApiClient-ERROR');
      throw _handleError(e);
    }
  }

  // User Profile Methods
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      if (kDebugMode) {
        dev.log('Fetching user profile...', name: 'ApiClient');
      }
      final result = await get('/api/users/profile');
      if (kDebugMode) {
        dev.log('User profile fetched successfully', name: 'ApiClient');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        dev.log('Error fetching user profile: $e', name: 'ApiClient-ERROR');
      }
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> profileData) async {
    try {
      dev.log('Updating user profile with data: $profileData',
          name: 'ApiClient');
      return await put('/api/users/profile', profileData);
    } catch (e) {
      dev.log('Error updating user profile: $e', name: 'ApiClient-ERROR');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateUserPreferences(
      Map<String, dynamic> preferencesData) async {
    try {
      dev.log('Updating user preferences with data: $preferencesData',
          name: 'ApiClient');
      return await put('/api/users/preferences', preferencesData);
    } catch (e) {
      dev.log('Error updating user preferences: $e', name: 'ApiClient-ERROR');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUserWallet() async {
    try {
      dev.log('Fetching user wallet information...', name: 'ApiClient');
      return await get('/api/users/wallet');
    } catch (e) {
      dev.log('Error fetching user wallet: $e', name: 'ApiClient-ERROR');
      throw _handleError(e);
    }
  }

  // Handle DioException and convert to ApiClient exceptions
  Exception _handleDioError(dio.DioException error) {
    switch (error.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
      case dio.DioExceptionType.receiveTimeout:
        return NetworkException(
            'Connection timeout. Please check your internet connection.');

      case dio.DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'];

        switch (statusCode) {
          case 401:
            return AuthException(message ?? 'Authentication failed');
          case 403:
            return AuthException(message ?? 'Access denied');
          case 404:
            return ServerException(message ?? 'Resource not found');
          case 422:
            return ValidationException(message ?? 'Validation failed');
          case 500:
            return ServerException(message ?? 'Internal server error');
          default:
            return ServerException(message ?? 'Server error');
        }

      case dio.DioExceptionType.cancel:
        return NetworkException('Request cancelled');

      case dio.DioExceptionType.connectionError:
        return NetworkException('No internet connection');

      default:
        return NetworkException('Network error: ${error.message}');
    }
  }

  // ✅ PERFORMANCE FIX: Dispose method to clean up persistent client
  void dispose() {
    _client.close();
  }
}
