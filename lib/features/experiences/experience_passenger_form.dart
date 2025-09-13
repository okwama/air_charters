import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:air_charters/core/models/experience_booking_model.dart';
import 'package:air_charters/core/services/experience_booking_service.dart';
import 'package:air_charters/core/network/api_client.dart';
import 'experience_payment_page.dart';

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
        email: '',
        phone: '',
      ));
    }
  }

  void _updatePassenger(int index, ExperiencePassenger passenger) {
    setState(() {
      _passengers[index] = passenger;
    });
  }

  bool get _canProceed {
    return _passengers.every((passenger) =>
        passenger.firstName.isNotEmpty &&
        passenger.lastName.isNotEmpty &&
        _isValidEmail(passenger.email) &&
        _isValidPhone(passenger.phone));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    // Basic phone validation - at least 10 digits
    return RegExp(r'^[\+]?[0-9]{10,}$')
        .hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  String? _getPassengerValidationError(int index) {
    final passenger = _passengers[index];

    if (passenger.firstName.isEmpty) {
      return 'First name is required';
    }
    if (passenger.lastName.isEmpty) {
      return 'Last name is required';
    }
    if (passenger.email.isEmpty) {
      return 'Email is required';
    }
    if (!_isValidEmail(passenger.email)) {
      return 'Please enter a valid email address';
    }
    if (passenger.phone.isEmpty) {
      return 'Phone number is required';
    }
    if (!_isValidPhone(passenger.phone)) {
      return 'Please enter a valid phone number';
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

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExperiencePaymentPage(
              booking: finalBooking,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Passenger Details',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
                        color: Colors.grey.shade600,
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
                      color: Colors.grey.shade600,
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
                  color: Colors.black,
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
            if (!_canProceed)
              Text(
                'Please complete all required fields',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.red.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_passengers.length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Passenger ${index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_getPassengerValidationError(index) != null)
                      Text(
                        _getPassengerValidationError(index)!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.red.shade600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPassengerForm(index),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPassengerForm(int index) {
    final passenger = _passengers[index];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: passenger.firstName,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  _updatePassenger(index, passenger.copyWith(firstName: value));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: passenger.lastName,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  _updatePassenger(index, passenger.copyWith(lastName: value));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: passenger.email,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            _updatePassenger(index, passenger.copyWith(email: value));
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: passenger.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            _updatePassenger(index, passenger.copyWith(phone: value));
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: passenger.passportNumber,
          decoration: InputDecoration(
            labelText: 'Passport Number (Optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            _updatePassenger(index, passenger.copyWith(passportNumber: value));
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: passenger.specialRequirements,
          decoration: InputDecoration(
            labelText: 'Special Requirements (Optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 2,
          onChanged: (value) {
            _updatePassenger(
                index, passenger.copyWith(specialRequirements: value));
          },
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
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
