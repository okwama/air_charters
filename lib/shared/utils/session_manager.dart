import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/auth_model.dart';

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
          print('SessionManager: Token validation failed, user signed out');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('SessionManager: Error checking token validity: $e');
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
        print('SessionManager: Error refreshing token: $e');
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

  // Dispose resources
  void dispose() {
    stopMonitoring();
    _authProvider = null;
  }
}
