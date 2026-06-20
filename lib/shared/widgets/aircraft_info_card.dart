import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/theme/app_theme.dart';
import '../../core/services/aircraft_type_service.dart';
import './image_carousel.dart';

class AircraftInfoCard extends StatelessWidget {
  final Aircraft aircraft;

  const AircraftInfoCard({
    super.key,
    required this.aircraft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aircraft Image Carousel
          if (aircraft.images.isNotEmpty)
            ImageCarousel(
              images: aircraft.images,
              height: 200,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              placeholderIcon: Icon(
                Icons.airplanemode_active,
                size: 48,
                color: AppTheme.textSecondaryColor,
              ),
              showIndicators: true,
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  Icons.airplanemode_active,
                  size: 48,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),

          // Aircraft Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.plane,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        aircraft.name,
                        style: AppTheme.heading3.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  aircraft.model,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                // All info in one row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      icon: LucideIcons.users,
                      text: '${aircraft.capacity} seats',
                    ),
                    _buildInfoChip(
                      icon: LucideIcons.clock,
                      text: aircraft.formattedFlightDuration,
                    ),
                    _buildInfoChip(
                      icon: LucideIcons.dollarSign,
                      text: aircraft.formattedPricePerHour,
                      isPrice: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    bool isPrice = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPrice
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.borderColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color:
                isPrice ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTheme.caption.copyWith(
              color:
                  isPrice ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
              fontWeight: isPrice ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
