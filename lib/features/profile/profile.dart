import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../config/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import 'pages/personal_info_page.dart';
import 'pages/travel_preferences_page.dart';
import 'pages/account_verification_page.dart';
import 'pages/account_info_page.dart';
import 'pages/wallet_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.profile ?? {};
        final preferences = profileProvider.preferences;

        if (profileProvider.loading && profile.isEmpty) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.only(
                      top: 60, left: 24, right: 24, bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top bar with close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.x,
                                color: AppTheme.textSecondaryColor),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Profile info row
                      Row(
                        children: [
                          // Name and Email on the left
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${profile['firstName']?.toString() ?? ''} ${profile['lastName']?.toString() ?? ''}'
                                      .trim(),
                                  style: AppTheme.heading2,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile['email']?.toString() ?? '',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Profile Avatar on the right
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.primaryColor.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                profile['firstName']?.toString().isNotEmpty ==
                                        true
                                    ? profile['firstName']
                                        .toString()[0]
                                        .toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Wallet Section
                _buildSectionCard(
                  icon: LucideIcons.wallet,
                  title: 'My Wallet',
                  subtitle: 'Manage your wallet & loyalty points',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WalletPage(
                          profile: profile,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Personal Information Section
                _buildSectionCard(
                  icon: LucideIcons.user,
                  title: 'Personal Information',
                  subtitle: 'Manage your personal details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalInfoPage(
                          profile: profile,
                          preferences: preferences,
                          profileProvider: profileProvider,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Travel Preferences Section
                _buildSectionCard(
                  icon: LucideIcons.planeTakeoff,
                  title: 'Travel Preferences',
                  subtitle: 'Set your flight preferences',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelPreferencesPage(
                          profile: profile,
                          profileProvider: profileProvider,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Account Verification Section
                _buildSectionCard(
                  icon: LucideIcons.shieldCheck,
                  title: 'Account Verification',
                  subtitle: 'Verify your account details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountVerificationPage(
                          profile: profile,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Account Information Section
                _buildSectionCard(
                  icon: LucideIcons.info,
                  title: 'Account Information',
                  subtitle: 'View your account details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountInfoPage(
                          profile: profile,
                        ),
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
      },
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.borderColor.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondaryColor.withOpacity(0.5),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.errorColor),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: const Icon(LucideIcons.logOut,
                color: AppTheme.errorColor, size: 20),
            title: Text(
              'Sign Out',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.errorColor,
              ),
            ),
            trailing: const Icon(
              LucideIcons.chevronRight,
              color: AppTheme.errorColor,
              size: 16,
            ),
            onTap: () async {
              await authProvider.logout(context);
              if (mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
            dense: false,
            minVerticalPadding: 4,
          ),
        );
      },
    );
  }
}
