import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme/app_theme.dart';
import '../../core/models/location_model.dart';
import '../../features/plan/stops_selection_screen.dart';

class StopsSection extends StatelessWidget {
  final List<LocationModel> stops;
  final VoidCallback onStopsSelection;

  const StopsSection({
    super.key,
    required this.stops,
    required this.onStopsSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.mapPin,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Flight Stops',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const Spacer(),
              Text(
                '${stops.length} stops',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (stops.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.borderColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.mapPin,
                    color: AppTheme.textSecondaryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No stops added',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add intermediate stops for a custom route',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: stops.asMap().entries.map((entry) {
                final index = entry.key;
                final stop = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: index < stops.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.borderColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.name,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textPrimaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (stop.code != null)
                              Text(
                                stop.code!,
                                style: AppTheme.caption.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // This would need to be handled by the parent widget
                          // For now, we'll just show the remove button
                        },
                        icon: Icon(
                          LucideIcons.x,
                          color: AppTheme.errorColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onStopsSelection,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryColor),
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(
                stops.isEmpty ? 'Add Stops' : 'Manage Stops',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
