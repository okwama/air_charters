import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'lib/shared/utils/session_manager.dart';
import 'lib/core/providers/auth_provider.dart';

void main() {
  testTokenHandling();
}

void testTokenHandling() {
  print('🧪 Testing Token Handling...');

  // Test SessionManager
  final sessionManager = SessionManager();

  // Test getAuthHeaders without AuthProvider
  final headers = sessionManager.getAuthHeaders();
  print('Headers without AuthProvider: $headers');

  // Test getAuthorizationHeader without AuthProvider
  final authHeader = sessionManager.getAuthorizationHeader();
  print('Auth header without AuthProvider: $authHeader');

  // Test session status
  final status = sessionManager.getSessionStatus();
  print('Session status: $status');

  print('🧪 Token handling test completed');
}
