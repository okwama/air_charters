import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../core/models/auth_model.dart';
import '../../core/models/user_model.dart';
import '../../config/env/app_config.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Pure token management - no authentication state decisions
  Timer? _tokenMonitorTimer;
  bool _isMonitoring = false;

  // Initialize session manager (simplified)
  void initialize() {
    _startTokenMonitoring();
  }

  // Start token monitoring
  void _startTokenMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _tokenMonitorTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkTokenValidity();
    });
  }

  // Stop token monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _tokenMonitorTimer?.cancel();
    _tokenMonitorTimer = null;
  }

  // Check token validity (simplified)
  Future<void> _checkTokenValidity() async {
    try {
      final authData = await getStoredAuthData();
      if (authData != null && authData.isExpired) {
        if (kDebugMode) {
          dev.log('SessionManager: Stored token is expired',
              name: 'session_manager');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('SessionManager: Error checking token validity: $e',
            name: 'session_manager');
      }
    }
  }

  // Get stored auth data
  Future<AuthModel?> getStoredAuthData() async {
    try {
      final authJson = await _storage.read(key: AppConfig.authStorageKey);
      if (authJson != null) {
        return AuthModel.fromJson(jsonDecode(authJson));
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('SessionManager: Error reading stored auth data: $e',
            name: 'session_manager');
      }
    }
    return null;
  }

  // Store auth data
  Future<void> storeAuthData(AuthModel authData) async {
    try {
      await _storage.write(
        key: AppConfig.authStorageKey,
        value: jsonEncode(authData.toJson()),
      );
      if (kDebugMode) {
        dev.log('SessionManager: Auth data stored successfully',
            name: 'session_manager');
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('SessionManager: Error storing auth data: $e',
            name: 'session_manager');
      }
    }
  }

  // Clear stored auth data
  Future<void> clearStoredAuthData() async {
    try {
      await _storage.delete(key: AppConfig.authStorageKey);
      if (kDebugMode) {
        dev.log('SessionManager: Auth data cleared', name: 'session_manager');
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('SessionManager: Error clearing auth data: $e',
            name: 'session_manager');
      }
    }
  }

  // Get authorization header for API requests
  Future<String?> getAuthorizationHeader() async {
    try {
      final authData = await getStoredAuthData();
      if (authData != null && !authData.isExpired) {
        if (kDebugMode) {
          dev.log('SessionManager: Using stored token for authorization',
              name: 'session_manager');
        }
        return authData.authorizationHeader;
      } else if (authData != null &&
          authData.isExpired &&
          authData.refreshToken.isNotEmpty) {
        if (kDebugMode) {
          dev.log('SessionManager: Token expired, attempting refresh',
              name: 'session_manager');
        }

        // Try to refresh the token
        try {
          final refreshedAuthData = await _refreshToken(authData.refreshToken);
          if (refreshedAuthData != null) {
            await storeAuthData(refreshedAuthData);
            if (kDebugMode) {
              dev.log('SessionManager: Token refreshed successfully',
                  name: 'session_manager');
            }
            return refreshedAuthData.authorizationHeader;
          }
        } catch (refreshError) {
          if (kDebugMode) {
            dev.log('SessionManager: Token refresh failed: $refreshError',
                name: 'session_manager');
          }
          // Clear invalid auth data
          await clearStoredAuthData();
        }
      } else {
        if (kDebugMode) {
          dev.log('SessionManager: No valid token available for authorization',
              name: 'session_manager');
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        dev.log('SessionManager: Error getting authorization header: $e',
            name: 'session_manager');
      }
      return null;
    }
  }

  // Refresh token using refresh token
  Future<AuthModel?> _refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.backendUrl}${AppConfig.refreshTokenEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final user = UserModel.fromJson(data['data']['user']);
          final newToken = data['data']['accessToken'];
          final newRefreshToken = data['data']['refreshToken'];

          return AuthModel(
            user: user,
            accessToken: newToken,
            refreshToken: newRefreshToken,
            tokenType: 'Bearer',
            expiresIn: 86400,
            expiresAt: DateTime.now().add(const Duration(hours: 24)),
          );
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        dev.log('SessionManager: Error refreshing token: $e',
            name: 'session_manager');
      }
      return null;
    }
  }

  // Enhanced method to get auth headers with better error handling
  Future<Map<String, String>> getAuthHeaders() async {
    final authHeader = await getAuthorizationHeader();

    if (authHeader != null) {
      if (kDebugMode) {
        dev.log(
            'SessionManager: Authorization header added: ${authHeader.substring(0, 20)}...',
            name: 'session_manager');
      }
      return {
        'Content-Type': 'application/json',
        'Authorization': authHeader,
      };
    } else {
      if (kDebugMode) {
        dev.log(
            'SessionManager: No Authorization header added (no valid token)',
            name: 'session_manager');
      }
      return {
        'Content-Type': 'application/json',
      };
    }
  }

  // New method to check authentication status with detailed information
  Future<AuthStatus> getAuthenticationStatus() async {
    try {
      final authData = await getStoredAuthData();

      if (authData == null) {
        return AuthStatus(
          isAuthenticated: false,
          status: AuthStatusType.noToken,
          message: 'No authentication token found',
          canRefresh: false,
        );
      }

      if (authData.isExpired) {
        if (authData.refreshToken.isNotEmpty) {
          return AuthStatus(
            isAuthenticated: false,
            status: AuthStatusType.expiredToken,
            message: 'Session expired, but refresh token available',
            canRefresh: true,
            expiresAt: authData.expiresAt,
            refreshToken: authData.refreshToken,
          );
        } else {
          return AuthStatus(
            isAuthenticated: false,
            status: AuthStatusType.expiredToken,
            message: 'Session expired, no refresh token available',
            canRefresh: false,
            expiresAt: authData.expiresAt,
          );
        }
      }

      if (authData.willExpireSoon) {
        return AuthStatus(
          isAuthenticated: true,
          status: AuthStatusType.validToken,
          message: 'Session valid but expiring soon',
          canRefresh: true,
          expiresAt: authData.expiresAt,
          refreshToken: authData.refreshToken,
        );
      }

      return AuthStatus(
        isAuthenticated: true,
        status: AuthStatusType.validToken,
        message: 'Session valid',
        canRefresh: true,
        expiresAt: authData.expiresAt,
        refreshToken: authData.refreshToken,
      );
    } catch (e) {
      if (kDebugMode) {
        dev.log('SessionManager: Error checking auth status: $e',
            name: 'session_manager');
      }
      return AuthStatus(
        isAuthenticated: false,
        status: AuthStatusType.error,
        message: 'Error checking authentication status',
        canRefresh: false,
      );
    }
  }

  // New method to validate token format
  Future<bool> validateTokenFormat() async {
    try {
      final authData = await getStoredAuthData();
      if (authData == null) return false;

      // Check if token has proper format (Bearer token should be non-empty)
      if (authData.accessToken.isEmpty) return false;

      // Check if token type is valid
      if (authData.tokenType.isEmpty) return false;

      // Check if refresh token exists (optional but recommended)
      if (authData.refreshToken.isEmpty) {
        if (kDebugMode) {
          dev.log('SessionManager: Warning - No refresh token available',
              name: 'session_manager');
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        dev.log('SessionManager: Token format validation error: $e',
            name: 'session_manager');
      }
      return false;
    }
  }

  // New method to handle authentication errors gracefully
  Future<AuthErrorHandling> handleAuthError(
      int statusCode, String? errorMessage) async {
    switch (statusCode) {
      case 401:
        final authStatus = await getAuthenticationStatus();

        if (authStatus.status == AuthStatusType.expiredToken &&
            authStatus.canRefresh) {
          // Try to refresh token
          try {
            final refreshed =
                await _refreshToken(authStatus.refreshToken ?? '');
            if (refreshed != null) {
              await storeAuthData(refreshed);
              return AuthErrorHandling(
                shouldRetry: true,
                shouldRedirectToLogin: false,
                message: 'Session refreshed successfully',
                action: AuthErrorAction.retry,
              );
            }
          } catch (e) {
            if (kDebugMode) {
              dev.log('SessionManager: Token refresh failed: $e',
                  name: 'session_manager');
            }
          }
        }

        // Clear invalid auth data and redirect to login
        await clearStoredAuthData();
        return AuthErrorHandling(
          shouldRetry: false,
          shouldRedirectToLogin: true,
          message: errorMessage ?? 'Session expired. Please login again.',
          action: AuthErrorAction.redirectToLogin,
        );

      case 403:
        return AuthErrorHandling(
          shouldRetry: false,
          shouldRedirectToLogin: false,
          message: errorMessage ??
              'Access denied. You don\'t have permission for this action.',
          action: AuthErrorAction.showError,
        );

      default:
        return AuthErrorHandling(
          shouldRetry: false,
          shouldRedirectToLogin: false,
          message: errorMessage ?? 'Authentication error occurred.',
          action: AuthErrorAction.showError,
        );
    }
  }

  // Debug method to check token status
  Future<void> debugTokenStatus() async {
    if (kDebugMode) {
      dev.log('=== SessionManager Debug Info ===', name: 'session_manager');

      final authData = await getStoredAuthData();
      if (authData != null) {
        dev.log('Token expires at: ${authData.expiresAt}',
            name: 'session_manager');
        dev.log('Token is expired: ${authData.isExpired}',
            name: 'session_manager');
        dev.log('Token will expire soon: ${authData.willExpireSoon}',
            name: 'session_manager');

        final authHeader = authData.authorizationHeader;
        if (authHeader.isNotEmpty) {
          dev.log(
              'Authorization header: ${authHeader.length > 20 ? authHeader.substring(0, 20) : authHeader}...',
              name: 'session_manager');
        } else {
          dev.log('Authorization header: empty', name: 'session_manager');
        }
      } else {
        dev.log('No stored auth data found', name: 'session_manager');
      }

      dev.log('=== End Debug Info ===', name: 'session_manager');
    }
  }

  // Dispose resources
  void dispose() {
    stopMonitoring();
  }
}

// Authentication status information
class AuthStatus {
  final bool isAuthenticated;
  final AuthStatusType status;
  final String message;
  final bool canRefresh;
  final DateTime? expiresAt;
  final String? refreshToken;

  const AuthStatus({
    required this.isAuthenticated,
    required this.status,
    required this.message,
    required this.canRefresh,
    this.expiresAt,
    this.refreshToken,
  });
}

// Authentication status types
enum AuthStatusType {
  noToken,
  validToken,
  expiredToken,
  error,
}

// Authentication error handling result
class AuthErrorHandling {
  final bool shouldRetry;
  final bool shouldRedirectToLogin;
  final String message;
  final AuthErrorAction action;

  const AuthErrorHandling({
    required this.shouldRetry,
    required this.shouldRedirectToLogin,
    required this.message,
    required this.action,
  });
}

// Authentication error actions
enum AuthErrorAction {
  retry,
  redirectToLogin,
  showError,
  ignore,
}
