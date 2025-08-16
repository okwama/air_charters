import 'package:flutter/material.dart';
import '../network/api_client.dart';
import 'auth_provider.dart';
import '../../shared/utils/session_manager.dart';

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

    // Use standardized authentication check
    final isAuthenticated = _authProvider?.isAuthenticated == true &&
        _authProvider?.hasValidToken == true;

    print(
        '🔥 PROFILE: AuthProvider - isAuthenticated: ${_authProvider?.isAuthenticated}');
    print(
        '🔥 PROFILE: AuthProvider - hasValidToken: ${_authProvider?.hasValidToken}');
    print('🔥 PROFILE: Final isAuthenticated: $isAuthenticated');

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
      final sessionManager = SessionManager();
      final authHeader = await sessionManager.getAuthorizationHeader();
      if (authHeader != null) {
        print('🔥 PROFILE: Authorization header: $authHeader');
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

        // Try to refresh the token using AuthProvider
        try {
          print('🔥 PROFILE: Attempting token refresh...');
          await _authProvider?.refreshToken();
          print('🔥 PROFILE: Token refresh completed');

          // Check if refresh was successful
          if (_authProvider?.hasValidToken == true) {
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
    // Use standardized AuthProvider check
    return _authProvider?.isAuthenticated == true &&
        _authProvider?.hasValidToken == true;
  }
}
