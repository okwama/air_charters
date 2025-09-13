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
import 'package:provider/provider.dart';
import 'navigation_provider.dart';
import '../routes/app_routes.dart';

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
      rethrow;
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

  // Phone Authentication with Twilio SMS
  Future<void> sendPhoneVerification(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      dev.log('Sending SMS verification to: $phoneNumber',
          name: 'AuthProvider');

      // Call the SMS verification endpoint
      await _authRepository.sendPhoneVerification(phoneNumber);

      _setLoading(false);
      _setSuccess('Verification code sent to $phoneNumber');
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  Future<void> verifyPhoneCode(String phoneNumber, String smsCode) async {
    _setLoading(true);
    _clearError();

    try {
      dev.log('Verifying SMS code for: $phoneNumber', name: 'AuthProvider');

      // Call the SMS verification endpoint
      final isVerified =
          await _authRepository.verifySmsCode(phoneNumber, smsCode);

      if (isVerified) {
        _setSuccess('Phone verification successful!');
      } else {
        _setError('Invalid verification code');
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // Email/Password Authentication
  Future<void> signInWithEmail(String email, String password) async {
    // Removed debug print
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Removed debug print
      final authData = await _authRepository.signInWithEmail(email, password);
      // Removed debug print
      await _setAuthenticatedWithToken(authData);
      _successMessage =
          'Login successful! Welcome back, ${authData.user.firstName}';
      // Removed debug print
    } catch (e) {
      // Removed debug print
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String firstName, String lastName) async {
    // Removed debug print
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
      // Re-throw to let the calling method handle it
      rethrow;
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

      // Add timeout to prevent hanging
      await Future.any([
        _performLogout(context),
        Future.delayed(const Duration(seconds: 10), () {
          throw Exception('Logout timeout - taking too long');
        }),
      ]);
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthProvider: Error during comprehensive logout: $e',
            name: 'auth_provider');
      }

      // Stop loading even if logout fails
      _setLoading(false);

      // Even if logout fails, try to navigate to login
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    }
  }

  // Separate method for the actual logout process
  Future<void> _performLogout(BuildContext context) async {
    // Clear navigation tracking data before logout
    try {
      final navigationProvider =
          Provider.of<NavigationProvider>(context, listen: false);
      navigationProvider.clearNavigationHistory();
      if (kDebugMode) {
        dev.log('AuthProvider: Navigation history cleared',
            name: 'auth_provider');
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthProvider: Error clearing navigation history: $e',
            name: 'auth_provider');
      }
      // Don't fail logout if navigation cleanup fails
    }

    // Perform signout
    await signOut();

    // Stop loading before navigation
    _setLoading(false);

    // Navigate to appropriate screen based on landing page status
    if (context.mounted) {
      try {
        final userHasSeenLanding = await hasSeenLanding();
        if (userHasSeenLanding) {
          // Returning user - go to login
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        } else {
          // New user - go to landing
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.landing, (route) => false);
        }
      } catch (e) {
        if (kDebugMode) {
          dev.log('AuthProvider: Error during navigation: $e',
              name: 'auth_provider');
        }
        // Fallback to login if navigation fails
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    }

    if (kDebugMode) {
      dev.log('AuthProvider: Comprehensive logout completed',
          name: 'auth_provider');
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
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthProvider: Error marking landing as seen: $e',
            name: 'auth_provider');
      }
    }
  }

  // Global authentication error handler for all services
  Future<AuthErrorResult> handleGlobalAuthError(dynamic error) async {
    if (kDebugMode) {
      dev.log('AuthProvider: Handling global auth error: $error',
          name: 'auth_provider');
    }

    try {
      if (error is AuthException) {
        // Check if this is a 401 error that might be resolved with token refresh
        if (error.message.contains('401') ||
            error.message.contains('expired') ||
            error.message.contains('Invalid')) {
          if (kDebugMode) {
            dev.log('AuthProvider: Attempting token refresh for auth error',
                name: 'auth_provider');
          }

          try {
            await refreshToken();
            if (kDebugMode) {
              dev.log(
                  'AuthProvider: Token refresh successful, retry recommended',
                  name: 'auth_provider');
            }
            return AuthErrorResult(
              shouldRetry: true,
              shouldRedirectToLogin: false,
              message: 'Session refreshed successfully',
              action: AuthErrorAction.retry,
            );
          } catch (refreshError) {
            if (kDebugMode) {
              dev.log('AuthProvider: Token refresh failed: $refreshError',
                  name: 'auth_provider');
            }
            await signOut();
            return AuthErrorResult(
              shouldRetry: false,
              shouldRedirectToLogin: true,
              message: 'Session expired. Please login again.',
              action: AuthErrorAction.redirectToLogin,
            );
          }
        } else {
          // Other auth errors (403, etc.)
          return AuthErrorResult(
            shouldRetry: false,
            shouldRedirectToLogin: false,
            message: error.message,
            action: AuthErrorAction.showError,
          );
        }
      } else {
        // Non-auth errors
        return AuthErrorResult(
          shouldRetry: false,
          shouldRedirectToLogin: false,
          message: 'An unexpected error occurred',
          action: AuthErrorAction.showError,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('AuthProvider: Error in global auth error handler: $e',
            name: 'auth_provider');
      }
      return AuthErrorResult(
        shouldRetry: false,
        shouldRedirectToLogin: true,
        message: 'Authentication error occurred',
        action: AuthErrorAction.redirectToLogin,
      );
    }
  }

  // Check if user should be redirected to login
  bool shouldRedirectToLogin() {
    return _state == AuthState.unauthenticated || _state == AuthState.error;
  }

  // Get current authentication status for UI
  String getAuthenticationStatusMessage() {
    switch (_state) {
      case AuthState.initial:
        return 'Initializing...';
      case AuthState.loading:
        return 'Loading...';
      case AuthState.authenticated:
        return _authData?.isExpired == true
            ? 'Session expired'
            : 'Authenticated';
      case AuthState.unauthenticated:
        return 'Not authenticated';
      case AuthState.error:
        return _errorMessage ?? 'Authentication error';
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

// Authentication error result for global handling
class AuthErrorResult {
  final bool shouldRetry;
  final bool shouldRedirectToLogin;
  final String message;
  final AuthErrorAction action;

  const AuthErrorResult({
    required this.shouldRetry,
    required this.shouldRedirectToLogin,
    required this.message,
    required this.action,
  });
}
