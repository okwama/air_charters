import '../models/user_model.dart';
import '../error/app_exceptions.dart';
import '../network/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Sign in user with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/signin',
        {
          'email': email,
          'password': password,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromJson(response['data']['user']);
      }

      return null;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to sign in: ${e.toString()}');
    }
  }

  /// Sign up new user
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? country,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/signup',
        {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (country != null) 'country': country,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromJson(response['data']['user']);
      }

      return null;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to sign up: ${e.toString()}');
    }
  }

  /// Sign out current user
  Future<bool> signOut() async {
    try {
      final response = await _apiClient.post('/api/auth/signout', {});
      return response['success'] == true;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to sign out: ${e.toString()}');
    }
  }

  /// Refresh authentication token
  Future<UserModel?> refreshToken() async {
    try {
      final response = await _apiClient.post('/api/auth/refresh', {});

      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromJson(response['data']['user']);
      }

      return null;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to refresh token: ${e.toString()}');
    }
  }

  /// Request password reset code
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/forgot-password',
        {'email': email},
      );

      return {
        'success': true,
        'message': response['message'] ?? 'Reset code sent to your email',
      };
    } catch (e) {
      if (e is AppException) rethrow;
      return {
        'success': false,
        'message': 'Failed to send reset code: ${e.toString()}',
      };
    }
  }

  /// Verify reset code
  Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/verify-reset-code',
        {
          'email': email,
          'code': code,
        },
      );

      return {
        'valid': response['valid'] == true,
      };
    } catch (e) {
      if (e is AppException) rethrow;
      return {
        'valid': false,
      };
    }
  }

  /// Reset password with code
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/reset-password',
        {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
      );

      return {
        'success': true,
        'message': response['message'] ?? 'Password reset successfully',
      };
    } catch (e) {
      if (e is AppException) rethrow;
      return {
        'success': false,
        'message': 'Failed to reset password: ${e.toString()}',
      };
    }
  }
}
