import 'package:flutter/foundation.dart';
import '../auth/auth_repository.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import '../error/app_exceptions.dart';
import 'dart:async';

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

  // Phone Authentication
  Future<void> sendPhoneVerification(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.sendPhoneVerification(phoneNumber);
      _setLoading(false);
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
      final authData = await _authRepository.verifyPhoneCode(smsCode);
      await _setAuthenticatedWithToken(authData);
      _successMessage =
          'Phone verification successful! Welcome back, ${authData.user.firstName}';
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Email/Password Authentication
  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final authData = await _authRepository.signInWithEmail(email, password);
      await _setAuthenticatedWithToken(authData);
      _successMessage =
          'Login successful! Welcome back, ${authData.user.firstName}';
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String firstName, String lastName) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final authData = await _authRepository.signUpWithEmail(
          email, password, firstName, lastName);
      await _setAuthenticatedWithToken(authData);
      _successMessage = 'Account created successfully! Welcome, $firstName';
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
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

  // State Setters
  void _setAuthenticated(UserModel user) {
    _state = AuthState.authenticated;
    _currentUser = user;
    _clearError();
    notifyListeners();
  }

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
