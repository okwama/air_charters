import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/env/app_config.dart';
import '../network/api_client.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import '../error/app_exceptions.dart';
import '../../shared/utils/session_manager.dart';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final authData = await _apiClient.getAuth();
      return authData != null && !authData.isExpired;
    } catch (e) {
      return false;
    }
  }

  // Email/Password Authentication (Backend-Only)
  Future<AuthModel> signInWithEmail(String email, String password) async {
    try {
      print('🔥 LOGIN: Starting backend authentication...');
      dev.log('Starting backend authentication for: $email',
          name: 'AuthRepository');

      // Use backend-only authentication
      print('🔥 LOGIN: Using backend authentication...');
      return await _loginBackendOnly(email, password);
    } catch (e, s) {
      print('🔥 LOGIN: Authentication error: $e');
      dev.log('Error during signInWithEmail: $e', name: 'AuthRepository-ERROR');
      dev.log('Stack trace: $s', name: 'AuthRepository-ERROR');

      // Re-throw the original exception to preserve specific error messages
      if (e is AuthException || e is ValidationException) {
        throw e;
      } else {
      throw AuthException(
          'An unexpected error occurred during sign-in. Please try again.');
      }
    }
  }

  // Email/Password Signup
  Future<AuthModel> signUpWithEmail(
      String email, String password, String firstName, String lastName) async {
    print('🔥 SIGNUP METHOD CALLED 🔥');
    dev.log('=== SIGNUP METHOD CALLED ===', name: 'AuthRepository-DEBUG');
    try {
      print('🔥 === STARTING BACKEND SIGNUP PROCESS ===');
      dev.log('=== STARTING BACKEND SIGNUP PROCESS ===',
          name: 'AuthRepository-DEBUG');
      print('🔥 Email: $email, First Name: $firstName, Last Name: $lastName');
      dev.log('Email: $email, First Name: $firstName, Last Name: $lastName',
          name: 'AuthRepository-DEBUG');

      // Use backend-only registration
      print('🔥 SIGNUP: Using backend registration...');
      return await _registerBackendOnly(email, password, firstName, lastName);
    } catch (e, stackTrace) {
      dev.log('Unexpected error during sign up: $e',
          name: 'AuthRepository-ERROR');
      dev.log('Error type: ${e.runtimeType}', name: 'AuthRepository-ERROR');
      dev.log('Stack trace: $stackTrace', name: 'AuthRepository-ERROR');

      // Re-throw the original exception to preserve specific error messages
      if (e is AuthException || e is ValidationException) {
        throw e;
      } else {
      throw AuthException('Failed to sign up: ${e.toString()}');
      }
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _apiClient.clearAuth();
    await _clearLocalAuthData();
  }

  // Get Current User
  Future<UserModel?> getCurrentUser() async {
    try {
      final authData = await _apiClient.getAuth();
      return authData?.user;
    } catch (e) {
      return null;
    }
  }

  // Update User Profile
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? countryCode,
  }) async {
    try {
      final response = await _apiClient.put('/api/auth/profile', {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (countryCode != null) 'countryCode': countryCode,
      });

      final updatedUser = UserModel.fromJson(response['user']);

      // Update stored auth data
      final currentAuth = await _apiClient.getAuth();
      if (currentAuth != null) {
        final updatedAuth = currentAuth.copyWith(user: updatedUser);
        await _apiClient.saveAuth(updatedAuth);
      }

      return updatedUser;
    } catch (e) {
      throw AuthException('Failed to update profile: $e');
    }
  }

  // Refresh Token
  Future<AuthModel?> refreshToken() async {
    try {
      return await _apiClient.refreshToken();
    } catch (e) {
      throw AuthException('Failed to refresh token: $e');
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      await _apiClient.delete('/api/auth/profile');
      await _clearLocalAuthData();
      await _apiClient.clearAuth();
    } catch (e) {
      throw AuthException('Failed to delete account: $e');
    }
  }

  // Test backend connectivity
  Future<bool> testBackendConnection() async {
    try {
      dev.log('Testing backend connectivity...', name: 'AuthRepository');
      final isHealthy = await _apiClient.checkBackendHealth();
      dev.log('Backend health check result: $isHealthy',
          name: 'AuthRepository');
      return isHealthy;
    } catch (e) {
      dev.log('Backend connectivity test failed: $e',
          name: 'AuthRepository-ERROR');
      return false;
    }
  }

  // Backend-only login
  Future<AuthModel> _loginBackendOnly(String email, String password) async {
    try {
      print('🔥 LOGIN: Backend-only authentication...');

      final response = await _apiClient.post('/api/auth/login', {
        'email': email,
        'password': password,
      });

      print('🔥 LOGIN: Backend-only login successful');

      // Create auth data from backend response using fromBackendJson
      final authData = AuthModel.fromBackendJson(response);

      // Store the token immediately
      await _apiClient.saveAuth(authData);
      await _saveLocalAuthData(authData);

      // Update SessionManager immediately after storing token
      try {
        final sessionManager = SessionManager();
        if (kDebugMode) {
          dev.log('AuthRepository: Updating SessionManager after login',
              name: 'auth_repository');
        }
        // Note: SessionManager will be re-initialized by AuthProvider
      } catch (e) {
        if (kDebugMode) {
          dev.log('AuthRepository: Error updating SessionManager: $e',
              name: 'auth_repository');
        }
      }

      print('🔥 LOGIN: Backend-only authentication completed');
      return authData;
    } catch (e) {
      print('🔥 LOGIN: Backend-only login failed: $e');
      // Re-throw the original exception to preserve the specific error message
      if (e is AuthException) {
        throw e;
      } else {
      throw AuthException('Login failed: $e');
      }
    }
  }

  // Register user with backend only
  Future<AuthModel> _registerBackendOnly(
      String email, String password, String firstName, String lastName) async {
    try {
      print('🔥 Starting backend-only registration...');

      // Create user directly in backend
      final response = await _apiClient.post('/api/auth/register', {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'authProvider': 'email', // Email/password authentication
      });

      print('🔥 Backend-only registration successful');

      // Create auth data from backend response using fromBackendJson
      final authData = AuthModel.fromBackendJson(response);
      await _apiClient.saveAuth(authData);

      print('🔥 Backend-only registration completed successfully');
      return authData;
    } catch (e) {
      print('🔥 Backend-only registration failed: $e');
      // Re-throw the original exception to preserve the specific error message
      if (e is AuthException || e is ValidationException) {
        throw e;
      } else {
      throw AuthException('Failed to register user: $e');
      }
    }
  }

  // Local storage helpers
  Future<void> _saveLocalAuthData(AuthModel authData) async {
    await _secureStorage.write(
      key: AppConfig.localAuthDataKey,
      value: json.encode(authData.toJson()),
    );
  }

  Future<AuthModel?> _getLocalAuthData() async {
    final data = await _secureStorage.read(key: AppConfig.localAuthDataKey);
    if (data != null) {
      try {
        // Parse the stored JSON string properly
        final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
            json.decode(data) as Map<String, dynamic>);
        return AuthModel.fromJson(jsonData);
      } catch (e) {
        // If parsing fails, try to clear the corrupted data and return null
        await _clearLocalAuthData();
        return null;
      }
    }
    return null;
  }

  Future<void> _clearLocalAuthData() async {
    await _secureStorage.delete(key: AppConfig.localAuthDataKey);
  }

  // Clear all stored data (for troubleshooting)
  Future<void> clearAllStoredData() async {
    try {
      // Clear local storage
      await _clearLocalAuthData();
      await _apiClient.clearAuth();
    } catch (e) {
      // Ignore errors when clearing data
    }
  }

  // Check if user exists before signup
  Future<bool> checkUserExists(String email) async {
    try {
      dev.log('Checking if user exists with email: $email',
          name: 'AuthRepository');

      // For backend-only, we'll rely on the backend to handle user existence
      // The backend will return appropriate errors if user already exists
      return false; // Let the backend handle this
    } catch (e) {
      dev.log('Error checking user existence: $e',
          name: 'AuthRepository-ERROR');
      // If we can't check, assume user doesn't exist to allow signup
      return false;
    }
  }
}
