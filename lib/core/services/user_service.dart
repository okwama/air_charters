import '../models/user_model.dart';
import '../error/app_exceptions.dart';
import '../network/api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  /// Update user profile
  Future<UserModel?> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiClient.put(
        '/api/users/profile',
        profileData,
      );

      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromJson(response['data']);
      }

      throw ServerException('Failed to update profile');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to update profile: ${e.toString()}');
    }
  }

  /// Update user preferences
  Future<UserModel?> updatePreferences(
      Map<String, dynamic> preferencesData) async {
    try {
      final response = await _apiClient.put(
        '/api/users/preferences',
        preferencesData,
      );

      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromJson(response['data']);
      }

      throw ServerException('Failed to update preferences');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to update preferences: ${e.toString()}');
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.put(
        '/api/users/password',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return response['message'] == 'Password changed successfully';
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to change password: ${e.toString()}');
    }
  }

  /// Delete user account
  Future<bool> deleteAccount({required String password}) async {
    try {
      final response = await _apiClient.deleteWithBody(
        '/api/users/account',
        {
          'password': password,
        },
      );

      return response['message'] == 'Account deleted successfully';
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to delete account: ${e.toString()}');
    }
  }

  /// Get user profile
  Future<UserModel?> getUserProfile() async {
    try {
      final response = await _apiClient.get('/api/users/profile');

      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to get user profile: ${e.toString()}');
    }
  }

  /// Update privacy settings
  Future<bool> updatePrivacySettings(Map<String, dynamic> privacyData) async {
    try {
      final response = await _apiClient.put(
        '/api/users/privacy',
        privacyData,
      );

      return response['success'] == true;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
          'Failed to update privacy settings: ${e.toString()}');
    }
  }

  /// Get privacy settings
  Future<Map<String, dynamic>?> getPrivacySettings() async {
    try {
      final response = await _apiClient.get('/api/users/privacy');

      if (response['success'] == true && response['privacySettings'] != null) {
        return response['privacySettings'];
      }

      return null;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to get privacy settings: ${e.toString()}');
    }
  }

  /// Export user data
  Future<Map<String, dynamic>?> exportUserData() async {
    try {
      final response = await _apiClient.get('/api/users/export');

      if (response['success'] == true && response['userData'] != null) {
        return response['userData'];
      }

      return null;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to export user data: ${e.toString()}');
    }
  }
}
