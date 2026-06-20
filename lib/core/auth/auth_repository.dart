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
      dev.log('Starting backend authentication for: $email',
          name: 'AuthRepository');

      // Use backend-only authentication
      return await _loginBackendOnly(email, password);
    } catch (e, s) {
      dev.log('Error during signInWithEmail: $e', name: 'AuthRepository-ERROR');
      dev.log('Stack trace: $s', name: 'AuthRepository-ERROR');

      // Re-throw the original exception to preserve specific error messages
      if (e is AuthException || e is ValidationException) {
        rethrow;
      } else {
        throw AuthException(
            'An unexpected error occurred during sign-in. Please try again.');
      }
    }
  }

  // Phone/Password Authentication (Backend-Only)
  Future<AuthModel> signInWithPhone(String phoneNumber, String password) async {
    try {
      dev.log('Starting backend phone authentication for: $phoneNumber',
          name: 'AuthRepository');

      // Use backend-only phone authentication
      return await _loginBackendOnlyPhone(phoneNumber, password);
    } catch (e, s) {
      dev.log('Error during signInWithPhone: $e', name: 'AuthRepository-ERROR');
      dev.log('Stack trace: $s', name: 'AuthRepository-ERROR');

      // Re-throw the original exception to preserve specific error messages
      if (e is AuthException || e is ValidationException) {
        rethrow;
      } else {
        throw AuthException(
            'An unexpected error occurred during phone sign-in. Please try again.');
      }
    }
  }

  // Email/Password Signup
  Future<AuthModel> signUpWithEmail(
      String email, String password, String firstName, String lastName,
      {String? phoneNumber}) async {
    dev.log('=== SIGNUP METHOD CALLED ===', name: 'AuthRepository-DEBUG');
    try {
      dev.log('=== STARTING BACKEND SIGNUP PROCESS ===',
          name: 'AuthRepository-DEBUG');
      dev.log('Email: $email, First Name: $firstName, Last Name: $lastName',
          name: 'AuthRepository-DEBUG');

      // Use backend-only registration
      return await _registerBackendOnly(email, password, firstName, lastName,
          phoneNumber: phoneNumber);
    } catch (e, stackTrace) {
      dev.log('Unexpected error during sign up: $e',
          name: 'AuthRepository-ERROR');
      dev.log('Error type: ${e.runtimeType}', name: 'AuthRepository-ERROR');
      dev.log('Stack trace: $stackTrace', name: 'AuthRepository-ERROR');

      // Re-throw the original exception to preserve specific error messages
      if (e is AuthException || e is ValidationException) {
        rethrow;
      } else {
        throw AuthException('Failed to sign up: ${e.toString()}');
      }
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      // Get stored auth data to retrieve refresh token
      final authData = await _getLocalAuthData();

      if (authData?.refreshToken != null) {
        // Call backend logout endpoint to revoke refresh token
        try {
          await _apiClient.post('/api/auth/logout', {
            'refreshToken': authData!.refreshToken,
          });
          if (kDebugMode) {
            dev.log('AuthRepository: Backend logout successful',
                name: 'AuthRepository');
          }
        } catch (e) {
          // Don't fail logout if backend call fails
          if (kDebugMode) {
            dev.log('AuthRepository: Backend logout failed: $e',
                name: 'AuthRepository-ERROR');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthRepository: Error during logout: $e',
            name: 'AuthRepository-ERROR');
      }
    } finally {
      // Always clear local auth data regardless of backend response
      await _apiClient.clearAuth();
      await _clearLocalAuthData();
    }
  }

  // Logout from all devices
  Future<bool> logoutAllDevices() async {
    try {
      await _apiClient.post('/api/auth/logout/all-devices', {});
      await _clearLocalAuthData();
      return true;
    } catch (e) {
      await _clearLocalAuthData();
      return false;
    }
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
      if (kDebugMode) {
        dev.log('=== AUTH REPOSITORY: Starting login for $email ===',
            name: 'AuthRepository-DEBUG');
        print('🔥 AUTH REPO: Calling /api/auth/login for $email');
      }

      final response = await _apiClient.post('/api/auth/login', {
        'email': email,
        'password': password,
      });

      if (kDebugMode) {
        dev.log('Login API response received', name: 'AuthRepository-DEBUG');
        print('🔥 AUTH REPO: Login response received successfully');
      }

      // Create auth data from backend response using fromBackendJson
      final authData = AuthModel.fromBackendJson(response);

      // Store the token immediately
      await _apiClient.saveAuth(authData);
      await _saveLocalAuthData(authData);

      // Note: SessionManager will be re-initialized by AuthProvider after login

      if (kDebugMode) {
        dev.log('=== AUTH REPOSITORY: Login successful ===',
            name: 'AuthRepository-DEBUG');
        print('🔥 AUTH REPO: Login completed successfully');
      }
      return authData;
    } catch (e) {
      if (kDebugMode) {
        dev.log('Login error: $e', name: 'AuthRepository-ERROR');
        dev.log('Error type: ${e.runtimeType}', name: 'AuthRepository-ERROR');
        print('🔥 AUTH REPO: Login failed with error: $e');
      }

      // Re-throw the original exception to preserve the specific error message
      if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Login failed: $e');
      }
    }
  }

  // Backend-only phone login
  Future<AuthModel> _loginBackendOnlyPhone(
      String phoneNumber, String password) async {
    try {
      if (kDebugMode) {
        dev.log(
            '=== AUTH REPOSITORY: Starting phone login for $phoneNumber ===',
            name: 'AuthRepository-DEBUG');
        print('🔥 AUTH REPO: Calling /api/auth/login/phone for $phoneNumber');
      }

      final response = await _apiClient.post('/api/auth/login/phone', {
        'phoneNumber': phoneNumber,
        'password': password,
      });

      if (kDebugMode) {
        dev.log('Phone login API response received',
            name: 'AuthRepository-DEBUG');
        print('🔥 AUTH REPO: Phone login response received successfully');
      }

      // Create auth data from backend response using fromBackendJson
      final authData = AuthModel.fromBackendJson(response);

      // Store the token immediately
      await _apiClient.saveAuth(authData);
      await _saveLocalAuthData(authData);

      // Note: SessionManager will be re-initialized by AuthProvider after phone login

      if (kDebugMode) {
        dev.log('=== AUTH REPOSITORY: Phone login successful ===',
            name: 'AuthRepository-DEBUG');
        print('🔥 AUTH REPO: Phone login completed successfully');
      }
      return authData;
    } catch (e) {
      if (kDebugMode) {
        dev.log('Phone login error: $e', name: 'AuthRepository-ERROR');
        dev.log('Error type: ${e.runtimeType}', name: 'AuthRepository-ERROR');
        print('🔥 AUTH REPO: Phone login failed with error: $e');
      }

      // Re-throw the original exception to preserve the specific error message
      if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Phone login failed: $e');
      }
    }
  }

  // Register user with backend only
  Future<AuthModel> _registerBackendOnly(
      String email, String password, String firstName, String lastName,
      {String? phoneNumber}) async {
    try {
      // Removed debug print

      // Create user directly in backend
      final requestData = {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'authProvider': 'email', // Email/password authentication
      };

      // Add phone number if provided
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        requestData['phoneNumber'] = phoneNumber;
        // Extract country code from phone number
        if (phoneNumber.startsWith('+')) {
          final countryCode = phoneNumber.substring(
              0,
              phoneNumber.length -
                  phoneNumber
                      .substring(1)
                      .replaceAll(RegExp(r'[^\d]'), '')
                      .length);
          requestData['countryCode'] = countryCode;
        }
      }

      final response = await _apiClient.post('/api/auth/register', requestData);

      // Removed debug print

      // Create auth data from backend response using fromBackendJson
      final authData = AuthModel.fromBackendJson(response);
      await _apiClient.saveAuth(authData);

      // Removed debug print
      return authData;
    } catch (e) {
      // Removed debug print
      // Re-throw the original exception to preserve the specific error message
      if (e is AuthException || e is ValidationException) {
        rethrow;
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

  // Phone Authentication with Twilio SMS
  Future<void> sendPhoneVerification(String phoneNumber) async {
    try {
      dev.log('Sending SMS verification to: $phoneNumber',
          name: 'AuthRepository');

      final response =
          await _apiClient.post(AppConfig.sendSmsVerificationEndpoint, {
        'phoneNumber': phoneNumber,
      });

      if (response['success'] == true) {
        dev.log('SMS verification sent successfully', name: 'AuthRepository');
        return; // Success - no exception thrown
      } else {
        throw AuthException(
            response['message'] ?? 'Failed to send verification code');
      }
    } catch (e) {
      dev.log('SMS verification error: $e', name: 'AuthRepository-ERROR');
      if (e is AuthException || e is ValidationException) {
        rethrow;
      } else {
        throw AuthException('Failed to send verification code: $e');
      }
    }
  }

  // Verify SMS Code
  Future<bool> verifySmsCode(String phoneNumber, String code) async {
    try {
      dev.log('Verifying SMS code for: $phoneNumber', name: 'AuthRepository');

      final response = await _apiClient.post(AppConfig.verifySmsCodeEndpoint, {
        'phoneNumber': phoneNumber,
        'code': code,
      });

      if (response['success'] == true) {
        dev.log('SMS code verified successfully', name: 'AuthRepository');
        return true;
      } else {
        throw AuthException(response['message'] ?? 'Invalid verification code');
      }
    } catch (e) {
      dev.log('SMS verification error: $e', name: 'AuthRepository-ERROR');
      if (e is AuthException || e is ValidationException) {
        rethrow;
      } else {
        throw AuthException('Failed to verify code: $e');
      }
    }
  }

  // Biometric Authentication
  Future<AuthModel> loginWithBiometric(
      String biometricId, String userId, String userEmail) async {
    try {
      dev.log('Starting biometric authentication for user: $userEmail',
          name: 'AuthRepository');

      final response = await _apiClient.post(AppConfig.biometricLoginEndpoint, {
        'biometricId': biometricId,
        'userId': userId,
        'userEmail': userEmail,
      });

      // Create auth data from backend response using fromBackendJson
      final authData = AuthModel.fromBackendJson(response);

      // Store the token immediately
      await _apiClient.saveAuth(authData);
      await _saveLocalAuthData(authData);

      // Note: SessionManager will be re-initialized by AuthProvider after biometric login

      dev.log('Biometric authentication successful', name: 'AuthRepository');
      return authData;
    } catch (e) {
      dev.log('Biometric authentication error: $e',
          name: 'AuthRepository-ERROR');
      if (e is AuthException || e is ValidationException) {
        rethrow;
      } else {
        throw AuthException('Biometric authentication failed: $e');
      }
    }
  }
}
