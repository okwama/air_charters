import 'dart:convert';
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
        '/api/users/change-password',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return response['success'] == true;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to change password: ${e.toString()}');
    }
  }

  /// Delete user account
  Future<bool> deleteAccount({required String password}) async {
    try {
      final response = await _apiClient.post(
        '/api/users/account/delete',
        {
          'password': password,
        },
      );

      return response['success'] == true;
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
}
