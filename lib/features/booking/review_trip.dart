// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'booking_confirmation_page.dart';
import '../../core/models/charter_deal_model.dart';
import '../../core/models/booking_model.dart' show BookingModel, PaymentMethod;
import '../../core/providers/passengers_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/booking_business_service.dart';
import '../../shared/widgets/passenger_list_widget.dart';
import '../../shared/widgets/loading_system.dart';

// Import modular widgets
import 'widgets/flight_details_widget.dart';
import 'widgets/special_requests_widget.dart';
import 'widgets/price_breakdown_widget.dart';

class ReviewTripPage extends StatefulWidget {
  final String departure;
  final String destination;
  final String date;
  final String time;
  final String aircraft;
  final int seats;
  final String duration;
  final double price;
  final CharterDealModel? deal; // ✅ Add deal parameter

  const ReviewTripPage({
    super.key,
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.aircraft,
    required this.seats,
    required this.duration,
    required this.price,
    this.deal, // ✅ Add deal parameter
  });

  @override
  State<ReviewTripPage> createState() => _ReviewTripPageState();
}

class _ReviewTripPageState extends State<ReviewTripPage> {
  bool _onboardDining = false;
  bool _groundTransportation = false;
  bool _agreeToTerms = false;
  String _selectedBillingRegion = 'United States';
  late final String _bookingId;

  final List<String> _billingRegions = [
    'United States',
    'Canada',
    'United Kingdom',
    'European Union',
    'Australia',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Generate a unique booking ID for when the booking is actually created
    _bookingId = 'booking_${DateTime.now().millisecondsSinceEpoch}';

    // Initialize passenger management for booking creation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final passengerProvider =
          Provider.of<PassengerProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Initialize with current user data
      passengerProvider.initializeForBooking(
          currentUser: authProvider.currentUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          'Review Trip',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Flight Details
            FlightDetailsWidget(
              departure: widget.departure,
              destination: widget.destination,
              date: widget.date,
              time: widget.time,
              aircraft: widget.aircraft,
              seats: widget.seats,
              duration: widget.duration,
            ),

            // Passengers Section
            _buildPassengersSection(),

            // Special Requests
            SpecialRequestsWidget(
              departure: widget.departure,
              destination: widget.destination,
              onboardDining: _onboardDining,
              groundTransportation: _groundTransportation,
              onOnboardDiningChanged: (value) {
                setState(() {
                  _onboardDining = value;
                });
              },
              onGroundTransportationChanged: (value) {
                setState(() {
                  _groundTransportation = value;
                });
              },
            ),

            // Important Information
            _buildImportantInformation(),

            // Support Section
            _buildSupportSection(),

            // Price Breakdown
            PriceBreakdownWidget(
              departure: widget.departure,
              destination: widget.destination,
              basePrice: widget.price,
              onboardDining: _onboardDining,
              groundTransportation: _groundTransportation,
            ),

            // Billing Region
            _buildBillingRegion(),

            // Payment Section - Simplified
            _buildSimplifiedPaymentSection(),

            // Agreement Section
            _buildAgreementSection(),

            // Request & Pay Button
            _buildRequestPayButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: PassengerListWidget(
        bookingId: 'local_booking', // Use consistent local booking ID
        onPassengersChanged: () {
          // Refresh UI when passengers change
          setState(() {});
        },
      ),
    );
  }

  Widget _buildImportantInformation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Important Information',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Cancellation Policy
          _buildInfoItem(
            'Cancellation Policy',
            'Free cancellation up to 24 hours before departure',
            null,
          ),

          const SizedBox(height: 12),

          // Terms & Conditions with arrow
          GestureDetector(
            onTap: () {
              // Navigate to terms and conditions
            },
            child: _buildInfoItem(
              'Terms & Conditions',
              'View complete terms and conditions',
              Icons.arrow_forward_ios_rounded,
            ),
          ),

          const SizedBox(height: 12),

          // Empty Leg Information
          _buildInfoItem(
            'Empty Leg Flight',
            'This flight may be subject to schedule changes',
            null,
          ),

          const SizedBox(height: 12),

