import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:air_charters/core/models/experience_booking_model.dart';
import 'package:air_charters/core/services/experience_booking_service.dart';
import 'package:air_charters/core/network/api_client.dart';
import 'package:air_charters/config/theme/app_theme.dart';
import 'experience_booking_confirmation_page.dart';

class ExperiencePassengerForm extends StatefulWidget {
  final ExperienceBookingModel booking;

  const ExperiencePassengerForm({
    super.key,
    required this.booking,
  });

  @override
  State<ExperiencePassengerForm> createState() =>
      _ExperiencePassengerFormState();
}

class _ExperiencePassengerFormState extends State<ExperiencePassengerForm> {
  late ExperienceBookingService _bookingService;
  final List<ExperiencePassenger> _passengers = [];
  final TextEditingController _specialRequestsController =
      TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bookingService = ExperienceBookingService(ApiClient());
    _initializePassengers();
  }

  void _initializePassengers() {
    _passengers.clear();
    for (int i = 0; i < widget.booking.passengersCount; i++) {
      _passengers.add(ExperiencePassenger(
        firstName: '',
        lastName: '',
      ));
    }
  }

  void _addPassenger() {
    setState(() {
      _passengers.add(ExperiencePassenger(
        firstName: '',
        lastName: '',
      ));
    });
  }

  void _removePassenger(int index) {
    if (_passengers.length > 1) {
      setState(() {
        _passengers.removeAt(index);
      });
    }
  }

  Future<void> _showPassengerFormModal(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerFormPage(
          passengerIndex: index,
          passenger: _passengers[index],
          onSave: (updatedPassenger) {
            setState(() {
              _passengers[index] = updatedPassenger;
            });
          },
        ),
      ),
    );
  }

  bool get _canProceed {
    return _passengers.isNotEmpty &&
        _passengers.every((passenger) =>
            passenger.firstName.isNotEmpty && passenger.lastName.isNotEmpty);
  }

  String? _getPassengerValidationError(int index) {
    final passenger = _passengers[index];

    if (passenger.firstName.isEmpty) {
      return 'First name is required';
    }
    if (passenger.lastName.isEmpty) {
      return 'Last name is required';
    }

    return null;
  }

  void _proceedToPayment() async {
    if (!_canProceed) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Create the final booking with passenger details
      final finalBooking = widget.booking.copyWith(
        passengers: _passengers,
        specialRequests: _specialRequestsController.text.isNotEmpty
            ? _specialRequestsController.text
            : null,
      );

      // Navigate to experience booking confirmation
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExperienceBookingConfirmationPage(
              bookingData: {
                // Experience details
                'experienceTitle': widget.booking.experienceTitle,
                'location': widget.booking.location,
                'imageUrl': widget.booking.imageUrl,
                'experienceId': widget.booking.experienceId,

                // Booking type
                'bookingType': 'experience',

                // Pricing
                'totalAmount': widget.booking.totalPrice,
                'totalPrice': widget.booking.totalPrice,
                'pricePerPerson': widget.booking.price,

                // Date/Time
                'selectedDate': widget.booking.selectedDate.toIso8601String(),
                'selectedTime': widget.booking.selectedTime,

                // Passenger information
                'passengerCount': widget.booking.passengers.length,
                'totalAdults':
                    widget.booking.passengers.where((p) => p.isAdult).length,
                'totalChildren':
                    widget.booking.passengers.where((p) => p.isChild).length,
                'passengers':
                    widget.booking.passengers.map((p) => p.toJson()).toList(),

                // Company details
                'companyId': widget.booking.companyId,

                // Additional info
                'specialRequests': widget.booking.specialRequests,
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking Summary',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Summary
                  _buildBookingSummary(),
                  const SizedBox(height: 24),

                  // Passenger Forms
                  _buildPassengerForms(),
                  const SizedBox(height: 24),

                  // Special Requests
                  _buildSpecialRequests(),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.booking.experienceTitle,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.booking.location,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.booking.formattedDate,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.booking.selectedTime,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.booking.formattedTotalPrice,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerForms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Passenger Details',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_passengers.length} Passenger${_passengers.length > 1 ? 's' : ''}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Passenger list cards
        ...List.generate(_passengers.length, (index) {
          final passenger = _passengers[index];
          final hasData =
              passenger.firstName.isNotEmpty && passenger.lastName.isNotEmpty;
          final isComplete = _getPassengerValidationError(index) == null;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isComplete ? AppTheme.successColor : AppTheme.borderColor,
                width: 1.5,
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isComplete
                      ? AppTheme.successColor.withValues(alpha: 0.1)
                      : AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isComplete ? Icons.check_circle : Icons.person_outline,
                  color: isComplete
                      ? AppTheme.successColor
                      : AppTheme.textSecondaryColor,
                  size: 24,
                ),
              ),
              title: Text(
                hasData
                    ? '${passenger.firstName} ${passenger.lastName}'
                    : 'Passenger ${index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: hasData
                      ? AppTheme.textPrimaryColor
                      : AppTheme.textSecondaryColor,
                ),
              ),
              subtitle: hasData
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              passenger.passengerType == PassengerType.adult
                                  ? Icons.person
                                  : Icons.child_care,
                              size: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              passenger.passengerType == PassengerType.adult
                                  ? 'Adult'
                                  : 'Child',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              passenger.residencyStatus ==
                                      ResidencyStatus.resident
                                  ? Icons.home
                                  : Icons.flight,
                              size: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              passenger.residencyStatus ==
                                      ResidencyStatus.resident
                                  ? 'Resident'
                                  : 'Foreigner',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Text(
                      'Tap to add details',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.primaryColor,
                      ),
                    ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_passengers.length > 1)
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: AppTheme.errorColor),
                      onPressed: () => _removePassenger(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              onTap: () => _showPassengerFormModal(index),
            ),
          );
        }),

        // Add More Passengers Button
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addPassenger,
          icon: const Icon(Icons.person_add_outlined),
          label: Text(
            'Add Another Passenger',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textPrimaryColor,
            side: BorderSide(color: AppTheme.borderColor, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Requests',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _specialRequestsController,
          decoration: InputDecoration(
            labelText: 'Any special requests or notes',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'e.g., dietary requirements, accessibility needs...',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _canProceed && !_isLoading ? _proceedToPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textPrimaryColor,
                  foregroundColor: AppTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.backgroundColor),
                        ),
                      )
                    : Text(
                        'Continue to Payment',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }
}

