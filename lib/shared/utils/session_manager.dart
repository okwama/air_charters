import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/network/api_client.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  Timer? _tokenMonitorTimer;
  AuthProvider? _authProvider;
  bool _isMonitoring = false;

  // Initialize session manager
  void initialize(AuthProvider authProvider) {
    _authProvider = authProvider;
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

  // Check token validity
  Future<void> _checkTokenValidity() async {
    if (_authProvider == null) return;

    try {
      final isValid = await _authProvider!.validateToken();
      if (!isValid) {
        // Token is invalid, user will be signed out automatically
        if (kDebugMode) {
          dev.log('SessionManager: Token validation failed, user signed out',
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

  // Get current token info
  Map<String, dynamic>? getTokenInfo() {
    if (_authProvider?.authData == null) return null;

    final authData = _authProvider!.authData!;
    final now = DateTime.now();
    final expiresIn = authData.expiresAt.difference(now);

    return {
      'isValid': !authData.isExpired,
      'willExpireSoon': authData.willExpireSoon,
      'expiresIn': expiresIn.inSeconds,
      'expiresAt': authData.expiresAt.toIso8601String(),
      'tokenType': authData.tokenType,
      'accessToken': authData.accessToken, // Add the access token
      'user': {
        'id': authData.user.id,
        'email': authData.user.email,
        'name': authData.user.fullName,
      },
    };
  }

  // Force token refresh
  Future<bool> forceTokenRefresh() async {
    if (_authProvider == null) return false;

    try {
      await _authProvider!.refreshToken();
      return _authProvider!.hasValidToken;
    } catch (e) {
      if (kDebugMode) {
        dev.log('SessionManager: Error refreshing token: $e',
            name: 'session_manager');
      }
      return false;
    }
  }

  // Check if session is active
  bool get isSessionActive {
    return _authProvider?.isAuthenticated == true &&
        _authProvider?.hasValidToken == true;
  }

  // Get session status
  Map<String, dynamic> getSessionStatus() {
    return {
      'isAuthenticated': _authProvider?.isAuthenticated ?? false,
      'hasValidToken': _authProvider?.hasValidToken ?? false,
      'isLoading': _authProvider?.isLoading ?? false,
      'tokenInfo': getTokenInfo(),
      'user': _authProvider?.currentUser?.toJson(),
    };
  }

  // Get authorization header for API requests
  String? getAuthorizationHeader() {
    try {
      // First try to get from AuthProvider
      if (_authProvider?.authData != null) {
        final authData = _authProvider!.authData!;
        if (!authData.isExpired) {
          if (kDebugMode) {
            dev.log('SessionManager: Using AuthProvider token',
                name: 'session_manager');
          }
          return authData.authorizationHeader;
        } else {
          if (kDebugMode) {
            dev.log('SessionManager: AuthProvider token is expired',
                name: 'session_manager');
          }
        }
      }

      // Fallback: try to get from ApiClient storage
      if (kDebugMode) {
        dev.log(
            'SessionManager: AuthProvider token not available, trying ApiClient',
            name: 'session_manager');
      }

      // Note: We can't directly access ApiClient here, but we can try to refresh the token
      // This is a temporary workaround - in a real app, you'd want to inject the ApiClient
      return null;
    } catch (e) {
      if (kDebugMode) {
        dev.log('SessionManager: Error getting authorization header: $e',
            name: 'session_manager');
      }
      return null;
    }
  }

  // Enhanced method to get auth headers with better error handling
  Map<String, String> getAuthHeaders() {
    final authHeader = getAuthorizationHeader();

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
            'SessionManager: No Authorization header added (authData null or expired)',
            name: 'session_manager');
      }
      return {
        'Content-Type': 'application/json',
      };
    }
  }

  // Debug method to check token status
  void debugTokenStatus() {
    if (kDebugMode) {
      dev.log('=== SessionManager Debug Info ===', name: 'session_manager');
      dev.log('AuthProvider is null: ${_authProvider == null}',
          name: 'session_manager');
      dev.log(
          'AuthProvider authData is null: ${_authProvider?.authData == null}',
          name: 'session_manager');

      if (_authProvider?.authData != null) {
        final authData = _authProvider!.authData!;
        dev.log('Token expires at: ${authData.expiresAt}',
            name: 'session_manager');
        dev.log('Token is expired: ${authData.isExpired}',
            name: 'session_manager');
        dev.log('Token will expire soon: ${authData.willExpireSoon}',
            name: 'session_manager');

        // Safe substring operation
        final authHeader = authData.authorizationHeader;
        if (authHeader.isNotEmpty) {
          dev.log(
              'Authorization header: ${authHeader.length > 20 ? authHeader.substring(0, 20) : authHeader}...',
              name: 'session_manager');
        } else {
          dev.log('Authorization header: empty', name: 'session_manager');
        }
      }

      dev.log('Session is active: $isSessionActive', name: 'session_manager');
      dev.log('=== End Debug Info ===', name: 'session_manager');
    }
  }

  // Dispose resources
  void dispose() {
    stopMonitoring();
    _authProvider = null;
  }
}
