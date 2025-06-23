import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_model.dart';
import '../error/app_exceptions.dart';
import 'dart:developer' as dev;

class ApiClient {
  static const String _baseUrl =
      'http://10.0.2.2:5000'; // Updated for local development
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

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
    final authData = await _getStoredAuth();
    if (authData != null && !authData.isExpired) {
      headers['Authorization'] = authData.authorizationHeader;
    }
    return headers;
  }

  // GET Request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _authHeaders;
      final response = await _client
          .get(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _authHeaders;
      final response = await _client
          .post(
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

  // PUT Request
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
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
  Future<Map<String, dynamic>> delete(String endpoint) async {
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

  // Handle Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 401:
        // Token expired or invalid
        _clearStoredAuth();
        throw AuthException('Authentication failed. Please login again.');
      case 403:
        throw AuthException(
            'Access denied. You don\'t have permission to perform this action.');
      case 404:
        throw ServerException('Resource not found.');
      case 422:
        throw ValidationException(body['message'] ?? 'Validation failed.');
      case 500:
        throw ServerException('Internal server error. Please try again later.');
      default:
        throw ServerException(
            body['message'] ?? 'An unexpected error occurred.');
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

  // Token Management
  Future<void> _storeAuth(AuthModel auth) async {
    await _storage.write(key: 'auth_data', value: jsonEncode(auth.toJson()));
  }

  Future<AuthModel?> _getStoredAuth() async {
    final authJson = await _storage.read(key: 'auth_data');
    if (authJson != null) {
      try {
        return AuthModel.fromJson(jsonDecode(authJson));
      } catch (e) {
        await _clearStoredAuth();
        return null;
      }
    }
    return null;
  }

  Future<void> _clearStoredAuth() async {
    await _storage.delete(key: 'auth_data');
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

  // New method for backend authentication
  Future<AuthModel> authenticateWithBackend(
    String firebaseToken, {
    String? firstName,
    String? lastName,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) {
        body['first_name'] = firstName;
      }
      if (lastName != null) {
        body['last_name'] = lastName;
      }

      final uri = Uri.parse('$_baseUrl/api/auth/register');
      dev.log('Sending auth request to backend: $uri', name: 'ApiClient');
      dev.log('Request body: ${jsonEncode(body)}', name: 'ApiClient');

      final response = await _client.post(
        // The base URL for the API client needs to be updated for local development
        uri,
        headers: {
          ..._defaultHeaders,
          'Authorization': 'Bearer $firebaseToken',
        },
        body: jsonEncode(body),
      );

      final responseBody = _handleResponse(response);
      dev.log('Backend auth response: $responseBody', name: 'ApiClient');
      final authModel = AuthModel.fromBackendJson(responseBody);
      await saveAuth(authModel);
      return authModel;
    } catch (e) {
      throw _handleError(e);
    }
  }
}
