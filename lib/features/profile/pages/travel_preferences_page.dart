import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_theme.dart';
import '../../../core/providers/profile_provider.dart';

class TravelPreferencesPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  final ProfileProvider profileProvider;

  const TravelPreferencesPage({
    super.key,
    required this.profile,
    required this.profileProvider,
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
          'Travel Preferences',
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
              icon: LucideIcons.user,
              title: 'Seat Preference',
              value:
                  profile['seatPreference']?.toString().toUpperCase() ?? 'ANY',
              onTap: () => _showEditDialog(
                context,
                'Seat Preference',
                profile['seatPreference'] ?? 'any',
                profileProvider,
              ),
            ),
            _buildInfoRow(
              context,
              icon: LucideIcons.utensils,
              title: 'Meal Preference',
              value: profile['mealPreference']?.toString() ?? 'None set',
              onTap: () => _showEditDialog(
                context,
                'Meal Preference',
                profile['mealPreference'] ?? '',
                profileProvider,
              ),
            ),
            _buildInfoRow(
              context,
              icon: LucideIcons.heart,
              title: 'Special Assistance',
              value:
                  profile['specialAssistance']?.toString() ?? 'None required',
              onTap: () => _showEditDialog(
                context,
                'Special Assistance',
                profile['specialAssistance'] ?? '',
                profileProvider,
              ),
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
                    Text(
                      value,
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
                color: AppTheme.textSecondaryColor.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String field,
    String currentValue,
    ProfileProvider provider,
  ) {
    final controller = TextEditingController(text: currentValue);

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
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondaryColor),
            child: Text('Cancel',
                style:
                    AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () async {
              await provider.updateProfile(
                  {field.toLowerCase().replaceAll(' ', ''): controller.text});
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$field updated successfully',
                        style:
                            AppTheme.bodyMedium.copyWith(color: Colors.white)),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            child: Text('Save',
                style:
                    AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
