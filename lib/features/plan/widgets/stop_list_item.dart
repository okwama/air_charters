import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/models/location_model.dart';
import '../../../core/services/route_calculator_service.dart';
import '../../../config/theme/app_theme.dart';

class StopListItem extends StatelessWidget {
  final LocationModel stop;
  final int index;
  final int totalStops;
  final double? distanceFromPrevious;
  final double? timeFromPrevious;
  final VoidCallback onRemove;
  final bool isCompact;
  final bool isLocked; // Can't be removed (origin/destination)
  final String? label; // "ORIGIN" or "DESTINATION"

  const StopListItem({
    super.key,
    required this.stop,
    required this.index,
    required this.totalStops,
    this.distanceFromPrevious,
    this.timeFromPrevious,
    required this.onRemove,
    this.isCompact = false,
    this.isLocked = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final stopColor = RouteCalculatorService.getStopColor(index, totalStops);
    final stopEmoji = RouteCalculatorService.getStopEmoji(index);

    if (isCompact) {
      return _buildCompactItem(stopColor, stopEmoji);
    }

    return _buildFullItem(stopColor, stopEmoji);
  }

  Widget _buildCompactItem(Color stopColor, String stopEmoji) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Stop indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: stopColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stopEmoji,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Stop name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (stop.country.isNotEmpty)
                  Text(
                    stop.country,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Remove button
          IconButton(
            icon: Icon(LucideIcons.x, size: 16, color: AppTheme.errorColor),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildFullItem(Color stopColor, String stopEmoji) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stop indicator with line
          Column(
            children: [
              // Number emoji + dot
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stopColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: stopColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    stopEmoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              // Connecting line (if not last stop)
              if (index < totalStops - 1)
                Container(
                  width: 2,
                  height: 24,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        stopColor,
                        RouteCalculatorService.getStopColor(
                            index + 1, totalStops),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Stop info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location name
                Text(
                  stop.name,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Subtitle (country/type)
                if (stop.country.isNotEmpty)
                  Text(
                    '${stop.type.name.toUpperCase()} • ${stop.country}',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),

                // Distance & time from previous stop
                if (distanceFromPrevious != null && distanceFromPrevious! > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(LucideIcons.moveRight,
                            size: 12, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          '+${RouteCalculatorService.formatDistance(distanceFromPrevious!)}',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (timeFromPrevious != null) ...[
                          const SizedBox(width: 8),
                          Icon(LucideIcons.clock,
                              size: 12, color: AppTheme.textSecondaryColor),
                          const SizedBox(width: 4),
                          Text(
                            '~${RouteCalculatorService.formatDuration(timeFromPrevious!)}',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Label (Origin/Destination)
                if (label != null)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: stopColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border:
                          Border.all(color: stopColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      label!,
                      style: AppTheme.caption.copyWith(
                        color: stopColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Remove button (only for non-locked stops)
          if (!isLocked)
            IconButton(
              icon: Icon(LucideIcons.trash2,
                  size: 18, color: AppTheme.errorColor),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              tooltip: 'Remove stop',
            )
          else
            // Lock icon for origin/destination
            Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(8),
              child: Icon(
                LucideIcons.lock,
                size: 16,
                color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }
}
