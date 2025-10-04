import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme/app_theme.dart';
import '../widgets/passenger_form.dart';
import '../../core/models/passenger_model.dart';

class PassengerSelector extends StatefulWidget {
  final int maxPassengers;
  final int initialCount;
  final Function(int) onCountChanged;
  final Function(List<PassengerModel>)? onPassengersChanged;
  final List<PassengerModel>? existingPassengers;

  const PassengerSelector({
    super.key,
    required this.maxPassengers,
    this.initialCount = 1,
    required this.onCountChanged,
    this.onPassengersChanged,
    this.existingPassengers,
  });

  @override
  State<PassengerSelector> createState() => _PassengerSelectorState();
}

class _PassengerSelectorState extends State<PassengerSelector> {
  late int _passengerCount;
  List<PassengerModel> _passengers = [];

  @override
  void initState() {
    super.initState();
    _passengerCount = widget.initialCount;
    _passengers = widget.existingPassengers ?? [];

    // Ensure we have the right number of passengers for the count
    _syncPassengerCount();
  }

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
            'Passenger Information',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),

          // Passenger count selector
          _buildPassengerCountSelector(),
          const SizedBox(height: 16),

          // Passenger list
          if (_passengers.isNotEmpty) ...[
            _buildPassengerList(),
            const SizedBox(height: 12),
          ],

          // Add passenger button - only show if we need more passengers
          if (_passengers.length < _passengerCount) _buildAddPassengerButton(),

          // Show completion status
          if (_passengers.length == _passengerCount && _passengerCount > 0)
            _buildCompletionStatus(),
        ],
      ),
    );
  }

  Widget _buildPassengerCountSelector() {
    return Row(
      children: [
        Icon(
          LucideIcons.users,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Number of Passengers',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildCountButton(
                    icon: LucideIcons.minus,
                    onPressed: _passengerCount > 1 ? _decreaseCount : null,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppTheme.borderColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '$_passengerCount',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildCountButton(
                    icon: LucideIcons.plus,
                    onPressed: _passengerCount < widget.maxPassengers
                        ? _increaseCount
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Maximum ${widget.maxPassengers} passengers',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onPressed != null
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.borderColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onPressed != null
                ? AppTheme.primaryColor
                : AppTheme.borderColor.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onPressed != null
              ? AppTheme.primaryColor
              : AppTheme.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildPassengerList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passenger Details',
          style: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(_passengers.length, (index) {
          final passenger = _passengers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppTheme.borderColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    LucideIcons.user,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${passenger.firstName} ${passenger.lastName}',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      if (passenger.age != null)
                        Text(
                          'Age: ${passenger.age}',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _editPassenger(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      LucideIcons.edit,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAddPassengerButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addPassenger,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.primaryColor),
          foregroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: const Icon(LucideIcons.userPlus, size: 16),
        label: Text(
          'Add Passenger ${_passengers.length + 1} of $_passengerCount',
          style: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _increaseCount() {
    if (_passengerCount < widget.maxPassengers) {
      setState(() {
        _passengerCount++;
      });
      widget.onCountChanged(_passengerCount);
    }
  }

  void _decreaseCount() {
    if (_passengerCount > 1) {
      setState(() {
        _passengerCount--;
        // Remove excess passengers if count is reduced
        if (_passengers.length > _passengerCount) {
          _passengers = _passengers.take(_passengerCount).toList();
          widget.onPassengersChanged?.call(_passengers);
        }
      });
      widget.onCountChanged(_passengerCount);
    }
  }

  void _syncPassengerCount() {
    // If we have more passengers than the count, remove excess
    if (_passengers.length > _passengerCount) {
      _passengers = _passengers.take(_passengerCount).toList();
    }
  }

  void _addPassenger() async {
    // Don't allow adding more passengers than the count
    if (_passengers.length >= _passengerCount) {
      return;
    }

    final result = await Navigator.push<PassengerModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const PassengerForm(
          mode: PassengerFormMode.single,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _passengers.add(result);
      });
      widget.onPassengersChanged?.call(_passengers);
    }
  }

  void _editPassenger(int index) async {
    final result = await Navigator.push<PassengerModel>(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerForm(
          mode: PassengerFormMode.single,
          passenger: _passengers[index],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _passengers[index] = result;
      });
      widget.onPassengersChanged?.call(_passengers);
    }
  }

  Widget _buildCompletionStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.checkCircle,
            color: AppTheme.successColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'All $_passengerCount passenger${_passengerCount > 1 ? 's' : ''} added successfully',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.successColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
