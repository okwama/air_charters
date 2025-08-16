import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../shared/components/virtual_card.dart';
import '../../shared/components/bottom_nav.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../shared/utils/session_manager.dart';
import '../../config/theme/app_theme.dart';
import 'dart:developer' as dev;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasShownAuthError = false;

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Use standardized authentication check from AuthProvider
    final isAuthenticated =
        authProvider.isAuthenticated && authProvider.hasValidToken;

    if (kDebugMode) {
      dev.log(
          'ProfileScreen: AuthProvider.isAuthenticated: ${authProvider.isAuthenticated}',
          name: 'profile_screen');
      dev.log(
          'ProfileScreen: AuthProvider.hasValidToken: ${authProvider.hasValidToken}',
          name: 'profile_screen');
      dev.log('ProfileScreen: Final isAuthenticated: $isAuthenticated',
          name: 'profile_screen');
    }

    // Redirect to login if not authenticated
    if (!isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Fetch profile on first build, but check authentication first
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (profileProvider.profile == null && !profileProvider.loading) {
        // Set the auth provider reference in ProfileProvider
        profileProvider.setAuthProvider(authProvider);

        if (profileProvider.canFetchProfile) {
          if (kDebugMode) {
            dev.log('ProfileScreen: Fetching profile...',
                name: 'profile_screen');
          }
          await profileProvider.fetchProfile();

          // Check if profile fetch failed due to auth issues
          if (profileProvider.profile == null && !_hasShownAuthError) {
            _hasShownAuthError = true;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session expired. Please login again.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
              // Redirect to login after showing the message
              Navigator.of(context).pushReplacementNamed('/login');
            }
          }
        } else {
          if (kDebugMode) {
            dev.log('ProfileScreen: Cannot fetch profile - auth issues',
                name: 'profile_screen');
          }
        }
      }
    });

    final profile = profileProvider.profile;
    final preferences = profileProvider.preferences;

    if (profileProvider.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state if profile is null (should not happen for authenticated users)
    if (profile == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/settings');
            },
          ),
          title: Text(
            'Profile',
            style: AppTheme.heading3,
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.alertCircle,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please try again later',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  profileProvider.fetchProfile();
                },
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNav(
            currentIndex: 3), // Settings tab (profile is part of settings)
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () {
            // Navigate to home screen and clear the stack
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
        ),
        title: Text(
          'Profile',
          style: AppTheme.heading3,
        ),
        centerTitle: true,
        actions: [
          // Add a refresh button for debugging
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () async {
                // Refresh profile
                await profileProvider.fetchProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile refreshed'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Force refresh profile
                await profileProvider.fetchProfile();
              },
              tooltip: 'Refresh Session Status',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Status Indicator (for debugging)
            if (kDebugMode) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isAuthenticated // Changed from sessionStatus['hasValidToken']
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isAuthenticated // Changed from sessionStatus['hasValidToken']
                            ? Colors.green.shade200
                            : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAuthenticated ? Icons.security : Icons.warning,
                      color: isAuthenticated ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAuthenticated ? 'Session Active' : 'Session Issues',
                        style: GoogleFonts.interTight(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isAuthenticated
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Virtual Card
            VirtualCard(
              points: profile['loyaltyPoints']?.toString() ?? '0',
              walletBalance: '\$${profile['walletBalance'] ?? '0.00'}',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card details coming soon!')),
                );
              },
            ),
            const SizedBox(height: 24),

            // Profile Information
            Text(
              'Personal Information',
              style: GoogleFonts.interTight(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            // Name
            _buildInfoRow(
              icon: LucideIcons.user,
              title: 'Full Name',
              value:
                  '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}',
              onTap: () => _showEditDialog(
                  context,
                  'Full Name',
                  '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}',
                  profileProvider),
            ),

            // Email
            _buildInfoRow(
              icon: LucideIcons.mail,
              title: 'Email',
              value: profile['email'] ?? '',
              onTap: () => _showEditDialog(
                  context, 'Email', profile['email'] ?? '', profileProvider),
            ),

            // Phone
            _buildInfoRow(
              icon: LucideIcons.phone,
              title: 'Phone Number',
              value: profile['phoneNumber'] ?? '',
              onTap: () => _showEditDialog(context, 'Phone Number',
                  profile['phoneNumber'] ?? '', profileProvider),
            ),

            // Date of Birth
            _buildInfoRow(
              icon: LucideIcons.calendar,
              title: 'Date of Birth',
              value:
                  preferences?['dateOfBirth']?.toString().split(' ').first ??
                      '',
              onTap: () => _showDatePicker(context, profileProvider),
            ),

            // Nationality
            _buildInfoRow(
              icon: LucideIcons.mapPin,
              title: 'Nationality',
              value: preferences?['nationality'] ?? '',
              onTap: () => _showEditDialog(context, 'Nationality',
                  preferences?['nationality'] ?? '', profileProvider,
                  isPreference: true),
            ),

            const SizedBox(height: 24),

            // Preferences Section
            Text(
              'Preferences',
              style: GoogleFonts.interTight(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            // Language
            _buildInfoRow(
              icon: LucideIcons.languages,
              title: 'Language',
              value: preferences?['language'] ?? 'English',
              onTap: () => _showPreferenceDialog(
                  context,
                  'Language',
                  ['English', 'Spanish', 'French', 'German'],
                  preferences?['language'] ?? 'English',
                  profileProvider),
            ),

            // Currency
            _buildInfoRow(
              icon: LucideIcons.dollarSign,
              title: 'Currency',
              value: preferences?['currency'] ?? 'USD (\$)',
              onTap: () => _showPreferenceDialog(
                  context,
                  'Currency',
                  ['USD (\$)', 'EUR (€)', 'GBP (£)', 'JPY (¥)'],
                  preferences?['currency'] ?? 'USD (\$)',
                  profileProvider),
            ),

            // Notifications
            _buildInfoRow(
              icon: LucideIcons.bell,
              title: 'Notifications',
              value: (preferences?['notifications'] ?? true)
                  ? 'Enabled'
                  : 'Disabled',
              onTap: () => _showPreferenceDialog(
                  context,
                  'Notifications',
                  ['Enabled', 'Disabled'],
                  (preferences?['notifications'] ?? true)
                      ? 'Enabled'
                      : 'Disabled',
                  profileProvider),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(
          currentIndex: 3), // Settings tab (profile is part of settings)
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(icon, color: Colors.black, size: 16),
        title: Text(
          title,
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          color: Colors.grey,
          size: 12,
        ),
        onTap: onTap,
        dense: true,
        minVerticalPadding: 0,
      ),
    );
  }

  void _showEditDialog(BuildContext context, String field, String currentValue,
      ProfileProvider provider,
      {bool isPreference = false}) {
    final controller = TextEditingController(text: currentValue);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context, ProfileProvider provider) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((date) async {
      if (date != null) {
        await provider.updatePreferences(
            {'dateOfBirth': date.toIso8601String().split('T').first});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Date of birth updated to  {date.toString().split(' ')[0]}')),
        );
      }
    });
  }

  void _showPreferenceDialog(BuildContext context, String field,
      List<String> options, String currentValue, ProfileProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select $field'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((option) => ListTile(
                    title: Text(option),
                    selected: option == currentValue,
                    onTap: () async {
                      if (field == 'Notifications') {
                        await provider.updatePreferences(
                            {'notifications': option == 'Enabled'});
                      } else {
                        await provider
                            .updatePreferences({field.toLowerCase(): option});
                      }
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper extension for camelCase conversion
extension StringCasingExtension on String {
  String camelCase() {
    if (isEmpty) return this;
    return this[0].toLowerCase() + substring(1);
  }
}
