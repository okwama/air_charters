import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';


/// Controller to handle user profile and preferences business logic
class UserController {
  final AuthProvider _authProvider;
  final UserService _userService;

  UserController({
    required AuthProvider authProvider,
    required UserService userService,
  })  : _authProvider = authProvider,
        _userService = userService;

  /// Update user profile
  Future<UserUpdateResult> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? country,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? zipCode,
  }) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return UserUpdateResult.failure(
            'User must be authenticated to update profile');
      }

      // Validate input
      final validation = validateProfileData(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      if (!validation.isValid) {
        return UserUpdateResult.failure(validation.errors.first);
      }

      // Update profile
      final updatedUser = await _userService.updateProfile({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'country': country,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'address': address,
        'city': city,
        'state': state,
        'zipCode': zipCode,
      });

      if (updatedUser != null) {
        // Update local user data
        _authProvider.updateUser(updatedUser);
        return UserUpdateResult.success(updatedUser);
      } else {
        return UserUpdateResult.failure('Failed to update profile');
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserController.updateProfile error: $e');
      }
      return UserUpdateResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Update user preferences
  Future<UserUpdateResult> updatePreferences({
    String? language,
    String? currency,
    String? timezone,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    List<String>? preferredAirlines,
    List<String>? preferredSeatTypes,
    Map<String, dynamic>? dietaryRestrictions,
  }) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return UserUpdateResult.failure(
            'User must be authenticated to update preferences');
      }

      // Update preferences
      final updatedUser = await _userService.updatePreferences({
        'language': language,
        'currency': currency,
        'timezone': timezone,
        'emailNotifications': emailNotifications,
        'pushNotifications': pushNotifications,
        'smsNotifications': smsNotifications,
        'preferredAirlines': preferredAirlines,
        'preferredSeatTypes': preferredSeatTypes,
        'dietaryRestrictions': dietaryRestrictions,
      });

      if (updatedUser != null) {
        // Update local user data
        _authProvider.updateUser(updatedUser);
        return UserUpdateResult.success(updatedUser);
      } else {
        return UserUpdateResult.failure('Failed to update preferences');
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserController.updatePreferences error: $e');
      }
      return UserUpdateResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return false;
      }

      // Validate input
      final validation = validatePasswordChange(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (!validation.isValid) {
        return false;
      }

      // Change password
      final success = await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('UserController.changePassword error: $e');
      }
      return false;
    }
  }

  /// Delete user account
  Future<bool> deleteAccount({
    required String password,
  }) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return false;
      }

      // Validate password
      if (password.isEmpty) {
        return false;
      }

      // Delete account
      final success = await _userService.deleteAccount(password: password);

      if (success) {
        // Clear local user data
        _authProvider.clearUser();
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('UserController.deleteAccount error: $e');
      }
      return false;
    }
  }

  /// Get user profile
  Future<UserModel?> getUserProfile() async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return null;
      }

      final user = await _userService.getUserProfile();

      if (user != null) {
        // Update local user data
        _authProvider.updateUser(user);
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('UserController.getUserProfile error: $e');
      }
      return null;
    }
  }

  /// Validate profile data
  UserValidationResult validateProfileData({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) {
    final errors = <String>[];

    if (firstName != null && firstName.trim().isEmpty) {
      errors.add('First name cannot be empty');
    }

    if (lastName != null && lastName.trim().isEmpty) {
      errors.add('Last name cannot be empty');
    }

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Basic phone number validation
      final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
      if (!phoneRegex.hasMatch(phoneNumber)) {
        errors.add('Please enter a valid phone number');
      }
    }

    return UserValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate password change
  UserValidationResult validatePasswordChange({
    required String currentPassword,
    required String newPassword,
  }) {
    final errors = <String>[];

    if (currentPassword.isEmpty) {
      errors.add('Current password is required');
    }

    if (newPassword.isEmpty) {
      errors.add('New password is required');
    } else if (newPassword.length < 6) {
      errors.add('New password must be at least 6 characters');
    }

    if (currentPassword == newPassword) {
      errors.add('New password must be different from current password');
    }

    return UserValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Get current user
  UserModel? get currentUser => _authProvider.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _authProvider.isAuthenticated;

  /// Check if update is in progress
  bool get isUpdating => _authProvider.isLoading;

  /// Get update error message
  String? get errorMessage => _authProvider.errorMessage;

  /// Clear update errors
  void clearError() {
    _authProvider.clearError();
  }
}

/// Result of user update operation
class UserUpdateResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;

  UserUpdateResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory UserUpdateResult.success(UserModel user) {
    return UserUpdateResult._(
      isSuccess: true,
      user: user,
    );
  }

  factory UserUpdateResult.failure(String errorMessage) {
    return UserUpdateResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of user validation
class UserValidationResult {
  final bool isValid;
  final List<String> errors;

  UserValidationResult({
    required this.isValid,
    required this.errors,
  });
}
