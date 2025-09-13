import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';

/// Provider to handle app settings and preferences state management
class SettingsProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final UserService _userService;

  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;

  // Local app preferences
  String _currentTheme = 'auto';
  String _currentLanguage = 'en';
  String _currentCurrency = 'USD';
  bool _isDarkMode = false;

  SettingsProvider({
    required AuthProvider authProvider,
    required UserService userService,
  })  : _authProvider = authProvider,
        _userService = userService {
    _loadLocalPreferences();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;

  // Local preferences getters
  String get currentTheme => _currentTheme;
  String get currentLanguage => _currentLanguage;
  String get currentCurrency => _currentCurrency;
  bool get isDarkMode => _isDarkMode;

  /// Load local preferences from SharedPreferences
  Future<void> _loadLocalPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentTheme = prefs.getString('app_theme') ?? 'auto';
      _currentLanguage = prefs.getString('app_language') ?? 'en';
      _currentCurrency = prefs.getString('app_currency') ?? 'USD';
      _isDarkMode = prefs.getBool('app_dark_mode') ?? false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('SettingsProvider._loadLocalPreferences error: $e');
      }
    }
  }

  /// Save local preferences to SharedPreferences
  Future<void> _saveLocalPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_theme', _currentTheme);
      await prefs.setString('app_language', _currentLanguage);
      await prefs.setString('app_currency', _currentCurrency);
      await prefs.setBool('app_dark_mode', _isDarkMode);
    } catch (e) {
      if (kDebugMode) {
        print('SettingsProvider._saveLocalPreferences error: $e');
      }
    }
  }

  /// Update theme preference
  Future<void> updateTheme(String theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      _isDarkMode = theme == 'dark';
      await _saveLocalPreferences();

      // Update ThemeProvider if available
      try {
        // This will be called from the settings screen where ThemeProvider is available
        // The actual theme switching is handled by ThemeProvider
      } catch (e) {
        if (kDebugMode) {
          print('SettingsProvider.updateTheme error: $e');
        }
      }

      notifyListeners();
    }
  }

  /// Update language preference
  Future<void> updateLanguage(String language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      await _saveLocalPreferences();
      notifyListeners();
    }
  }

  /// Update currency preference
  Future<void> updateCurrency(String currency) async {
    if (_currentCurrency != currency) {
      _currentCurrency = currency;
      await _saveLocalPreferences();
      notifyListeners();
    }
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    _currentTheme = _isDarkMode ? 'dark' : 'light';
    await _saveLocalPreferences();
    notifyListeners();
  }

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
      _setLoading(true);
      _clearError();

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
        _currentUser = updatedUser;
        notifyListeners();
        return SettingsUpdateResult.success(updatedUser);
      } else {
        return SettingsUpdateResult.failure('Failed to update settings');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SettingsProvider.updateAppPreferences error: $e');
      }
      _setError(e.toString());
      return SettingsUpdateResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Change user password
  Future<SettingsUpdateResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _setLoading(true);
      _clearError();

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
        return SettingsUpdateResult.success(null);
      } else {
        return SettingsUpdateResult.failure('Failed to change password');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SettingsProvider.changePassword error: $e');
      }
      _setError(e.toString());
      return SettingsUpdateResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<SettingsUpdateResult> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? countryCode,
    String? dateOfBirth,
    String? gender,
    String? nationality,
    String? passportNumber,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return SettingsUpdateResult.failure(
            'User must be authenticated to update profile');
      }

      // Validate input
      final validation = validateProfileUpdate(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );
      if (!validation.isValid) {
        return SettingsUpdateResult.failure(validation.errors.first);
      }

      // Update profile
      final updatedUser = await _userService.updateProfile({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'countryCode': countryCode,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'nationality': nationality,
        'passportNumber': passportNumber,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
      });

      if (updatedUser != null) {
        // Update local user data
        _authProvider.updateUser(updatedUser);
        _currentUser = updatedUser;
        notifyListeners();
        return SettingsUpdateResult.success(updatedUser);
      } else {
        return SettingsUpdateResult.failure('Failed to update profile');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SettingsProvider.updateProfile error: $e');
      }
      _setError(e.toString());
      return SettingsUpdateResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Delete user account
  Future<SettingsUpdateResult> deleteAccount({
    required String password,
    required String reason,
    required BuildContext context,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return SettingsUpdateResult.failure(
            'User must be authenticated to delete account');
      }

      // Validate input
      if (password.isEmpty) {
        return SettingsUpdateResult.failure('Password is required');
      }

      // Delete account
      final success = await _userService.deleteAccount(
        password: password,
      );

      if (success) {
        // Logout user after account deletion
        await _authProvider.logout(context);
        return SettingsUpdateResult.success(null);
      } else {
        return SettingsUpdateResult.failure('Failed to delete account');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SettingsProvider.deleteAccount error: $e');
      }
      _setError(e.toString());
      return SettingsUpdateResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Validation methods
  SettingsValidationResult validateAppPreferences({
    String? language,
    String? currency,
    String? timezone,
  }) {
    final errors = <String>[];

    if (language != null && language.isEmpty) {
      errors.add('Language cannot be empty');
    }

    if (currency != null && currency.isEmpty) {
      errors.add('Currency cannot be empty');
    }

    if (timezone != null && timezone.isEmpty) {
      errors.add('Timezone cannot be empty');
    }

    return SettingsValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

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
      errors.add('Confirm password is required');
    } else if (newPassword != confirmPassword) {
      errors.add('Passwords do not match');
    }

    return SettingsValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  SettingsValidationResult validateProfileUpdate({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) {
    final errors = <String>[];

    if (firstName != null && firstName.isEmpty) {
      errors.add('First name cannot be empty');
    }

    if (lastName != null && lastName.isEmpty) {
      errors.add('Last name cannot be empty');
    }

    if (email != null && email.isNotEmpty) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        errors.add('Invalid email format');
      }
    }

    if (phone != null && phone.isNotEmpty) {
      if (!RegExp(r'^\+?[\d\s-]+$').hasMatch(phone)) {
        errors.add('Invalid phone number format');
      }
    }

    return SettingsValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// Result class for settings operations
class SettingsUpdateResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;

  SettingsUpdateResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory SettingsUpdateResult.success(UserModel? user) {
    return SettingsUpdateResult._(
      isSuccess: true,
      user: user,
    );
  }

  factory SettingsUpdateResult.failure(String errorMessage) {
    return SettingsUpdateResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result class for settings validation
class SettingsValidationResult {
  final bool isValid;
  final List<String> errors;

  SettingsValidationResult({
    required this.isValid,
    required this.errors,
  });
}
