import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme/app_theme.dart';

class LegalSection extends StatelessWidget {
  final Function(BuildContext) onTermsOfServiceTap;
  final Function(BuildContext) onPrivacyPolicyTap;
  final Function(BuildContext) onCookiePolicyTap;
  final Function(BuildContext) onDataProcessingTap;
  final Function(BuildContext) onLicensesTap;

  const LegalSection({
    super.key,
    required this.onTermsOfServiceTap,
    required this.onPrivacyPolicyTap,
    required this.onCookiePolicyTap,
    required this.onDataProcessingTap,
    required this.onLicensesTap,
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
                      LucideIcons.fileText,
                      size: 24,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Legal & Policies',
                      style: AppTheme.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Terms of Service
                _buildPreferenceItem(
                  icon: LucideIcons.fileText,
                  title: 'Terms of Service',
                  subtitle: 'User agreement and terms',
                  onTap: () => onTermsOfServiceTap(context),
                ),

                // Privacy Policy
                _buildPreferenceItem(
                  icon: LucideIcons.shield,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  onTap: () => onPrivacyPolicyTap(context),
                ),

                // Cookie Policy
                _buildPreferenceItem(
                  icon: LucideIcons.cookie,
                  title: 'Cookie Policy',
                  subtitle: 'Cookie usage and preferences',
                  onTap: () => onCookiePolicyTap(context),
                ),

                // Data Processing
                _buildPreferenceItem(
                  icon: LucideIcons.database,
                  title: 'Data Processing',
                  subtitle: 'GDPR and data processing info',
                  onTap: () => onDataProcessingTap(context),
                ),

                // Open Source Licenses
                _buildPreferenceItem(
                  icon: LucideIcons.code,
                  title: 'Open Source Licenses',
                  subtitle: 'Third-party library licenses',
                  onTap: () => onLicensesTap(context),
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
                color: Colors.grey.shade700,
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
                        color: AppTheme.textPrimaryColor,
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
