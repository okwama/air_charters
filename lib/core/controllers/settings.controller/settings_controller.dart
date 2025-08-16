import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';

/// Controller to handle app settings and preferences business logic
class SettingsController {
  final AuthProvider _authProvider;
  final UserService _userService;

  SettingsController({
    required AuthProvider authProvider,
    required UserService userService,
  })  : _authProvider = authProvider,
        _userService = userService;

  /// Update app preferences
  Future<SettingsUpdateResult> updateAppPreferences({
    String? language,
    String? currency,
    String? timezone,
    bool? darkMode,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? locationServices,
    bool? analyticsEnabled,
    String? appVersion,
  }) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return SettingsUpdateResult.failure(
            'User must be authenticated to update settings');
      }

      // Validate input
      final validation = validateAppPreferences(
        language: language,
        currency: currency,
        timezone: timezone,
      );
      if (!validation.isValid) {
        return SettingsUpdateResult.failure(validation.errors.first);
      }

      // Update preferences
      final updatedUser = await _userService.updatePreferences({
        'language': language,
        'currency': currency,
        'timezone': timezone,
        'darkMode': darkMode,
        'emailNotifications': emailNotifications,
        'pushNotifications': pushNotifications,
        'smsNotifications': smsNotifications,
        'locationServices': locationServices,
        'analyticsEnabled': analyticsEnabled,
        'appVersion': appVersion,
      });

      if (updatedUser != null) {
        // Update local user data
        _authProvider.updateUser(updatedUser);
        return SettingsUpdateResult.success(updatedUser);
      } else {
        return SettingsUpdateResult.failure('Failed to update settings');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SettingsController.updateAppPreferences error: $e');
      }
      return SettingsUpdateResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Change user password
  Future<SettingsUpdateResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return SettingsUpdateResult.failure(
            'User must be authenticated to change password');
      }

      // Validate input
      final validation = validatePasswordChange(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      if (!validation.isValid) {
        return SettingsUpdateResult.failure(validation.errors.first);
      }

      // Change password
      final success = await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (success) {
        return SettingsUpdateResult.success(_authProvider.currentUser!);
      } else {
        return SettingsUpdateResult.failure('Failed to change password');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SettingsController.changePassword error: $e');
      }
      return SettingsUpdateResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Delete user account
  Future<SettingsUpdateResult> deleteAccount({
    required String password,
    required String confirmation,
  }) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return SettingsUpdateResult.failure(
            'User must be authenticated to delete account');
      }

      // Validate input
      final validation = validateAccountDeletion(
        password: password,
        confirmation: confirmation,
      );
      if (!validation.isValid) {
        return SettingsUpdateResult.failure(validation.errors.first);
      }

      // Delete account
      final success = await _userService.deleteAccount(password: password);

      if (success) {
        // Clear local user data
        _authProvider.clearUser();
        return SettingsUpdateResult.success(null, accountDeleted: true);
      } else {
        return SettingsUpdateResult.failure('Failed to delete account');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SettingsController.deleteAccount error: $e');
      }
      return SettingsUpdateResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Clear all app data and restart
  Future<SettingsUpdateResult> clearAllDataAndRestart() async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return SettingsUpdateResult.failure(
            'User must be authenticated to clear data');
      }

      // Clear local user data (this will clear all stored data)
      _authProvider.clearUser();
      return SettingsUpdateResult.success(null, dataCleared: true);
    } catch (e) {
      if (kDebugMode) {
        print('SettingsController.clearAllDataAndRestart error: $e');
      }
      return SettingsUpdateResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Export user data (placeholder for future implementation)
  Future<DataExportResult> exportUserData() async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return DataExportResult.failure(
            'User must be authenticated to export data');
      }

      // Placeholder implementation - return basic user data
      final user = _authProvider.currentUser;
      if (user != null) {
        final exportData = {
          'user': user.toJson(),
          'exportedAt': DateTime.now().toIso8601String(),
        };
        return DataExportResult.success(exportData);
      } else {
        return DataExportResult.failure('No user data available');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SettingsController.exportUserData error: $e');
      }
      return DataExportResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get app version information (placeholder for future implementation)
  Future<AppVersionResult> getAppVersion() async {
    try {
      // Placeholder implementation - return basic version info
      final versionInfo = {
        'version': '1.0.0',
        'buildNumber': '1',
        'platform': 'Flutter',
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      return AppVersionResult.success(versionInfo);
    } catch (e) {
      if (kDebugMode) {
        print('SettingsController.getAppVersion error: $e');
      }
      return AppVersionResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Validate app preferences
  SettingsValidationResult validateAppPreferences({
    String? language,
    String? currency,
    String? timezone,
  }) {
    final errors = <String>[];

    if (language != null) {
      final validLanguages = ['en', 'es', 'fr', 'de', 'pt', 'ar'];
      if (!validLanguages.contains(language.toLowerCase())) {
        errors.add('Invalid language selection');
      }
    }

    if (currency != null) {
      final validCurrencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY'];
      if (!validCurrencies.contains(currency.toUpperCase())) {
        errors.add('Invalid currency selection');
      }
    }

    if (timezone != null && timezone.trim().isEmpty) {
      errors.add('Timezone cannot be empty');
    }

    return SettingsValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate password change
  SettingsValidationResult validatePasswordChange({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    final errors = <String>[];

    if (currentPassword.isEmpty) {
      errors.add('Current password is required');
    }

    if (newPassword.isEmpty) {
      errors.add('New password is required');
    } else if (newPassword.length < 8) {
      errors.add('New password must be at least 8 characters');
    }

    if (confirmPassword.isEmpty) {
      errors.add('Password confirmation is required');
    }

    if (newPassword != confirmPassword) {
      errors.add('Passwords do not match');
    }

    if (currentPassword == newPassword) {
      errors.add('New password must be different from current password');
    }

    return SettingsValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate account deletion
  SettingsValidationResult validateAccountDeletion({
    required String password,
    required String confirmation,
  }) {
    final errors = <String>[];

    if (password.isEmpty) {
      errors.add('Password is required');
    }

    if (confirmation.isEmpty) {
      errors.add('Confirmation is required');
    }

    if (confirmation.toLowerCase() != 'delete') {
      errors.add('Please type "DELETE" to confirm account deletion');
    }

    return SettingsValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Get current user
  UserModel? get currentUser => _authProvider.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _authProvider.isAuthenticated;

  /// Check if settings update is in progress
  bool get isUpdating => _authProvider.isLoading;

  /// Get settings error message
  String? get errorMessage => _authProvider.errorMessage;

  /// Clear settings errors
  void clearError() {
    _authProvider.clearError();
  }

  /// Get current app preferences from user profile
  Map<String, dynamic> get currentPreferences {
    // These would come from the user_profile table in the database
    // For now, return default values
    return {
      'seatPreference': 'any',
      'mealPreference': null,
      'specialAssistance': null,
      'emailNotifications': true,
      'smsNotifications': true,
      'pushNotifications': true,
      'marketingEmails': true,
      'profileVisible': false,
    };
  }

  /// Get current language from user table
  String get currentLanguage => _authProvider.currentUser?.language ?? 'en';

  /// Get current currency from user table
  String get currentCurrency => _authProvider.currentUser?.currency ?? 'USD';

  /// Get current theme mode from user table
  String get currentTheme => _authProvider.currentUser?.theme ?? 'auto';

  /// Get notification settings from user profile
  bool get emailNotificationsEnabled =>
      currentPreferences['emailNotifications'] ?? true;

  bool get pushNotificationsEnabled =>
      currentPreferences['pushNotifications'] ?? true;

  bool get smsNotificationsEnabled =>
      currentPreferences['smsNotifications'] ?? true;

  bool get marketingEmailsEnabled =>
      currentPreferences['marketingEmails'] ?? true;

  /// Get travel preferences from user profile
  String get seatPreference => currentPreferences['seatPreference'] ?? 'any';

  String? get mealPreference => currentPreferences['mealPreference'];

  String? get specialAssistance => currentPreferences['specialAssistance'];

  /// Get privacy settings
  bool get profileVisible => currentPreferences['profileVisible'] ?? false;

  /// Update privacy settings
  Future<SettingsUpdateResult> updatePrivacySettings({
    bool? dataSharing,
    bool? marketingEmails,
    bool? smsNotifications,
    bool? pushNotifications,
    bool? profileVisible,
    bool? locationTracking,
  }) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return SettingsUpdateResult.failure(
            'User must be authenticated to update privacy settings');
      }

      // Update privacy settings
      final success = await _userService.updatePrivacySettings({
        'dataSharing': dataSharing,
        'marketingEmails': marketingEmails,
        'smsNotifications': smsNotifications,
        'pushNotifications': pushNotifications,
        'profileVisible': profileVisible,
        'locationTracking': locationTracking,
      });

      if (success) {
        return SettingsUpdateResult.success(_authProvider.currentUser!);
      } else {
        return SettingsUpdateResult.failure(
            'Failed to update privacy settings');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SettingsController.updatePrivacySettings error: $e');
      }
      return SettingsUpdateResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get privacy settings from API
  Future<PrivacySettingsResult> getPrivacySettings() async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return PrivacySettingsResult.failure(
            'User must be authenticated to get privacy settings');
      }

      // Get privacy settings
      final privacySettings = await _userService.getPrivacySettings();

      if (privacySettings != null) {
        return PrivacySettingsResult.success(privacySettings);
      } else {
        return PrivacySettingsResult.failure('Failed to get privacy settings');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SettingsController.getPrivacySettings error: $e');
      }
      return PrivacySettingsResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Export user data from API
  Future<DataExportResult> exportUserDataFromAPI() async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return DataExportResult.failure(
            'User must be authenticated to export data');
      }

      // Export user data from API
      final exportData = await _userService.exportUserData();

      if (exportData != null) {
        return DataExportResult.success(exportData);
      } else {
        return DataExportResult.failure('Failed to export user data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SettingsController.exportUserDataFromAPI error: $e');
      }
      return DataExportResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}

/// Result of settings update operation
class SettingsUpdateResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;
  final bool accountDeleted;
  final bool dataCleared;

  SettingsUpdateResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
    this.accountDeleted = false,
    this.dataCleared = false,
  });

  factory SettingsUpdateResult.success(
    UserModel? user, {
    bool accountDeleted = false,
    bool dataCleared = false,
  }) {
    return SettingsUpdateResult._(
      isSuccess: true,
      user: user,
      accountDeleted: accountDeleted,
      dataCleared: dataCleared,
    );
  }

  factory SettingsUpdateResult.failure(String errorMessage) {
    return SettingsUpdateResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of data export operation
class DataExportResult {
  final bool isSuccess;
  final Map<String, dynamic>? exportData;
  final String? errorMessage;

  DataExportResult._({
    required this.isSuccess,
    this.exportData,
    this.errorMessage,
  });

  factory DataExportResult.success(Map<String, dynamic> exportData) {
    return DataExportResult._(
      isSuccess: true,
      exportData: exportData,
    );
  }

  factory DataExportResult.failure(String errorMessage) {
    return DataExportResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of app version operation
class AppVersionResult {
  final bool isSuccess;
  final Map<String, dynamic>? versionInfo;
  final String? errorMessage;

  AppVersionResult._({
    required this.isSuccess,
    this.versionInfo,
    this.errorMessage,
  });

  factory AppVersionResult.success(Map<String, dynamic> versionInfo) {
    return AppVersionResult._(
      isSuccess: true,
      versionInfo: versionInfo,
    );
  }

  factory AppVersionResult.failure(String errorMessage) {
    return AppVersionResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of settings validation
class SettingsValidationResult {
  final bool isValid;
  final List<String> errors;

  SettingsValidationResult({
    required this.isValid,
    required this.errors,
  });
}

/// Result of privacy settings operation
class PrivacySettingsResult {
  final bool isSuccess;
  final Map<String, dynamic>? privacySettings;
  final String? errorMessage;

  PrivacySettingsResult._({
    required this.isSuccess,
    this.privacySettings,
    this.errorMessage,
  });

  factory PrivacySettingsResult.success(Map<String, dynamic> privacySettings) {
    return PrivacySettingsResult._(
      isSuccess: true,
      privacySettings: privacySettings,
    );
  }

  factory PrivacySettingsResult.failure(String errorMessage) {
    return PrivacySettingsResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
