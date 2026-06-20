import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/theme/app_theme.dart';

class TripTypeSelector extends StatelessWidget {
  final bool isRoundTrip;
  final ValueChanged<bool> onChanged;

  const TripTypeSelector({
    super.key,
    required this.isRoundTrip,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Trip Type',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTripTypeOption(
                  'One Way',
                  'Single journey',
                  false,
                  LucideIcons.arrowRight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTripTypeOption(
                  'Round Trip',
                  'Return journey',
                  true,
                  LucideIcons.arrowLeftRight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeOption(
      String title, String subtitle, bool value, IconData icon) {
    final isSelected = isRoundTrip == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.borderColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryColor,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondaryColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
