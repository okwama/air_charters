import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_theme.dart';

class AccountSecuritySection extends StatelessWidget {
  final Function(BuildContext) onChangePasswordTap;
  final Function(BuildContext) onBiometricTap;
  final Function(BuildContext) onExportDataTap;
  final Function(BuildContext) onDeleteAccountTap;
  final Function(BuildContext)? onLogoutAllDevicesTap;

  const AccountSecuritySection({
    super.key,
    required this.onChangePasswordTap,
    required this.onBiometricTap,
    required this.onExportDataTap,
    required this.onDeleteAccountTap,
    this.onLogoutAllDevicesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.borderColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                      style: AppTheme.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
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

                // Logout from All Devices
                if (onLogoutAllDevicesTap != null)
                  _buildPreferenceItem(
                    icon: LucideIcons.logOut,
                    title: 'Logout from All Devices',
                    subtitle: 'Sign out from all active sessions',
                    onTap: () => onLogoutAllDevicesTap!(context),
                    isWarning: true,
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
    bool isWarning = false,
  }) {
    Color iconColor = Colors.grey.shade700;
    Color textColor = AppTheme.textPrimaryColor;

    if (isDestructive) {
      iconColor = Colors.red.shade600;
      textColor = AppTheme.errorColor;
    } else if (isWarning) {
      iconColor = Colors.orange.shade600;
      textColor = Colors.orange.shade700;
    }

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
                color: iconColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondaryColor,
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
