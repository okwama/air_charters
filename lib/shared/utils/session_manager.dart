import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/models/auth_model.dart';
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

  // Debug method to check token status
  void debugTokenStatus() async {
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