// Separate full-page form for individual passenger
class PassengerFormPage extends StatefulWidget {
  final int passengerIndex;
  final ExperiencePassenger passenger;
  final Function(ExperiencePassenger) onSave;

  const PassengerFormPage({
    super.key,
    required this.passengerIndex,
    required this.passenger,
    required this.onSave,
  });

  @override
  State<PassengerFormPage> createState() => _PassengerFormPageState();
}

class _PassengerFormPageState extends State<PassengerFormPage> {
  late ExperiencePassenger _passenger;

  @override
  void initState() {
    super.initState();
    _passenger = widget.passenger;
  }

  void _updatePassenger(ExperiencePassenger passenger) {
    setState(() {
      _passenger = passenger;
    });
  }

  bool get _isValid {
    return _passenger.firstName.isNotEmpty && _passenger.lastName.isNotEmpty;
  }

  String? get _validationError {
    if (_passenger.firstName.isEmpty) return 'First name is required';
    if (_passenger.lastName.isEmpty) return 'Last name is required';
    return null;
  }

  void _saveAndReturn() {
    if (_isValid) {
      widget.onSave(_passenger);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _validationError ?? 'Please complete all required fields',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Passenger ${widget.passengerIndex + 1} Details',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        actions: [
          if (_isValid)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 24,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildForm(),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Passenger Type Toggle
        Text(
          'Passenger Type',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                label: 'Adult',
                icon: Icons.person,
                isSelected: _passenger.passengerType == PassengerType.adult,
                onTap: () {
                  _updatePassenger(
                      _passenger.copyWith(passengerType: PassengerType.adult));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleButton(
                label: 'Child',
                icon: Icons.child_care,
                isSelected: _passenger.passengerType == PassengerType.child,
                onTap: () {
                  _updatePassenger(
                      _passenger.copyWith(passengerType: PassengerType.child));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Residency Status Toggle
        Text(
          'Residency Status',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                label: 'Resident',
                icon: Icons.home,
                isSelected:
                    _passenger.residencyStatus == ResidencyStatus.resident,
                onTap: () {
                  _updatePassenger(_passenger.copyWith(
                      residencyStatus: ResidencyStatus.resident));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleButton(
                label: 'Foreigner',
                icon: Icons.flight,
                isSelected:
                    _passenger.residencyStatus == ResidencyStatus.foreigner,
                onTap: () {
                  _updatePassenger(_passenger.copyWith(
                      residencyStatus: ResidencyStatus.foreigner));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Name Fields
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _passenger.firstName,
                decoration: InputDecoration(
                  labelText: 'First Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  _updatePassenger(_passenger.copyWith(firstName: value));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: _passenger.lastName,
                decoration: InputDecoration(
                  labelText: 'Last Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  _updatePassenger(_passenger.copyWith(lastName: value));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _passenger.phoneNumber,
          decoration: InputDecoration(
            labelText: 'Phone Number (Optional)',
            hintText: 'Contact number for this passenger',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            _updatePassenger(_passenger.copyWith(
                phoneNumber: value.isNotEmpty ? value : null));
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _passenger.idPassportNumber,
          decoration: InputDecoration(
            labelText: 'Passport/ID Number (Optional)',
            hintText: 'ID or passport number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            _updatePassenger(_passenger.copyWith(
                idPassportNumber: value.isNotEmpty ? value : null));
          },
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? AppTheme.textPrimaryColor : AppTheme.backgroundColor,
          border: Border.all(
            color:
                isSelected ? AppTheme.textPrimaryColor : AppTheme.borderColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppTheme.backgroundColor
                  : AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.backgroundColor
                    : AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveAndReturn,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textPrimaryColor,
              foregroundColor: AppTheme.backgroundColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save Passenger Details',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
