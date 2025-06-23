import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/components/bottom_nav.dart';
import '../../shared/widgets/token_info_widget.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            Navigator.of(context).pop();
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
                  _buildUserInfoSection(context),

                  const SizedBox(height: 24),

                  // Token Info Section (for debugging and user awareness)
                  const TokenInfoWidget(),

                  const SizedBox(height: 24),

                  // Troubleshooting Section (for debugging)
                  _buildTroubleshootingSection(context),

                  const SizedBox(height: 24),

                  // Settings Menu Items
                  _buildSettingsMenuSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Sign Out Button at bottom
          _buildSignOutButton(context),

          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: const BottomNav(
        currentIndex: 3, // Settings tab is active
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/profile');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: Icon(
                LucideIcons.user,
                size: 30,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(width: 16),

            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Doe',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'john.doe@example.com',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+1 (555) 123-4567',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: LucideIcons.heart,
            title: 'Favorite Routes',
            onTap: () => print('Favorite Routes tapped'),
            showDivider: true,
          ),
          _buildSettingsItem(
            icon: LucideIcons.helpCircle,
            title: 'FAQ',
            onTap: () => print('FAQ tapped'),
            showDivider: true,
          ),
          _buildSettingsItem(
            icon: LucideIcons.scale,
            title: 'Legal',
            onTap: () => print('Legal tapped'),
            showDivider: true,
          ),
          _buildSettingsItem(
            icon: LucideIcons.shield,
            title: 'Privacy',
            onTap: () => print('Privacy tapped'),
            showDivider: true,
          ),
          _buildSettingsItem(
            icon: LucideIcons.messageCircle,
            title: 'Contact Us',
            onTap: () => print('Contact Us tapped'),
            showDivider: true,
          ),
          _buildSettingsItem(
            icon: LucideIcons.dollarSign,
            title: 'Currency',
            subtitle: 'Canadian Dollar (CAD)',
            onTap: () => print('Currency tapped'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/landing');
                }
              },
              icon: Icon(
                LucideIcons.logOut,
                size: 18,
                color: Colors.red.shade600,
              ),
              label: Text(
                'Sign Out',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                  fontSize: 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Colors.red.shade200,
                  width: 1,
                ),
                backgroundColor: Colors.red.shade50,
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

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.grey.shade100,
            indent: 56,
            endIndent: 20,
          ),
      ],
    );
  }

  Widget _buildTroubleshootingSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.wrench,
                      size: 24,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Troubleshooting',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'If you\'re experiencing issues, you can clear all stored data and restart fresh.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                // Show confirmation dialog
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Clear All Data?',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    content: Text(
                                      'This will clear all stored data and sign you out. You\'ll need to sign in again.',
                                      style: GoogleFonts.plusJakartaSans(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text(
                                          'Cancel',
                                          style: GoogleFonts.outfit(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text(
                                          'Clear Data',
                                          style: GoogleFonts.outfit(
                                            color: Colors.red.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true && context.mounted) {
                                  await authProvider.clearAllDataAndRestart();
                                  if (context.mounted) {
                                    Navigator.of(context)
                                        .pushReplacementNamed('/landing');
                                  }
                                }
                              },
                        icon: Icon(
                          LucideIcons.refreshCw,
                          size: 18,
                          color: Colors.orange.shade600,
                        ),
                        label: Text(
                          'Clear All Data & Restart',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                          backgroundColor: Colors.orange.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
