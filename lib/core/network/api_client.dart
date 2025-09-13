import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_model.dart';
import '../error/app_exceptions.dart';
import '../../config/env/app_config.dart';
import '../../shared/utils/session_manager.dart';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart' show kDebugMode;

class ApiClient {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  String get _baseUrl => AppConfig.backendUrl;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  http.Client get _client => http.Client();

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
  Future<dynamic> get(String endpoint, {int maxRetries = 3}) async {
    return await _retryRequest(() async {
      print('🔍 ApiClient: Making GET request to $_baseUrl$endpoint');
      final headers = await _authHeaders;
      print('🔍 ApiClient: Headers: $headers');

      final response = await _client
          .get(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 30));

      print('🔍 ApiClient: Response status: ${response.statusCode}');
      print('🔍 ApiClient: Response body: ${response.body}');

      return _handleResponse(response);
    }, maxRetries: maxRetries);
  }

  // POST Request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      // Removed debug print
      // Removed debug print
      // Removed debug print

      final headers = await _authHeaders;
      final jsonBody = jsonEncode(data);
      // Removed debug print

      final response = await _client
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: jsonBody,
          )
          .timeout(const Duration(seconds: 30));

      // Removed debug print
      // Removed debug print

      return _handleResponse(response);
    } catch (e) {
      // Removed debug print
      throw _handleError(e);
    }
  }

  // PUT Request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _authHeaders;
      final response = await _client
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _authHeaders;
      final response = await _client
          .delete(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 30));

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
        final errorMessage = body['message'] ?? 'Bad request. Please check your input.';
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

  // Retry logic with exponential backoff
  Future<dynamic> _retryRequest(Future<dynamic> Function() request, {int maxRetries = 3}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await request();
      } catch (e) {
        print('🔄 ApiClient: Attempt ${attempt + 1}/$maxRetries failed: $e');
        
        if (attempt == maxRetries - 1) {
          print('❌ ApiClient: All retry attempts failed, throwing error');
          throw _handleError(e);
        }
        
        // Exponential backoff: 1s, 2s, 4s
        final delay = Duration(seconds: 1 << attempt);
        print('⏳ ApiClient: Waiting ${delay.inSeconds}s before retry...');
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
              'refresh_token': currentAuth.refreshToken,
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
      print('🔥 API: getUserProfile');
      dev.log('Fetching user profile...', name: 'ApiClient');
      final result = await get('/api/users/profile');
      print('🔥 API: getUserProfile - Success');
      return result;
    } catch (e) {
      print('🔥 API: getUserProfile - Error: $e');
      dev.log('Error fetching user profile: $e', name: 'ApiClient-ERROR');
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
}
