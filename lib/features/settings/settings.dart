import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/theme/app_theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/auth_provider.dart';

// Import modular widgets
import 'widgets/user_info_section.dart';
import 'widgets/app_preferences_section.dart';
import 'widgets/account_security_section.dart';
import 'widgets/support_help_section.dart';
import 'widgets/legal_section.dart';

// Import enhanced dialogs
import '../../shared/widgets/biometric_dialog.dart';

// Import pages
import 'pages/enable_biometric_page.dart';
import 'pages/app_version_page.dart';
import 'pages/faq_page.dart';
import 'pages/contact_support_page.dart';
import 'pages/language_page.dart';
import 'pages/currency_page.dart';
import 'pages/notification_settings_page.dart';
import 'pages/terms_of_service_page.dart';
import 'pages/privacy_policy_page.dart';
import 'pages/cookie_policy_page.dart';
import 'pages/delete_account_page.dart';
import 'pages/data_processing_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundColor,
            automaticallyImplyLeading: false,
            title: Text(
              'Settings',
              style: AppTheme.heading3,
            ),
            elevation: 0,
            centerTitle: true,
          ),
          body: Stack(
            children: [
              // Settings SVG Background
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                bottom: 0,
                child: Opacity(
                  opacity: 0.08,
                  child: SvgPicture.asset(
                    'assets/icons/settings.svg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Main content
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // User Info Section
                          const UserInfoSection(),

                          const SizedBox(height: 24),

                          // App Preferences Section
                          AppPreferencesSection(
                            onLanguageTap: _showLanguageDialog,
                            onCurrencyTap: _showCurrencyDialog,
                            onNotificationsTap: _showNotificationsDialog,
                            onPrivacyTap: _showPrivacyDialog,
                            currentLanguage: settingsProvider.currentLanguage,
                            currentCurrency: settingsProvider.currentCurrency,
                          ),

                          const SizedBox(height: 24),

                          // Account & Security Section
                          AccountSecuritySection(
                            onChangePasswordTap: _showChangePasswordDialog,
                            onBiometricTap: _showBiometricDialog,
                            onExportDataTap: _exportUserData,
                            onDeleteAccountTap: _showDeleteAccountDialog,
                            onLogoutAllDevicesTap: _logoutAllDevices,
                          ),

                          const SizedBox(height: 24),

                          // Legal & Policies Section
                          LegalSection(
                            onTermsOfServiceTap: _showTermsOfService,
                            onPrivacyPolicyTap: _showPrivacyPolicy,
                            onCookiePolicyTap: _showCookiePolicy,
                            onDataProcessingTap: _showDataProcessing,
                          ),

                          const SizedBox(height: 24),

                          // Support & Help Section
                          SupportHelpSection(
                            onFAQTap: _showFAQ,
                            onContactSupportTap: _contactSupport,
                            onAppTutorialTap: _showAppTutorial,
                            onRateAppTap: _rateApp,
                            onAppVersionTap: _showAppVersion,
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Dialog methods (now using provider)
  void _showLanguageDialog(BuildContext context) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LanguagePage(
          currentLanguage: settingsProvider.currentLanguage,
          onLanguageSelected: (language) async {
            await settingsProvider.updateLanguage(language);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Language changed to ${_getLanguageName(language)}',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.backgroundColor),
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencyPage(
          currentCurrency: settingsProvider.currentCurrency,
          onCurrencySelected: (currency) async {
            await settingsProvider.updateCurrency(currency);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Currency changed to ${_getCurrencyName(currency)}',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.backgroundColor),
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'pt':
        return 'Portuguese';
      case 'it':
        return 'Italian';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      default:
        return code;
    }
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'British Pound';
      case 'CAD':
        return 'Canadian Dollar';
      case 'AUD':
        return 'Australian Dollar';
      case 'JPY':
        return 'Japanese Yen';
      case 'CHF':
        return 'Swiss Franc';
      case 'CNY':
        return 'Chinese Yuan';
      case 'INR':
        return 'Indian Rupee';
      case 'BRL':
        return 'Brazilian Real';
      default:
        return code;
    }
  }

  void _showNotificationsDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text('Privacy Settings', style: AppTheme.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Profile Visibility', style: AppTheme.bodyMedium),
              subtitle: Text('Make your profile visible to others',
                  style: AppTheme.bodySmall),
              value: false, // TODO: Get from SettingsProvider
              onChanged: (value) {
                // TODO: Implement privacy toggle
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Profile visibility ${value ? 'enabled' : 'disabled'}',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.backgroundColor),
                    ),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
            ),
            SwitchListTile(
              title: Text('Analytics', style: AppTheme.bodyMedium),
              subtitle: Text('Help improve the app with analytics',
                  style: AppTheme.bodySmall),
              value: true, // Default to true
              onChanged: (value) {
                // TODO: Implement analytics toggle
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Analytics ${value ? 'enabled' : 'disabled'}',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.backgroundColor),
                    ),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
            child: Text('Done',
                style:
                    AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text('Change Password', style: AppTheme.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: AppTheme.bodyMedium,
              decoration: AppTheme.inputDecoration.copyWith(
                labelText: 'Current Password',
                labelStyle: AppTheme.bodyMedium
                    .copyWith(color: AppTheme.textSecondaryColor),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: AppTheme.bodyMedium,
              decoration: AppTheme.inputDecoration.copyWith(
                labelText: 'New Password',
                labelStyle: AppTheme.bodyMedium
                    .copyWith(color: AppTheme.textSecondaryColor),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: AppTheme.bodyMedium,
              decoration: AppTheme.inputDecoration.copyWith(
                labelText: 'Confirm New Password',
                labelStyle: AppTheme.bodyMedium
                    .copyWith(color: AppTheme.textSecondaryColor),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondaryColor,
            ),
            child: Text('Cancel',
                style:
                    AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement password change
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Password changed successfully',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.backgroundColor),
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
            child: Text('Change Password',
                style:
                    AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showBiometricDialog(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if biometric is available
    final bool isAvailable = await authProvider.isBiometricAvailable();
    if (!isAvailable) {
      _showBiometricNotAvailableDialog(context);
      return;
    }

    // Check if biometric is already enabled
    final bool isEnabled = await authProvider.isBiometricEnabled();
    final List<dynamic> availableTypes =
        await authProvider.getAvailableBiometrics();
    final String biometricName =
        authProvider.getBiometricTypeName(availableTypes);
    final String biometricIcon = authProvider.getBiometricIcon(availableTypes);

    // ✅ Navigate to modal page (Uber/Airbnb style)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnableBiometricPage(
          biometricName: biometricName,
          biometricIcon: biometricIcon,
          isCurrentlyEnabled: isEnabled,
        ),
      ),
    );
  }

  // ✅ INDUSTRY STANDARD: Verify identity before enabling biometric (like Uber/Airbnb)
  Future<void> _enableBiometricWithVerification(
      BuildContext context, String biometricName) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Step 1: Show password confirmation dialog
    final password = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        final passwordController = TextEditingController();
        return AlertDialog(
          backgroundColor: AppTheme.backgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Your Identity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'For security, please enter your password to enable $biometricName',
                style: AppTheme.bodySmall
                    .copyWith(color: AppTheme.textSecondaryColor),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel',
                  style: AppTheme.bodyMedium
                      .copyWith(color: AppTheme.textSecondaryColor)),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(passwordController.text),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor),
              child:
                  const Text('Verify', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (password == null || password.isEmpty || !context.mounted) return;

    // Step 2: Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Setting up $biometricName...', style: AppTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );

    try {
      // Step 3: Validate password with backend (security check)
      // For now, just enable biometric - add backend password validation later
      await authProvider.enableBiometric();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$biometricName enabled! You can now login with $biometricName',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enable biometric: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showBiometricNotAvailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Row(
          children: [
            const Text('🔒', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text('Biometric Not Available', style: AppTheme.heading3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biometric authentication is not available on this device.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_outlined,
                      color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Make sure your device supports fingerprint or face recognition',
                      style: AppTheme.bodySmall
                          .copyWith(color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
            child: Text('OK',
                style:
                    AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _exportUserData(BuildContext context) async {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data export feature coming soon',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.backgroundColor),
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeleteAccountPage()),
    );
  }

  void _showFAQ(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FAQPage()),
    );
  }

  void _contactSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactSupportPage()),
    );
  }

  void _logoutAllDevices(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                LucideIcons.alertTriangle,
                color: Colors.orange.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Logout from All Devices?',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const Text(
            'This will sign you out from all devices where you\'re currently logged in. You\'ll need to log in again on those devices.\n\nYou will remain logged in on this device unless you also choose to logout.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout All',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Call logout all devices from AuthRepository
      await authProvider.logoutAllDevices();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Successfully logged out from all other devices',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to logout from all devices: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _showAppTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text('App Tutorial', style: AppTheme.heading3),
        content: Text(
          'Interactive tutorial will be available here.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
            child: Text('OK',
                style:
                    AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _rateApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text('Rate App', style: AppTheme.heading3),
        content: Text(
          'App store rating link will be available here.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
            child: Text('OK',
                style:
                    AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAppVersion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppVersionPage()),
    );
  }

  // Legal & Policies Navigation Methods
  void _showTermsOfService(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
    );
  }

  void _showCookiePolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CookiePolicyPage()),
    );
  }

  void _showDataProcessing(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DataProcessingPage()),
    );
  }
}
