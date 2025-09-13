import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

/// Helper class to test logout functionality
class LogoutTestHelper {
  /// Test logout with detailed logging
  static Future<void> testLogout(BuildContext context) async {
    if (kDebugMode) {
      print('🧪 LOGOUT TEST: Starting logout test...');
    }

    final authProvider = context.read<AuthProvider>();

    // Check initial state
    if (kDebugMode) {
      print('🧪 LOGOUT TEST: Initial auth state: ${authProvider.state}');
      print(
          '🧪 LOGOUT TEST: Is authenticated: ${authProvider.isAuthenticated}');
      print('🧪 LOGOUT TEST: Is loading: ${authProvider.isLoading}');
    }

    try {
      // Perform logout
      await authProvider.logout(context);

      if (kDebugMode) {
        print('🧪 LOGOUT TEST: Logout completed successfully');
        print('🧪 LOGOUT TEST: Final auth state: ${authProvider.state}');
        print(
            '🧪 LOGOUT TEST: Is authenticated: ${authProvider.isAuthenticated}');
        print('🧪 LOGOUT TEST: Is loading: ${authProvider.isLoading}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🧪 LOGOUT TEST: Logout failed with error: $e');
      }
      rethrow;
    }
  }

  /// Test logout with timeout
  static Future<void> testLogoutWithTimeout(BuildContext context,
      {Duration timeout = const Duration(seconds: 5)}) async {
    if (kDebugMode) {
      print(
          '🧪 LOGOUT TEST: Starting logout test with ${timeout.inSeconds}s timeout...');
    }

    try {
      await Future.any([
        testLogout(context),
        Future.delayed(timeout, () {
          throw Exception(
              'Logout test timed out after ${timeout.inSeconds} seconds');
        }),
      ]);

      if (kDebugMode) {
        print('🧪 LOGOUT TEST: Logout completed within timeout');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🧪 LOGOUT TEST: Logout test failed: $e');
      }
      rethrow;
    }
  }

  /// Verify logout state
  static bool verifyLogoutState(AuthProvider authProvider) {
    final isLoggedOut = !authProvider.isAuthenticated &&
        !authProvider.isLoading &&
        authProvider.state == AuthState.unauthenticated;

    if (kDebugMode) {
      print('🧪 LOGOUT TEST: Logout state verification:');
      print('  - Is authenticated: ${authProvider.isAuthenticated}');
      print('  - Is loading: ${authProvider.isLoading}');
      print('  - Auth state: ${authProvider.state}');
      print('  - Logout successful: $isLoggedOut');
    }

    return isLoggedOut;
  }
}
