import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../shared/components/virtual_card.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../config/theme/app_theme.dart';

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

    // Redirect to login if not authenticated
    if (!isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Industry standard: Smart profile loading with caching
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!profileProvider.loading) {
        // Set the auth provider reference in ProfileProvider
        profileProvider.setAuthProvider(authProvider);

        // Only fetch if we don't have cached data or if data is stale
        if (profileProvider.canFetchProfile) {
          try {
            await profileProvider.fetchProfileIfNeeded();
          } catch (e) {
            // Handle auth errors gracefully
            if (e.toString().contains('Authentication failed') ||
                e.toString().contains('Invalid or expired token') ||
                e.toString().contains('401')) {
              if (!_hasShownAuthError) {
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
            }
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
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(LucideIcons.arrowLeft, color: AppTheme.primaryColor),
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
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load profile',
                style: AppTheme.heading3,
              ),
              const SizedBox(height: 8),
              Text(
                'Please try again later',
                style: AppTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  profileProvider.fetchProfile();
                },
                style: AppTheme.primaryButtonStyle,
                child: Text('Retry',
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primaryColor),
          onPressed: () {
            // Simply go back to the previous screen (settings)
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Profile',
          style: AppTheme.heading3,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Virtual Card
            VirtualCard(
              points: profile['loyaltyPoints']?.toString() ?? '0',
              walletBalance: '\$${profile['walletBalance'] ?? '0.00'}',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Card details coming soon!',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Profile Information
            Text(
              'Personal Information',
              style: AppTheme.heading3,
            ),
            const SizedBox(height: 16),

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
              value: preferences?['dateOfBirth']?.toString().split(' ').first ??
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

            const SizedBox(height: 32),

            // Account Settings Section
            Text(
              'Account Settings',
              style: AppTheme.heading3,
            ),
            const SizedBox(height: 16),

            // Account Status
            _buildInfoRow(
              icon: LucideIcons.shield,
              title: 'Account Status',
              value: 'Verified',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Account verification details',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
            ),

            // Member Since
            _buildInfoRow(
              icon: LucideIcons.calendar,
              title: 'Member Since',
              value: profile['createdAt'] != null
                  ? DateTime.parse(profile['createdAt']).year.toString()
                  : '2024',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Account creation details',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Sign Out Button
            _buildSignOutButton(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, color: AppTheme.primaryColor, size: 20),
        title: Text(
          title,
          style: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        subtitle: Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          color: AppTheme.textSecondaryColor,
          size: 16,
        ),
        onTap: onTap,
        dense: false,
        minVerticalPadding: 4,
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
        backgroundColor: AppTheme.backgroundColor,
        title: Text('Edit $field', style: AppTheme.heading3),
        content: TextField(
          controller: controller,
          style: AppTheme.bodyMedium,
          decoration: AppTheme.inputDecoration.copyWith(
            labelText: field,
            labelStyle: AppTheme.bodyMedium
                .copyWith(color: AppTheme.textSecondaryColor),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: AppTheme.primaryButtonStyle,
            child: Text(
              'Save',
              style: AppTheme.bodyMedium
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: AppTheme.secondaryButtonStyle,
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
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
              'Date of birth updated to ${date.toString().split(' ')[0]}',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    });
  }

  Widget _buildSignOutButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.errorColor.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.errorColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppTheme.backgroundColor,
                    title: Text(
                      'Sign Out?',
                      style: AppTheme.heading3,
                    ),
                    content: Text(
                      'Are you sure you want to sign out?',
                      style: AppTheme.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondaryColor,
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTheme.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                        ),
                        child: Text(
                          'Sign Out',
                          style: AppTheme.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  // Use the comprehensive logout method
                  await authProvider.logout(context);
                }
              },
              icon: Icon(
                LucideIcons.logOut,
                size: 18,
                color: AppTheme.errorColor,
              ),
              label: Text(
                'Sign Out',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
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
