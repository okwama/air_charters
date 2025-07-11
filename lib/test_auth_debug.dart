import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_provider.dart';
import 'shared/utils/session_manager.dart';
import 'core/network/api_client.dart';
import 'dart:developer' as dev;

class AuthDebugScreen extends StatefulWidget {
  const AuthDebugScreen({super.key});

  @override
  State<AuthDebugScreen> createState() => _AuthDebugScreenState();
}

class _AuthDebugScreenState extends State<AuthDebugScreen> {
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _runDebugTests();
  }

  // Helper method to safely get substring
  String _safeSubstring(String? text, int start, int end) {
    if (text == null || text.isEmpty) return 'null/empty';
    if (start >= text.length) return text;
    if (end > text.length) end = text.length;
    if (start >= end) return text;
    return text.substring(start, end);
  }

  Future<void> _runDebugTests() async {
    final debugInfo = StringBuffer();

    try {
      // Test 1: Check AuthProvider state
      debugInfo.writeln('=== AUTH PROVIDER DEBUG ===');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      debugInfo.writeln('AuthProvider state: ${authProvider.state}');
      debugInfo.writeln(
          'AuthProvider isAuthenticated: ${authProvider.isAuthenticated}');
      debugInfo
          .writeln('AuthProvider hasValidToken: ${authProvider.hasValidToken}');
      debugInfo.writeln('AuthProvider isLoading: ${authProvider.isLoading}');

      if (authProvider.authData != null) {
        debugInfo.writeln('AuthProvider authData exists: true');
        debugInfo
            .writeln('Token expires at: ${authProvider.authData!.expiresAt}');
        debugInfo
            .writeln('Token is expired: ${authProvider.authData!.isExpired}');
        debugInfo.writeln(
            'Authorization header: ${_safeSubstring(authProvider.authData!.authorizationHeader, 0, 20)}...');
      } else {
        debugInfo.writeln('AuthProvider authData exists: false');
      }

      // Test 2: Check SessionManager state
      debugInfo.writeln('\n=== SESSION MANAGER DEBUG ===');
      final sessionManager = SessionManager();
      debugInfo.writeln(
          'SessionManager isSessionActive: ${sessionManager.isSessionActive}');

      final sessionStatus = sessionManager.getSessionStatus();
      debugInfo.writeln('SessionManager sessionStatus: $sessionStatus');

      final authHeader = sessionManager.getAuthorizationHeader();
      debugInfo.writeln(
          'SessionManager authHeader: ${_safeSubstring(authHeader, 0, 20)}...');

      // Test 3: Check ApiClient state
      debugInfo.writeln('\n=== API CLIENT DEBUG ===');
      final apiClient = ApiClient();
      final isApiAuthenticated = await apiClient.isAuthenticated();
      debugInfo.writeln('ApiClient isAuthenticated: $isApiAuthenticated');

      final storedAuth = await apiClient.getAuth();
      if (storedAuth != null) {
        debugInfo.writeln('ApiClient stored auth exists: true');
        debugInfo.writeln('Stored token expires at: ${storedAuth.expiresAt}');
        debugInfo.writeln('Stored token is expired: ${storedAuth.isExpired}');
        debugInfo.writeln(
            'Stored auth header: ${_safeSubstring(storedAuth.authorizationHeader, 0, 20)}...');
      } else {
        debugInfo.writeln('ApiClient stored auth exists: false');
      }

      // Test 4: Test backend connectivity
      debugInfo.writeln('\n=== BACKEND CONNECTIVITY TEST ===');
      try {
        final isHealthy = await apiClient.checkBackendHealth();
        debugInfo.writeln('Backend health check: $isHealthy');
      } catch (e) {
        debugInfo.writeln('Backend health check failed: $e');
      }

      // Test 5: Test profile fetch
      debugInfo.writeln('\n=== PROFILE FETCH TEST ===');
      try {
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);
        await profileProvider.fetchProfile();

        if (profileProvider.profile != null) {
          debugInfo.writeln('Profile fetch successful');
          debugInfo.writeln('Profile data: ${profileProvider.profile}');
        } else {
          debugInfo.writeln('Profile fetch failed - no profile data');
        }
      } catch (e) {
        debugInfo.writeln('Profile fetch error: $e');
      }
    } catch (e) {
      debugInfo.writeln('Debug test error: $e');
      debugInfo.writeln('Error type: ${e.runtimeType}');
      debugInfo.writeln('Error stack trace: ${StackTrace.current}');
    }

    setState(() {
      _debugInfo = debugInfo.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDebugTests,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Authentication Debug Info',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _debugInfo,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Test login with backend
                try {
                  final apiClient = ApiClient();
                  final authModel =
                      await apiClient.authenticateWithBackend('test-token');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Login test successful: ${authModel.user.fullName}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login test failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Test Backend Login'),
            ),
          ],
        ),
      ),
    );
  }
}
