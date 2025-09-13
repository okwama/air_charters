import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppPreferencesSection extends StatelessWidget {
  final Function(BuildContext) onThemeTap;
  final Function(BuildContext) onLanguageTap;
  final Function(BuildContext) onCurrencyTap;
  final Function(BuildContext) onNotificationsTap;
  final Function(BuildContext) onPrivacyTap;

  // Add current values as parameters
  final String currentTheme;
  final String currentLanguage;
  final String currentCurrency;

  const AppPreferencesSection({
    super.key,
    required this.onThemeTap,
    required this.onLanguageTap,
    required this.onCurrencyTap,
    required this.onNotificationsTap,
    required this.onPrivacyTap,
    required this.currentTheme,
    required this.currentLanguage,
    required this.currentCurrency,
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
                      LucideIcons.settings,
                      size: 24,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'App Preferences',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Theme Setting
                _buildPreferenceItem(
                  icon: LucideIcons.palette,
                  title: 'Theme',
                  subtitle: _getThemeDisplayName(),
                  onTap: () => onThemeTap(context),
                ),

                // Language Setting
                _buildPreferenceItem(
                  icon: LucideIcons.languages,
                  title: 'Language',
                  subtitle: _getLanguageDisplayName(),
                  onTap: () => onLanguageTap(context),
                ),

                // Currency Setting
                _buildPreferenceItem(
                  icon: LucideIcons.dollarSign,
                  title: 'Currency',
                  subtitle: _getCurrencyDisplayName(),
                  onTap: () => onCurrencyTap(context),
                ),

                // Notifications Breakdown
                _buildPreferenceItem(
                  icon: LucideIcons.bell,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () => onNotificationsTap(context),
                ),

                // Privacy Settings
                _buildPreferenceItem(
                  icon: LucideIcons.shield,
                  title: 'Privacy',
                  subtitle: 'Manage privacy settings',
                  onTap: () => onPrivacyTap(context),
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

  // Helper methods for getting display names - now using actual values
  String _getThemeDisplayName() {
    switch (currentTheme) {
      case 'light':
        return 'Light Mode';
      case 'dark':
        return 'Dark Mode';
      case 'auto':
        return 'Auto (System)';
      default:
        return 'Auto (System)';
    }
  }

  String _getLanguageDisplayName() {
    switch (currentLanguage) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'pt':
        return 'Portuguese';
      case 'it':
        return 'Italian';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      case 'zh':
        return 'Chinese (Simplified)';
      case 'ar':
        return 'Arabic';
      case 'ru':
        return 'Russian';
      case 'hi':
        return 'Hindi';
      default:
        return 'English';
    }
  }

  String _getCurrencyDisplayName() {
    switch (currentCurrency) {
      case 'USD':
        return 'US Dollar (\$)';
      case 'EUR':
        return 'Euro (€)';
      case 'GBP':
        return 'British Pound (£)';
      case 'CAD':
        return 'Canadian Dollar (C\$)';
      case 'AUD':
        return 'Australian Dollar (A\$)';
      case 'JPY':
        return 'Japanese Yen (¥)';
      case 'CHF':
        return 'Swiss Franc (CHF)';
      case 'CNY':
        return 'Chinese Yuan (¥)';
      case 'INR':
        return 'Indian Rupee (₹)';
      case 'BRL':
        return 'Brazilian Real (R\$)';
      case 'MXN':
        return 'Mexican Peso (MX\$)';
      case 'SGD':
        return 'Singapore Dollar (S\$)';
      case 'HKD':
        return 'Hong Kong Dollar (HK\$)';
      case 'KRW':
        return 'South Korean Won (₩)';
      case 'THB':
        return 'Thai Baht (฿)';
      default:
        return 'US Dollar (\$)';
    }
  }
}
