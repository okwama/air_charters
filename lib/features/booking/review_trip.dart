import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// Removed unused import: cached_network_image
import 'payment/add_card.dart';
import 'payment/payment_screen.dart';
import 'booking_confirmation_page.dart';
import '../../core/models/charter_deal_model.dart';
import '../../core/models/booking_model.dart';
import '../../core/providers/passengers_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/controllers/booking.controller/booking_controller.dart';
import '../../shared/widgets/passenger_list_widget.dart';
import '../../shared/widgets/app_spinner.dart';

// Import modular widgets
import 'widgets/flight_details_widget.dart';
import 'widgets/special_requests_widget.dart';
import 'widgets/price_breakdown_widget.dart';
import 'widgets/payment_section_widget.dart';
import 'widgets/payment_method_selection_widget.dart';
import 'services/booking_review_service.dart';

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
  String _selectedPaymentMethod = 'Visa •••• 1234';
  late final String _bookingId;

  final List<String> _billingRegions = [
    'United States',
    'Canada',
    'United Kingdom',
    'European Union',
    'Australia',
    'Other',
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Credit Card', 'icon': Icons.credit_card},
    {'name': 'Debit Card', 'icon': Icons.payment},
    {'name': 'Digital Wallet', 'icon': Icons.account_balance_wallet},
    {'name': 'MPesa', 'icon': Icons.phone_android},
  ];

  final List<Map<String, dynamic>> _savedCards = [
    {
      'name': 'Visa •••• 1234',
      'icon': Icons.credit_card,
      'type': 'saved_card',
      'details': 'Expires 12/26'
    },
    {
      'name': 'Mastercard •••• 5678',
      'icon': Icons.credit_card,
      'type': 'saved_card',
      'details': 'Expires 08/25'
    },
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
              basePrice: widget.price,
              onboardDining: _onboardDining,
              groundTransportation: _groundTransportation,
            ),

            // Billing Region
            _buildBillingRegion(),

            // Payment Section
            PaymentSectionWidget(
              selectedPaymentMethod: _selectedPaymentMethod,
              savedCards: _savedCards,
              onChangePaymentMethod: _showChangePaymentMethod,
            ),

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
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _agreeToTerms
              ? () {
                  _showPaymentConfirmation();
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
            'Request & Pay – \$${totalPrice.toStringAsFixed(2)} USD',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCardPage(),
      ),
    ).then((result) {
      // Refresh the page if a card was added
      if (result == true) {
        setState(() {
          // You could add the new card to _savedCards here
          // For now, we'll just refresh the UI
        });
      }
    });
  }

  void _showChangePaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentMethodSelectionWidget(
        selectedPaymentMethod: _selectedPaymentMethod,
        savedCards: _savedCards,
        paymentMethods: _paymentMethods,
        onPaymentMethodSelected: (method) {
          setState(() {
            _selectedPaymentMethod = method;
          });
          Navigator.pop(context);
        },
        onAddCard: () {
          Navigator.pop(context);
          _showAddCard();
        },
      ),
    );
  }

  Future<void> _showPaymentConfirmation() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppSpinner(),
            const SizedBox(height: 16),
            Text(
              'Creating your booking...',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // Calculate pricing
      final basePrice = widget.price;
      final diningCost = _onboardDining ? 150.0 : 0.0;
      final transportationCost = _groundTransportation ? 200.0 : 0.0;
      final taxes = (basePrice + diningCost + transportationCost) * 0.12;
      final totalPrice = basePrice + diningCost + transportationCost + taxes;

      // Parse payment method
      PaymentMethod? paymentMethod;
      if (_selectedPaymentMethod.contains('Card')) {
        paymentMethod = PaymentMethod.card;
      } else if (_selectedPaymentMethod.contains('MPesa')) {
        paymentMethod = PaymentMethod.mpesa;
      } else if (_selectedPaymentMethod.contains('Wallet')) {
        paymentMethod = PaymentMethod.wallet;
      }

      // Create booking with payment intent through controller
      final bookingController =
          Provider.of<BookingController>(context, listen: false);
      final result = await bookingController.createBookingWithPaymentIntent(
        dealId: widget.deal?.id ?? 0,
        totalPrice: totalPrice.toDouble(),
        onboardDining: _onboardDining,
        groundTransportation: _groundTransportation,
        billingRegion: _selectedBillingRegion,
        paymentMethod: paymentMethod,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result.isSuccess && result.booking != null) {
        // Check if we have payment intent for Stripe integration
        if (result.bookingWithPaymentIntent?.paymentIntent != null) {
          final paymentIntent = result.bookingWithPaymentIntent!.paymentIntent!;

          // Validate that we have a valid client secret
          if (paymentIntent.clientSecret.isNotEmpty) {
            // Navigate to payment screen for Stripe payment
            if (mounted) {
              final paymentResult = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentScreen(
                    bookingId: result.booking!.id ?? '',
                    clientSecret: paymentIntent.clientSecret,
                    amount: totalPrice,
                    currency: 'USD',
                    paymentIntentId:
                        paymentIntent.id.isNotEmpty ? paymentIntent.id : null,
                  ),
                ),
              );

              // Handle payment result
              if (paymentResult == true) {
                // Payment successful - navigate to confirmation
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingConfirmationPage(
                        booking: result.booking!,
                      ),
                    ),
                  );
                }
                return;
              }
            }
          } else {
            // Fallback to legacy payment flow
            if (mounted) {
              _showLegacyPaymentDialog(context, result.booking!);
            }
          }
        } else {
          // No payment intent - use legacy payment flow
          if (mounted) {
            _showLegacyPaymentDialog(context, result.booking!);
          }
        }
      } else {
        // Show error dialog
        if (mounted) {
          _showErrorDialog(result.errorMessage ??
              'Failed to create booking. Please try again.');
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error dialog
      if (mounted) {
        _showErrorDialog('An error occurred: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Error',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
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

  void _showLegacyPaymentDialog(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Payment Required',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        content: Text(
          'This booking requires a payment. Please complete the payment process to confirm your booking.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // For legacy payment, we'll navigate to confirmation directly
              // since we don't have a client secret
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingConfirmationPage(
                    booking: booking,
                  ),
                ),
              );
            },
            child: Text(
              'Proceed to Confirmation',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
