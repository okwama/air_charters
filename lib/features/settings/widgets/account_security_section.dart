import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AccountSecuritySection extends StatelessWidget {
  final Function(BuildContext) onChangePasswordTap;
  final Function(BuildContext) onBiometricTap;
  final Function(BuildContext) onExportDataTap;
  final Function(BuildContext) onDeleteAccountTap;

  const AccountSecuritySection({
    super.key,
    required this.onChangePasswordTap,
    required this.onBiometricTap,
    required this.onExportDataTap,
    required this.onDeleteAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                      LucideIcons.lock,
                      size: 24,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Account & Security',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Change Password
                _buildPreferenceItem(
                  icon: LucideIcons.key,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () => onChangePasswordTap(context),
                ),

                // Biometric Authentication
                _buildPreferenceItem(
                  icon: LucideIcons.fingerprint,
                  title: 'Biometric Login',
                  subtitle: 'Use fingerprint or face ID',
                  onTap: () => onBiometricTap(context),
                ),

                // Data Export
                _buildPreferenceItem(
                  icon: LucideIcons.download,
                  title: 'Export Data',
                  subtitle: 'Download your personal data',
                  onTap: () => onExportDataTap(context),
                ),

                // Delete Account
                _buildPreferenceItem(
                  icon: LucideIcons.trash2,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  onTap: () => onDeleteAccountTap(context),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDestructive ? Colors.red.shade600 : Colors.grey.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? Colors.red.shade600 : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
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
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 