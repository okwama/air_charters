import 'package:flutter/foundation.dart';
import '../auth/auth_repository.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import '../error/app_exceptions.dart';
import 'dart:async';
import 'dart:developer' as dev;
import '../../shared/utils/session_manager.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  Timer? _tokenRefreshTimer;

  AuthState _state = AuthState.initial;
  AuthModel? _authData;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;
  String? _successMessage;

  // Getters
  AuthState get state => _state;
  AuthModel? get authData => _authData;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get hasValidToken => _authData != null && !_authData!.isExpired;

  // Initialize auth state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          // Create a basic AuthModel for the current user
          final authData = await _authRepository.refreshToken();
          if (authData != null) {
            await _setAuthenticatedWithToken(authData);
          } else {
            _setUnauthenticated();
          }
        } else {
          _setUnauthenticated();
        }
      } else {
        _setUnauthenticated();
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set authenticated state with token management
  Future<void> _setAuthenticatedWithToken(AuthModel authData) async {
    _authData = authData;
    _currentUser = authData.user;
    _state = AuthState.authenticated;
    _clearError();
    _clearSuccess();

    // Setup token refresh timer
    _setupTokenRefreshTimer();

    // Ensure SessionManager is updated with the new auth data
    try {
      final sessionManager = SessionManager();
      // Re-initialize session manager with current auth provider
      sessionManager.initialize(this);

      // Debug token status
      sessionManager.debugTokenStatus();

      if (kDebugMode) {
        dev.log('AuthProvider: SessionManager updated with new auth data',
            name: 'auth_provider');
        dev.log('AuthProvider: Token expires at: ${authData.expiresAt}',
            name: 'auth_provider');
        dev.log('AuthProvider: Token is expired: ${authData.isExpired}',
            name: 'auth_provider');
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthProvider: Error updating SessionManager: $e',
            name: 'auth_provider');
      }
    }

    notifyListeners();
  }

  // Setup automatic token refresh
  void _setupTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();

    if (_authData != null) {
      // Calculate time until token expires (minus 5 minutes buffer)
      final timeUntilExpiry = _authData!.expiresAt.difference(DateTime.now());
      final refreshTime = timeUntilExpiry.inMilliseconds -
          (5 * 60 * 1000); // 5 minutes before expiry

      if (refreshTime > 0) {
        _tokenRefreshTimer = Timer(Duration(milliseconds: refreshTime), () {
          _refreshTokenIfNeeded();
        });
      } else {
        // Token is already expired or will expire soon, refresh immediately
        _refreshTokenIfNeeded();
      }
    }
  }

  // Refresh token if needed
  Future<void> _refreshTokenIfNeeded() async {
    if (_authData != null && _authData!.willExpireSoon) {
      try {
        await refreshToken();
      } catch (e) {
        // If refresh fails, sign out user
        await signOut();
      }
    }
  }

  // Validate current token
  Future<bool> validateToken() async {
    if (_authData == null) return false;

    if (_authData!.isExpired) {
      try {
        await refreshToken();
        return true;
      } catch (e) {
        await signOut();
        return false;
      }
    }

    return true;
  }

  // Phone Authentication - Backend Only Implementation
  Future<void> sendPhoneVerification(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      // For backend-only, we'll implement a simple phone verification
      // This would typically involve sending an SMS via your backend
      await _authRepository.testBackendConnection();
      _setLoading(false);
      _setSuccess('Verification code sent to $phoneNumber');
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  Future<void> verifyPhoneCode(String smsCode) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // For backend-only, this would validate the SMS code
      // For now, we'll just simulate success
      _setSuccess('Phone verification successful!');
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Email/Password Authentication
  Future<void> signInWithEmail(String email, String password) async {
    print('🔥 AUTH PROVIDER: SIGNIN STARTED');
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      print('🔥 AUTH PROVIDER: Calling _authRepository.signInWithEmail');
      final authData = await _authRepository.signInWithEmail(email, password);
      print('🔥 AUTH PROVIDER: Repository signin completed successfully');
      await _setAuthenticatedWithToken(authData);
      _successMessage =
          'Login successful! Welcome back, ${authData.user.firstName}';
      print('🔥 AUTH PROVIDER: SIGNIN COMPLETED SUCCESSFULLY');
    } catch (e) {
      print('🔥 AUTH PROVIDER: Signin error: $e');
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String firstName, String lastName) async {
    print('🔥 AUTH PROVIDER: SIGNUP STARTED 🔥');
    dev.log('=== AUTH PROVIDER: SIGNUP STARTED ===',
        name: 'AuthProvider-DEBUG');
    dev.log('Email: $email, First Name: $firstName, Last Name: $lastName',
        name: 'AuthProvider-DEBUG');

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      dev.log('About to call _authRepository.signUpWithEmail',
          name: 'AuthProvider-DEBUG');
      final authData = await _authRepository.signUpWithEmail(
          email, password, firstName, lastName);
      dev.log('Auth repository signup completed successfully',
          name: 'AuthProvider-DEBUG');
      await _setAuthenticatedWithToken(authData);
      _successMessage = 'Account created successfully! Welcome, $firstName';
      dev.log('=== AUTH PROVIDER: SIGNUP COMPLETED ===',
          name: 'AuthProvider-DEBUG');
    } catch (e) {
      dev.log('Auth provider signup error: $e', name: 'AuthProvider-ERROR');
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user exists before signup
  Future<bool> checkUserExists(String email) async {
    try {
      return await _authRepository.checkUserExists(email);
    } catch (e) {
      // If we can't check, assume user doesn't exist to allow signup
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authRepository.signOut();
      _tokenRefreshTimer?.cancel();
      _setUnauthenticated();
      _setSuccess('Successfully signed out');
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  // Update Profile
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? countryCode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        countryCode: countryCode,
      );
      _currentUser = updatedUser;
      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  // Refresh Token
  Future<void> refreshToken() async {
    try {
      final newAuthData = await _authRepository.refreshToken();
      if (newAuthData != null) {
        await _setAuthenticatedWithToken(newAuthData);
        _setSuccess('Session refreshed successfully');
      } else {
        _setUnauthenticated();
      }
    } catch (e) {
      _setUnauthenticated();
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    _setLoading(true);

    try {
      await _authRepository.deleteAccount();
      _setUnauthenticated();
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  // Removed unused method: _setAuthenticated

  void _setUnauthenticated() {
    _state = AuthState.unauthenticated;
    _authData = null;
    _currentUser = null;
    _tokenRefreshTimer?.cancel();
    _clearError();
    _clearSuccess();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _state = AuthState.loading;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.initial;
    }
  }

  void _clearSuccess() {
    _successMessage = null;
  }

  void _setSuccess(String message) {
    _successMessage = message;
  }

  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString();
    } else {
      return 'An unexpected error occurred: $error';
    }
  }

  // Clear all data and restart fresh (for troubleshooting)
  Future<void> clearAllDataAndRestart() async {
    try {
      await _authRepository.clearAllStoredData();
      _tokenRefreshTimer?.cancel();
      _setUnauthenticated();
    } catch (e) {
      // Ignore errors when clearing data
    }
  }

  // Clear all data (for testing or reset)
  void clear() {
    _state = AuthState.initial;
    _authData = null;
    _currentUser = null;
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    _tokenRefreshTimer?.cancel();
    notifyListeners();
  }
}
