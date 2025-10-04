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

  // Industry standard caching
  static const Duration _cacheTTL = Duration(minutes: 30);
  DateTime? _lastFetch;
  bool _isRefreshing = false;

  // Set the auth provider reference
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  // Industry standard: Check if profile should be refreshed
  bool get shouldRefreshProfile {
    return _profile == null ||
        _lastFetch == null ||
        DateTime.now().difference(_lastFetch!) > _cacheTTL;
  }

  // Industry standard: Check if profile data is stale
  bool get isProfileStale {
    if (_lastFetch == null) return true;
    return DateTime.now().difference(_lastFetch!) > Duration(minutes: 15);
  }

  // Industry standard: Smart fetch - only when needed
  Future<void> fetchProfileIfNeeded({bool forceRefresh = false}) async {
    if (!forceRefresh && !shouldRefreshProfile) {
      print('🔥 PROFILE: Using cached data, skipping API call');
      return;
    }

    // If data is stale but exists, show it immediately and refresh in background
    if (!forceRefresh && _profile != null && isProfileStale && !_isRefreshing) {
      print('🔥 PROFILE: Data is stale, refreshing in background');
      _refreshInBackground();
      return;
    }

    await fetchProfile(forceRefresh: forceRefresh);
  }

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    print('🔥 PROFILE: fetchProfile (forceRefresh: $forceRefresh)');

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
      _lastFetch = DateTime.now(); // Record successful fetch time
    } catch (e) {
      print('🔥 PROFILE: API call failed: $e');

      // Handle authentication errors gracefully
      if (e.toString().contains('Authentication failed') ||
          e.toString().contains('Invalid or expired token') ||
          e.toString().contains('401')) {
        print('🔥 PROFILE: Authentication failed, clearing profile data');

        // Clear profile data
        _profile = null;
        _preferences = null;

        // Use the global auth error handler for proper token refresh and logout handling
        try {
          print('🔥 PROFILE: Using global auth error handler...');
          final authErrorResult = await _authProvider?.handleGlobalAuthError(e);

          if (authErrorResult?.shouldRetry == true) {
            // Token was refreshed successfully, retry the profile fetch
            print('🔥 PROFILE: Token refreshed, retrying profile fetch...');
            final data = await _apiClient.getUserProfile();
            _profile = data;
            _preferences = data['preferences'];
            print('🔥 PROFILE: Retry successful');
          } else if (authErrorResult?.shouldRedirectToLogin == true) {
            print('🔥 PROFILE: User needs to login again');
            // The auth provider should have already handled the logout
          }
        } catch (authError) {
          print('🔥 PROFILE: Global auth error handler failed: $authError');
          // Fallback: try direct token refresh
          try {
            print('🔥 PROFILE: Fallback - attempting direct token refresh...');
            await _authProvider?.refreshToken();

            if (_authProvider?.hasValidToken == true) {
              print('🔥 PROFILE: Fallback refresh successful, retrying...');
              final data = await _apiClient.getUserProfile();
              _profile = data;
              _preferences = data['preferences'];
            } else {
              print('🔥 PROFILE: Fallback refresh failed, signing out...');
              await _authProvider?.signOut();
            }
          } catch (fallbackError) {
            print(
                '🔥 PROFILE: Fallback refresh error, signing out: $fallbackError');
            await _authProvider?.signOut();
          }
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

  // Industry standard: Background refresh for stale data
  Future<void> _refreshInBackground() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    try {
      print('🔥 PROFILE: Starting background refresh...');
      await fetchProfile(forceRefresh: true);
      print('🔥 PROFILE: Background refresh completed');
    } catch (e) {
      print('🔥 PROFILE: Background refresh failed: $e');
      // Don't update UI on background refresh failure
    } finally {
      _isRefreshing = false;
    }
  }

  // Industry standard: Clear cache method
  void clearCache() {
    _profile = null;
    _preferences = null;
    _lastFetch = null;
    notifyListeners();
  }

  // Industry standard: Pull-to-refresh method
  Future<void> refreshProfile() async {
    await fetchProfileIfNeeded(forceRefresh: true);
  }
}
