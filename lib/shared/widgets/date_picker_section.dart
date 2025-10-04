import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme/app_theme.dart';

class DatePickerSection extends StatelessWidget {
  final DateTime? departureDate;
  final DateTime? returnDate;
  final bool isRoundTrip;
  final VoidCallback onDepartureDateTap;
  final VoidCallback onReturnDateTap;

  const DatePickerSection({
    super.key,
    required this.departureDate,
    required this.returnDate,
    required this.isRoundTrip,
    required this.onDepartureDateTap,
    required this.onReturnDateTap,
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
          Text(
            'Travel Dates',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Departure Date',
                  hint: 'Select departure date',
                  value: departureDate,
                  onTap: onDepartureDateTap,
                ),
              ),
              if (isRoundTrip) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    label: 'Return Date',
                    hint: 'Select return date',
                    value: returnDate,
                    onTap: onReturnDateTap,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String hint,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      decoration: AppTheme.inputDecoration.copyWith(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.schedule, color: AppTheme.primaryColor),
      ),
      readOnly: true,
      onTap: onTap,
      controller: TextEditingController(
        text: value != null ? _formatDateTime(value) : '',
      ),
      style: AppTheme.bodyMedium.copyWith(
        color: AppTheme.textPrimaryColor,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final month = months[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$month $day, $year • $hour:$minute';
  }
}
