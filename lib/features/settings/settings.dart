import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/theme_provider.dart';

// Import modular widgets
import 'widgets/user_info_section.dart';
import 'widgets/app_preferences_section.dart';
import 'widgets/account_security_section.dart';
import 'widgets/support_help_section.dart';
import 'widgets/sign_out_button.dart';

// Import pages
import 'pages/app_version_page.dart';
import 'pages/faq_page.dart';
import 'pages/contact_support_page.dart';
import 'pages/theme_page.dart';
import 'pages/language_page.dart';
import 'pages/currency_page.dart';
import 'pages/notification_settings_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            automaticallyImplyLeading: false,
            title: Text(
              'Settings',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontSize: 20,
              ),
            ),
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(
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
                        onThemeTap: _showThemeDialog,
                        onLanguageTap: _showLanguageDialog,
                        onCurrencyTap: _showCurrencyDialog,
                        onNotificationsTap: _showNotificationsDialog,
                        onPrivacyTap: _showPrivacyDialog,
                        currentTheme: settingsProvider.currentTheme,
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

              // Sign Out Button at bottom
              const SignOutButton(),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  // Dialog methods (now using provider)
  void _showThemeDialog(BuildContext context) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThemePage(
          currentTheme: settingsProvider.currentTheme,
          onThemeSelected: (theme) async {
            await settingsProvider.updateTheme(theme);
            await themeProvider.setThemeMode(theme);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Theme changed to ${theme == 'auto' ? 'Auto (System)' : theme == 'light' ? 'Light Mode' : 'Dark Mode'}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

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
                  content:
                      Text('Language changed to ${_getLanguageName(language)}'),
                  backgroundColor: Colors.green,
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
                  content:
                      Text('Currency changed to ${_getCurrencyName(currency)}'),
                  backgroundColor: Colors.green,
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
        title: const Text('Privacy Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Profile Visibility'),
              subtitle: const Text('Make your profile visible to others'),
              value: false, // TODO: Get from SettingsProvider
              onChanged: (value) {
                // TODO: Implement privacy toggle
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Profile visibility ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Analytics'),
              subtitle: const Text('Help improve the app with analytics'),
              value: true, // Default to true
              onChanged: (value) {
                // TODO: Implement analytics toggle
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Analytics ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
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
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement password change
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showBiometricDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Authentication'),
        content:
            const Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportUserData(BuildContext context) async {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export feature coming soon')),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter your password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmationController,
              decoration: const InputDecoration(
                labelText: 'Type "DELETE" to confirm',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement account deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Account deletion feature coming soon')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
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

  void _showAppTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Tutorial'),
        content: const Text('Interactive tutorial will be available here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _rateApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate App'),
        content: const Text('App store rating link will be available here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
}
