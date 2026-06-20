import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_theme.dart';

class AccountVerificationPage extends StatelessWidget {
  final Map<String, dynamic> profile;

  const AccountVerificationPage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account Verification',
          style: AppTheme.heading3,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              icon: LucideIcons.mail,
              title: 'Email Verification',
              value: profile['emailVerified'] == true
                  ? 'Verified'
                  : 'Not Verified',
              isVerified: profile['emailVerified'] == true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      profile['emailVerified'] == true
                          ? 'Your email is verified'
                          : 'Please verify your email address',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: profile['emailVerified'] == true
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                );
              },
            ),
            _buildInfoRow(
              context,
              icon: LucideIcons.phone,
              title: 'Phone Verification',
              value: profile['phoneVerified'] == true
                  ? 'Verified'
                  : 'Not Verified',
              isVerified: profile['phoneVerified'] == true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      profile['phoneVerified'] == true
                          ? 'Your phone is verified'
                          : 'Please verify your phone number',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: profile['phoneVerified'] == true
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required bool isVerified,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.textSecondaryColor),
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
                    Row(
                      children: [
                        Text(
                          value,
                          style: AppTheme.caption.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isVerified
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isVerified ? Icons.check_circle : Icons.info,
                          size: 16,
                          color: isVerified
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondaryColor.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
