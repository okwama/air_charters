import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/theme/app_theme.dart';
import '../../core/services/aircraft_type_service.dart';
import '../../core/services/dynamic_pricing_service.dart';
import '../../shared/utils/currency_utils.dart';

class BookingSummaryCard extends StatelessWidget {
  final Aircraft aircraft;
  final String originText;
  final String destinationText;
  final List<String> stops;
  final int passengerCount;
  final bool isRoundTrip;
  final FlightPricingResult? pricingResult;
  final bool isCalculatingPrice;

  const BookingSummaryCard({
    super.key,
    required this.aircraft,
    required this.originText,
    required this.destinationText,
    required this.stops,
    required this.passengerCount,
    required this.isRoundTrip,
    this.pricingResult,
    this.isCalculatingPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aircraft header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.plane,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aircraft.name,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      '${aircraft.capacity} passengers • ${aircraft.formattedPricePerHour}',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flight details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.borderColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  LucideIcons.mapPin,
                  'Route',
                  stops.isEmpty 
                    ? '$originText → $destinationText'
                    : '$originText → ${stops.join(' → ')} → $destinationText',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        LucideIcons.users,
                        'Passengers',
                        '$passengerCount',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        LucideIcons.arrowLeftRight,
                        'Trip Type',
                        isRoundTrip ? 'Round Trip' : 'One Way',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Price section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Total',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    Text(
                      'Including all fees',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                _buildPriceDisplay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDisplay() {
    if (isCalculatingPrice) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Calculating...',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      );
    } else if (pricingResult != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FutureBuilder<Map<String, String>>(
            future: pricingResult!.dualCurrencyPricing,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final pricing = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      pricing['USD']!,
                      style: AppTheme.heading3.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pricing['KES']!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                );
              } else {
                return CurrencyText(
                  amount: pricingResult!.totalPrice,
                  currency: 'USD',
                  style: AppTheme.heading3.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Based on ${pricingResult!.formattedDistance} route',
            style: AppTheme.caption.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Custom Pricing',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Contact us for quote',
            style: AppTheme.caption.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              Text(
                value,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
