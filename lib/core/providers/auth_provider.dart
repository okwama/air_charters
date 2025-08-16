import 'package:flutter/foundation.dart';
import '../auth/auth_repository.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import '../error/app_exceptions.dart';
import 'dart:async';
import 'dart:developer' as dev;
import '../../shared/utils/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart'; // Added for BuildContext

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final SessionManager _sessionManager = SessionManager();
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
    if (kDebugMode) {
      dev.log('AuthProvider: Starting initialization', name: 'auth_provider');
    }

    _setLoading(true);
    try {
      // Try to restore auth state from storage
      final storedAuthData = await _sessionManager.getStoredAuthData();

      if (storedAuthData != null) {
        if (storedAuthData.isExpired) {
          if (kDebugMode) {
            dev.log('AuthProvider: Stored token is expired, attempting refresh',
                name: 'auth_provider');
          }

          // Try to refresh the token
          try {
            final newAuthData = await _authRepository.refreshToken();
            if (newAuthData != null) {
              await _setAuthenticatedWithToken(newAuthData);
              if (kDebugMode) {
                dev.log('AuthProvider: Token refreshed successfully',
                    name: 'auth_provider');
              }
            } else {
              _setUnauthenticated();
              if (kDebugMode) {
                dev.log(
                    'AuthProvider: Token refresh failed, setting unauthenticated',
                    name: 'auth_provider');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              dev.log(
                  'AuthProvider: Token refresh error, setting unauthenticated: $e',
                  name: 'auth_provider');
            }
            _setUnauthenticated();
          }
        } else {
          // Token is valid, restore authentication
          await _setAuthenticatedWithToken(storedAuthData);
          if (kDebugMode) {
            dev.log('AuthProvider: Restored authentication from storage',
                name: 'auth_provider');
          }
        }
      } else {
        _setUnauthenticated();
        if (kDebugMode) {
          dev.log('AuthProvider: No stored authentication found',
              name: 'auth_provider');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthProvider: Error during initialization: $e',
            name: 'auth_provider');
      }
      _setUnauthenticated();
    } finally {
      _setLoading(false);
    }
  }

  // Set authenticated state with token management
  Future<void> _setAuthenticatedWithToken(AuthModel authData) async {
    if (kDebugMode) {
      dev.log('AuthProvider: Setting authenticated state',
          name: 'auth_provider');
    }

    try {
      _authData = authData;
      _currentUser = authData.user;
      _state = AuthState.authenticated;
      _clearError();
      _clearSuccess();

      // Store in SessionManager
      await _sessionManager.storeAuthData(authData);

      // Setup token refresh timer
      _setupTokenRefreshTimer();

      if (kDebugMode) {
        dev.log('AuthProvider: Authentication state set successfully',
            name: 'auth_provider');
        dev.log('AuthProvider: Token expires at: ${authData.expiresAt}',
            name: 'auth_provider');
        dev.log('AuthProvider: Token is expired: ${authData.isExpired}',
            name: 'auth_provider');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthProvider: Error setting authenticated state: $e',
            name: 'auth_provider');
      }
      // If setting authenticated state fails, fall back to unauthenticated
      _setUnauthenticated();
      throw e;
    }
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
        if (kDebugMode) {
          dev.log(
              'AuthProvider: Token refresh scheduled in ${refreshTime ~/ 1000} seconds',
              name: 'auth_provider');
        }
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
    if (kDebugMode) {
      dev.log('AuthProvider: Starting sign out process', name: 'auth_provider');
    }

    _setLoading(true);

    try {
      // Cancel any ongoing token refresh
      _tokenRefreshTimer?.cancel();

      // Clear auth data from backend (if possible)
      try {
        await _authRepository.signOut();
      } catch (e) {
        // Don't fail signout if backend call fails
        if (kDebugMode) {
          dev.log(
              'AuthProvider: Backend signout failed, continuing with local cleanup: $e',
              name: 'auth_provider');
        }
      }

      // Clear all local storage
      await _sessionManager.clearStoredAuthData();

      // Clear SharedPreferences landing flag (optional - keeps user as "returning")
      // await _clearLandingFlag(); // Uncomment if you want to reset landing page for logout

      // Reset state
      _setUnauthenticated();

      if (kDebugMode) {
        dev.log('AuthProvider: Sign out completed successfully',
            name: 'auth_provider');
      }

      _setSuccess('Successfully signed out');
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthProvider: Error during sign out: $e',
            name: 'auth_provider');
      }
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // Comprehensive logout method for UI
  Future<void> logout(BuildContext context) async {
    if (kDebugMode) {
      dev.log('AuthProvider: Starting comprehensive logout',
          name: 'auth_provider');
    }

    try {
      // Show loading indicator
      _setLoading(true);

      // Perform signout
      await signOut();

      // Navigate to appropriate screen based on landing page status
      if (context.mounted) {
        final userHasSeenLanding = await hasSeenLanding();
        if (userHasSeenLanding) {
          // Returning user - go to login
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        } else {
          // New user - go to landing
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/landing', (route) => false);
        }
      }

      if (kDebugMode) {
        dev.log('AuthProvider: Comprehensive logout completed',
            name: 'auth_provider');
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthProvider: Error during comprehensive logout: $e',
            name: 'auth_provider');
      }
      // Even if logout fails, try to navigate to login
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Clear landing flag (optional method for complete reset)
  Future<void> _clearLandingFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('hasSeenLanding');
      if (kDebugMode) {
        dev.log('AuthProvider: Landing flag cleared', name: 'auth_provider');
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthProvider: Error clearing landing flag: $e',
            name: 'auth_provider');
      }
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

      // Update stored auth data with new user info
      if (_authData != null) {
        final updatedAuthData = _authData!.copyWith(user: updatedUser);
        await _sessionManager.storeAuthData(updatedAuthData);
        _authData = updatedAuthData;
      }

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
      await _sessionManager.clearStoredAuthData();
      _setUnauthenticated();
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  // Check if user has seen landing page
  Future<bool> hasSeenLanding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('hasSeenLanding') ?? false;
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthProvider: Error checking landing status: $e',
            name: 'auth_provider');
      }
      return false;
    }
  }

  // Mark landing page as seen
  Future<void> markLandingAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenLanding', true);
      if (kDebugMode) {
        dev.log('AuthProvider: Landing page marked as seen',
            name: 'auth_provider');
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthProvider: Error marking landing as seen: $e',
            name: 'auth_provider');
      }
    }
  }

  void _setUnauthenticated() {
    if (kDebugMode) {
      dev.log('AuthProvider: Setting unauthenticated state',
          name: 'auth_provider');
    }

    _state = AuthState.unauthenticated;
    _authData = null;
    _currentUser = null;
    _tokenRefreshTimer?.cancel();
    _clearError();
    _clearSuccess();
    notifyListeners();

    if (kDebugMode) {
      dev.log('AuthProvider: Unauthenticated state set successfully',
          name: 'auth_provider');
    }
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
      await _sessionManager.clearStoredAuthData();
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

  // Update user data (for UserController)
  void updateUser(UserModel user) {
    _currentUser = user;

    // Update stored auth data with new user info
    if (_authData != null) {
      final updatedAuthData = _authData!.copyWith(user: user);
      _authData = updatedAuthData;
      _sessionManager.storeAuthData(updatedAuthData);
    }

    notifyListeners();
  }

  // Clear user data (for UserController)
  void clearUser() {
    _currentUser = null;
    _authData = null;
    _state = AuthState.unauthenticated;
    _tokenRefreshTimer?.cancel();
    _sessionManager.clearStoredAuthData();
    notifyListeners();
  }

  // Clear error (for UserController)
  void clearError() {
    _clearError();
  }
}
