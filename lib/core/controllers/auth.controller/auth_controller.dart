import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

/// Controller to handle authentication and authorization business logic
class AuthController {
  final AuthProvider _authProvider;
  final AuthService _authService;

  AuthController({
    required AuthProvider authProvider,
    required AuthService authService,
  })  : _authProvider = authProvider,
        _authService = authService;

  /// Sign in user with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      final validation = validateSignInData(email: email, password: password);
      if (!validation.isValid) {
        return AuthResult.failure(validation.errors.first);
      }

      // Attempt sign in
      final user = await _authService.signIn(email: email, password: password);

      if (user != null) {
        return AuthResult.success(user);
      } else {
        return AuthResult.failure('Invalid email or password');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthController.signIn error: $e');
      }
      return AuthResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Sign up new user
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? country,
  }) async {
    try {
      // Validate input
      final validation = validateSignUpData(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      if (!validation.isValid) {
        return AuthResult.failure(validation.errors.first);
      }

      // Attempt sign up
      final user = await _authService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        country: country,
      );

      if (user != null) {
        return AuthResult.success(user);
      } else {
        return AuthResult.failure('Failed to create account');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthController.signUp error: $e');
      }
      return AuthResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Sign out current user
  Future<bool> signOut() async {
    try {
      final success = await _authService.signOut();
      if (success) {
        _authProvider.clearUser();
      }
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('AuthController.signOut error: $e');
      }
      return false;
    }
  }

  /// Refresh authentication token
  Future<AuthResult> refreshToken() async {
    try {
      final user = await _authService.refreshToken();
      if (user != null) {
        return AuthResult.success(user);
      } else {
        return AuthResult.failure('Failed to refresh token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthController.refreshToken error: $e');
      }
      return AuthResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      // Validate email
      if (email.isEmpty || !email.contains('@')) {
        return false;
      }

      return await _authService.resetPassword(email);
    } catch (e) {
      if (kDebugMode) {
        print('AuthController.resetPassword error: $e');
      }
      return false;
    }
  }

  /// Validate sign in data
  AuthValidationResult validateSignInData({
    required String email,
    required String password,
  }) {
    final errors = <String>[];

    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!email.contains('@')) {
      errors.add('Please enter a valid email address');
    }

    if (password.isEmpty) {
      errors.add('Password is required');
    } else if (password.length < 6) {
      errors.add('Password must be at least 6 characters');
    }

    return AuthValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate sign up data
  AuthValidationResult validateSignUpData({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    final errors = <String>[];

    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!email.contains('@')) {
      errors.add('Please enter a valid email address');
    }

    if (password.isEmpty) {
      errors.add('Password is required');
    } else if (password.length < 6) {
      errors.add('Password must be at least 6 characters');
    }

    if (firstName.trim().isEmpty) {
      errors.add('First name is required');
    }

    if (lastName.trim().isEmpty) {
      errors.add('Last name is required');
    }

    return AuthValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Get current authentication state
  AuthState get authState => _authProvider.state;

  /// Check if user is authenticated
  bool get isAuthenticated => _authProvider.isAuthenticated;

  /// Get current user
  UserModel? get currentUser => _authProvider.currentUser;

  /// Check if authentication is loading
  bool get isLoading => _authProvider.isLoading;

  /// Get authentication error message
  String? get errorMessage => _authProvider.errorMessage;

  /// Clear authentication errors
  void clearError() {
    _authProvider.clearError();
  }
}

/// Result of authentication operation
class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(UserModel user) {
    return AuthResult._(
      isSuccess: true,
      user: user,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of authentication validation
class AuthValidationResult {
  final bool isValid;
  final List<String> errors;

  AuthValidationResult({
    required this.isValid,
    required this.errors,
  });
}
