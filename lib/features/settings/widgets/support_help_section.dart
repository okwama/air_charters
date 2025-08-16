import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SupportHelpSection extends StatelessWidget {
  final Function(BuildContext) onFAQTap;
  final Function(BuildContext) onContactSupportTap;
  final Function(BuildContext) onAppTutorialTap;
  final Function(BuildContext) onRateAppTap;
  final Function(BuildContext) onAppVersionTap;

  const SupportHelpSection({
    super.key,
    required this.onFAQTap,
    required this.onContactSupportTap,
    required this.onAppTutorialTap,
    required this.onRateAppTap,
    required this.onAppVersionTap,
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
                      LucideIcons.helpCircle,
                      size: 24,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Support & Help',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // FAQ
                _buildPreferenceItem(
                  icon: LucideIcons.fileText,
                  title: 'FAQ',
                  subtitle: 'Frequently asked questions',
                  onTap: () => onFAQTap(context),
                ),

                // Contact Us
                _buildPreferenceItem(
                  icon: LucideIcons.messageCircle,
                  title: 'Contact Us',
                  subtitle: 'Get in touch with support',
                  onTap: () => onContactSupportTap(context),
                ),

                // App Tutorial
                _buildPreferenceItem(
                  icon: LucideIcons.play,
                  title: 'App Tutorial',
                  subtitle: 'Learn how to use the app',
                  onTap: () => onAppTutorialTap(context),
                ),

                // Rate App
                _buildPreferenceItem(
                  icon: LucideIcons.star,
                  title: 'Rate App',
                  subtitle: 'Rate us on the app store',
                  onTap: () => onRateAppTap(context),
                ),

                // App Version
                _buildPreferenceItem(
                  icon: LucideIcons.info,
                  title: 'App Version',
                  subtitle: 'Version 1.0.0 (Build 1)',
                  onTap: () => onAppVersionTap(context),
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
                color:
                    isDestructive ? Colors.red.shade600 : Colors.grey.shade700,
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
                        color:
                            isDestructive ? Colors.red.shade600 : Colors.black,
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
