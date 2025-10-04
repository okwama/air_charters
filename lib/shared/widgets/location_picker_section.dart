import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme/app_theme.dart';
import '../../core/models/location_model.dart';
import 'enhanced_location_picker.dart';

class LocationPickerSection extends StatelessWidget {
  final LocationModel? originLocation;
  final LocationModel? destinationLocation;
  final String originText;
  final String destinationText;
  final Function(LocationModel, String) onLocationSelected;

  const LocationPickerSection({
    super.key,
    required this.originLocation,
    required this.destinationLocation,
    required this.originText,
    required this.destinationText,
    required this.onLocationSelected,
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
            'Flight Route',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLocationField(
                  controller: TextEditingController(text: originText),
                  label: 'Origin',
                  hint: 'Select departure airport',
                  onTap: () => _showLocationPicker(context, 'origin'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLocationField(
                  controller: TextEditingController(text: destinationText),
                  label: 'Destination',
                  hint: 'Select arrival airport',
                  onTap: () => _showLocationPicker(context, 'destination'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context, String field) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedLocationPicker(
          title: field == 'origin' ? 'Select Origin' : 'Select Destination',
          selectedLocation:
              field == 'origin' ? originLocation : destinationLocation,
          placeholder: field == 'origin'
              ? 'Where are you departing from?'
              : 'Where are you flying to?',
          onLocationSelected: (location) {
            onLocationSelected(location, field);
          },
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTheme.bodyMedium.copyWith(
        color: AppTheme.textPrimaryColor,
      ),
      decoration: AppTheme.inputDecoration.copyWith(
        labelText: label,
        hintText: hint,
        prefixIcon:
            const Icon(LucideIcons.mapPin, color: AppTheme.primaryColor),
        suffixIcon: const Icon(LucideIcons.chevronDown,
            color: AppTheme.textSecondaryColor),
      ),
      readOnly: true,
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }
}