          // Operator Approval
          _buildInfoItem(
            'Booking Approval',
            'Subject to operator approval within 24 hours',
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description, IconData? icon) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
        if (icon != null)
          Icon(
            icon,
            color: const Color(0xFF666666),
            size: 16,
          ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.headset_mic_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Help?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Contact our 24/7 support team',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Contact support
            },
            child: Text(
              'Contact',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingRegion() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Billing Region',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedBillingRegion,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _billingRegions.map((region) {
              return DropdownMenuItem(
                value: region,
                child: Text(
                  region,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBillingRegion = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimplifiedPaymentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Secure Payment',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF666666),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    size: 20,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter payment details on next screen',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF666666),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value!;
              });
            },
            activeColor: Colors.black,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF666666),
                  ),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestPayButton() {
    final basePrice = widget.price;
    final diningCost = _onboardDining ? 150.0 : 0.0;
    final transportationCost = _groundTransportation ? 200.0 : 0.0;
    final taxes = (basePrice + diningCost + transportationCost) * 0.12;
    final totalPrice = basePrice + diningCost + transportationCost + taxes;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Single Request & Pay Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _agreeToTerms
                  ? () {
                      _addToCart();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: const Color(0xFFE5E5E5),
                foregroundColor: Colors.white,
                disabledForegroundColor: const Color(0xFF888888),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Request & Pay',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Total Price Display
          Text(
            'Total: \$${totalPrice.toStringAsFixed(2)} USD',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart() async {
    print('=== ADDING TO CART START ===');
    print('Stack trace: ${StackTrace.current}');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Loading Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child:
                    LoadingSystem.inline(size: 24, color: Colors.blue.shade600),
              ),
              const SizedBox(height: 20),

              // Loading Text
              Text(
                'Processing Booking...',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Please wait while we create your booking request',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      print('=== CALCULATING PRICING ===');
      // Calculate pricing
      final basePrice = widget.price;
      final diningCost = _onboardDining ? 150.0 : 0.0;
      final transportationCost = _groundTransportation ? 200.0 : 0.0;
      final taxes = (basePrice + diningCost + transportationCost) * 0.12;
      final totalPrice = basePrice + diningCost + transportationCost + taxes;

      print('Base price: $basePrice');
      print('Dining cost: $diningCost');
      print('Transportation cost: $transportationCost');
      print('Taxes: $taxes');
      print('Total price: $totalPrice');

      print('=== GETTING BOOKING CONTROLLER ===');
      // Create booking without payment intent (request only)
      final bookingService =
          Provider.of<BookingBusinessService>(context, listen: false);
      print('Booking service obtained: ${bookingService != null}');

      print('=== CALLING CREATE BOOKING (REQUEST ONLY) ===');
      print('Deal ID: ${widget.deal?.id ?? 0}');
      print('Total price: $totalPrice');

      final result = await bookingService.createBookingWithPaymentIntent(
        dealId: widget.deal?.id ?? 0,
        totalPrice: totalPrice.toDouble(),
        onboardDining: _onboardDining,
        groundTransportation: _groundTransportation,
        billingRegion: _selectedBillingRegion,
        paymentMethod: PaymentMethod.card, // Default for request
      );

      print('=== BOOKING RESULT RECEIVED ===');
      print('Result success: ${result.isSuccess}');
      print('Result booking: ${result.booking != null}');
      print('Result error message: ${result.errorMessage}');

      if (result.isSuccess && result.booking != null) {
        print('=== REQUEST SUCCESSFUL - NAVIGATING TO CONFIRMATION ===');
        // Close loading dialog before navigation
        if (mounted) {
          Navigator.of(context).pop();
          print('=== LOADING DIALOG CLOSED ===');
        }
        // Request successful - navigate to confirmation
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BookingConfirmationPage(
                bookingData: {
                  'id': result.booking!.id, // Add the actual booking ID
                  'reference': result.booking!.referenceNumber,
                  'departure': widget.departure,
                  'destination': widget.destination,
                  'date': widget.date,
                  'time': widget.time,
                  'aircraft': widget.aircraft,
                  'passengers': result.booking!.passengers
                      .map((passenger) => {
                            'firstName': passenger.firstName,
                            'lastName': passenger.lastName,
                            'age': passenger.age,
                            'nationality': passenger.nationality,
                            'passportNumber': passenger.idPassportNumber,
                            'type': 'Adult', // Default type
                          })
                      .toList(),
                  'totalAmount': totalPrice,
                  'onboardDining': _onboardDining,
                  'groundTransportation': _groundTransportation,
                  'billingRegion': _selectedBillingRegion,
                },
              ),
            ),
          );
        }
      } else {
        print('=== REQUEST FAILED - SHOWING ERROR ===');
        // Close loading dialog before showing error
        if (mounted) {
          Navigator.of(context).pop();
          print('=== LOADING DIALOG CLOSED DUE TO ERROR ===');
        }
        // Show error dialog
        if (mounted) {
          _showErrorDialog(result.errorMessage ??
              'Failed to create booking request. Please try again.');
        }
      }
    } catch (e, stackTrace) {
      print('=== EXCEPTION CAUGHT ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        print('=== LOADING DIALOG CLOSED DUE TO EXCEPTION ===');
      }

      // Show error dialog
      if (mounted) {
        _showErrorDialog('An error occurred: ${e.toString()}');
      }
    }

    print('=== ADDING TO CART END ===');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red[600],
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Error',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF666666),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'OK',
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
      ),
    );
  }
}
