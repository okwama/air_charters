import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/components/bottom_nav.dart';
import '../../shared/widgets/token_info_widget.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/controllers/settings.controller/settings_controller.dart';
import '../../core/services/user_service.dart';

// Import modular widgets
import 'widgets/user_info_section.dart';
import 'widgets/app_preferences_section.dart';
import 'widgets/account_security_section.dart';
import 'widgets/support_help_section.dart';
import 'widgets/troubleshooting_section.dart';
import 'widgets/sign_out_button.dart';

// Import dialogs
import 'dialogs/theme_dialog.dart';
import 'dialogs/language_dialog.dart';
import 'dialogs/currency_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsController? _settingsController;

  @override
  void initState() {
    super.initState();
    _initializeSettingsController();
  }

  void _initializeSettingsController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        setState(() {
          _settingsController = SettingsController(
            authProvider: authProvider,
            userService: UserService(),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            size: 25,
          ),
          onPressed: () {
            // Navigate to home screen and clear the stack
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: Colors.black,
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
                  if (_settingsController != null)
                    AppPreferencesSection(
                      settingsController: _settingsController!,
                      onThemeTap: _showThemeDialog,
                      onLanguageTap: _showLanguageDialog,
                      onCurrencyTap: _showCurrencyDialog,
                      onNotificationsTap: _showNotificationsDialog,
                      onPrivacyTap: _showPrivacyDialog,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 16),
                          Text('Loading preferences...'),
                        ],
                      ),
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

                  const SizedBox(height: 24),

                  // Token Info Section (for debugging and user awareness)
                  const TokenInfoWidget(),

                  const SizedBox(height: 24),

                  // Troubleshooting Section (for debugging)
                  const TroubleshootingSection(),

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
      bottomNavigationBar: const BottomNav(
        currentIndex: 3, // Settings tab is active (fixed)
      ),
    );
  }

  // Dialog methods (placeholder implementations)
  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ThemeDialog(
        onThemeSelected: (theme) {
          // TODO: Implement theme change
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Theme changed to $theme')),
          );
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LanguageDialog(
        onLanguageSelected: (language) {
          // TODO: Implement language change
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Language changed to $language')),
          );
        },
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CurrencyDialog(
        onCurrencySelected: (currency) {
          // TODO: Implement currency change
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Currency changed to $currency')),
          );
        },
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive notifications via email'),
              value: _settingsController?.emailNotificationsEnabled ?? false,
              onChanged: (value) {
                // TODO: Implement notification toggle
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Email notifications ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: _settingsController?.pushNotificationsEnabled ?? false,
              onChanged: (value) {
                // TODO: Implement notification toggle
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Push notifications ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('SMS Notifications'),
              subtitle: const Text('Receive SMS notifications'),
              value: _settingsController?.smsNotificationsEnabled ?? false,
              onChanged: (value) {
                // TODO: Implement notification toggle
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'SMS notifications ${value ? 'enabled' : 'disabled'}')),
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
              value: _settingsController?.profileVisible ?? false,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FAQ'),
        content:
            const Text('Frequently asked questions will be available here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content:
            const Text('Support contact information will be available here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Version'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version: 1.0.0'),
            const Text('Build: 1'),
            const Text('Platform: Flutter'),
            Text('Last Updated: ${DateTime.now().toString().split(' ')[0]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
