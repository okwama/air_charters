import 'package:flutter/material.dart';
import '../network/api_client.dart';
import '../models/auth_model.dart';
import 'auth_provider.dart';
import '../../shared/utils/session_manager.dart';
import 'dart:developer' as dev;

class ProfileProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  AuthProvider? _authProvider;

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? get profile => _profile;

  Map<String, dynamic>? _preferences;
  Map<String, dynamic>? get preferences => _preferences;

  bool _loading = false;
  bool get loading => _loading;

  // Set the auth provider reference
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchProfile() async {
    print('🔥 PROFILE: fetchProfile');

    // Check if user is authenticated using SessionManager
    final sessionManager = SessionManager();
    final isAuthenticated = sessionManager.isSessionActive;
    final sessionStatus = sessionManager.getSessionStatus();

    print('🔥 PROFILE: SessionManager - isAuthenticated: $isAuthenticated');
    print('🔥 PROFILE: SessionManager - sessionStatus: $sessionStatus');

    if (!isAuthenticated) {
      print('🔥 PROFILE: User not authenticated, skipping API call');
      _loading = false;
      notifyListeners();
      return; // Don't make API call if not authenticated
    }

    _loading = true;
    notifyListeners();

    try {
      // Debug: Check what token is being sent
      final authHeader = sessionManager.getAuthorizationHeader();
      if (authHeader != null && authHeader.isNotEmpty) {
        print(
            '🔥 PROFILE: Authorization header: ${authHeader.length > 20 ? authHeader.substring(0, 20) : authHeader}...');
      } else {
        print('🔥 PROFILE: Authorization header: null or empty');
      }

      final data = await _apiClient.getUserProfile();
      print('🔥 PROFILE: API call successful');
      _profile = data;
      _preferences = data['preferences'];
    } catch (e) {
      print('🔥 PROFILE: API call failed: $e');

      // Handle authentication errors gracefully
      if (e.toString().contains('Authentication failed')) {
        print('🔥 PROFILE: Authentication failed, clearing profile data');

        // Clear profile data
        _profile = null;
        _preferences = null;

        // Try to refresh the token
        try {
          print('🔥 PROFILE: Attempting token refresh...');
          final refreshed = await sessionManager.forceTokenRefresh();
          print('🔥 PROFILE: Token refresh result: $refreshed');

          if (refreshed) {
            // Try fetching profile again with refreshed token
            print('🔥 PROFILE: Retrying profile fetch with refreshed token...');
            final data = await _apiClient.getUserProfile();
            _profile = data;
            _preferences = data['preferences'];
            print('🔥 PROFILE: Retry successful');
          } else {
            print(
                '🔥 PROFILE: Token refresh failed, user needs to login again');
            // Don't rethrow - let the UI handle the unauthenticated state
          }
        } catch (refreshError) {
          print('🔥 PROFILE: Token refresh error: $refreshError');
          // Don't rethrow - let the UI handle the unauthenticated state
        }
      } else {
        // For non-auth errors, rethrow
        rethrow;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _apiClient.updateUserProfile(profileData);
      _profile = data['user'];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updatePreferences(Map<String, dynamic> preferencesData) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _apiClient.updateUserPreferences(preferencesData);
      _preferences = data['preferences'];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Check if profile can be fetched (user is authenticated)
  bool get canFetchProfile {
    final sessionManager = SessionManager();
    return sessionManager.isSessionActive;
  }
}
