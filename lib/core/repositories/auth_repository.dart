import '../models/user_model.dart';
import '../models/auth_model.dart';
import '../network/api_client.dart';
import '../../config/env/app_config.dart';
import '../../shared/utils/session_manager.dart';

/// Repository for authentication operations
/// Handles data access and API communication for auth features
class AuthRepository {
  final ApiClient _apiClient;
  final SessionManager _sessionManager;

  AuthRepository({
    ApiClient? apiClient,
    SessionManager? sessionManager,
  })  : _apiClient = apiClient ?? ApiClient(),
        _sessionManager = sessionManager ?? SessionManager();

  /// Login user with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );

      if (response['success'] == true) {
        final user = UserModel.fromJson(response['data']['user']);
        final token = response['data']['accessToken'];
        final refreshToken = response['data']['refreshToken'];

        // Store auth data securely
        final authData = AuthModel(
          user: user,
          accessToken: token,
          refreshToken: refreshToken,
          tokenType: 'Bearer',
          expiresIn: 86400, // 24 hours in seconds
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        );
        await _sessionManager.storeAuthData(authData);

        return AuthResult.success(user);
      } else {
        return AuthResult.failure(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Register new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    String? countryCode,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.registerEndpoint,
        {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          if (countryCode != null) 'countryCode': countryCode,
        },
      );

      if (response['success'] == true) {
        final user = UserModel.fromJson(response['data']['user']);
        final token = response['data']['accessToken'];
        final refreshToken = response['data']['refreshToken'];

        // Store auth data securely
        final authData = AuthModel(
          user: user,
          accessToken: token,
          refreshToken: refreshToken,
          tokenType: 'Bearer',
          expiresIn: 86400, // 24 hours in seconds
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        );
        await _sessionManager.storeAuthData(authData);

        return AuthResult.success(user);
      } else {
        return AuthResult.failure(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Refresh access token
  Future<AuthResult> refreshToken() async {
    try {
      final authData = await _sessionManager.getStoredAuthData();
      if (authData?.refreshToken == null) {
        return AuthResult.failure('No refresh token available');
      }

      final response = await _apiClient.post(
        AppConfig.refreshTokenEndpoint,
        {
          'refreshToken': authData!.refreshToken,
        },
      );

      if (response['success'] == true) {
        final token = response['data']['accessToken'];
        final newRefreshToken = response['data']['refreshToken'];

        // Update stored auth data
        final updatedAuthData = AuthModel(
          user: authData.user,
          accessToken: token,
          refreshToken: newRefreshToken,
          tokenType: 'Bearer',
          expiresIn: 86400, // 24 hours in seconds
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        );
        await _sessionManager.storeAuthData(updatedAuthData);

        return AuthResult.success(null); // Token refreshed, no user data needed
      } else {
        return AuthResult.failure(
            response['message'] ?? 'Token refresh failed');
      }
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Get user profile
  Future<AuthResult> getProfile() async {
    try {
      final authHeader = await _sessionManager.getAuthorizationHeader();
      if (authHeader == null) {
        return AuthResult.failure('Not authenticated');
      }

      final response = await _apiClient.get(AppConfig.profileEndpoint);

      if (response['success'] == true) {
        final user = UserModel.fromJson(response['data']);
        return AuthResult.success(user);
      } else {
        return AuthResult.failure(
            response['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Logout user
  Future<AuthResult> logout() async {
    try {
      final authHeader = await _sessionManager.getAuthorizationHeader();
      if (authHeader != null) {
        // Call logout endpoint
        await _apiClient.post(AppConfig.logoutEndpoint, {});
      }

      // Clear stored auth data
      await _sessionManager.clearStoredAuthData();

      return AuthResult.success(null);
    } catch (e) {
      // Even if logout API fails, clear local auth data
      await _sessionManager.clearStoredAuthData();
      return AuthResult.success(null);
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final authData = await _sessionManager.getStoredAuthData();
    return authData != null && !authData.isExpired;
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    final authData = await _sessionManager.getStoredAuthData();
    return authData?.accessToken;
  }
}

/// Result class for authentication operations
class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(UserModel? user) {
    return AuthResult._(
      isSuccess: true,
      user: user,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
