import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// Removed unused import: cached_network_image
import 'payment/add_card.dart';
import 'booking_confirmation_page.dart';
import '../../core/models/charter_deal_model.dart';
import '../../core/models/booking_model.dart';
import '../../core/providers/passengers_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/controllers/booking_controller.dart';
import '../../shared/widgets/passenger_list_widget.dart';
import '../../shared/widgets/app_spinner.dart';

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
            _buildFlightDetails(),

            // Passengers Section
            _buildPassengersSection(),

            // Special Requests
            _buildSpecialRequests(),

            // Important Information
            _buildImportantInformation(),

            // Support Section
            _buildSupportSection(),

            // Price Breakdown
            _buildPriceBreakdown(),

            // Billing Region
            _buildBillingRegion(),

            // Payment Section
            _buildPaymentSection(),

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

  Widget _buildFlightDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flight Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Aircraft and Seating
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aircraft Type',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.aircraft,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Seating Capacity',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.seats} seats',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Departure and Arrival
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Departure',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.departure,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.date} • ${widget.time}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.flight_takeoff_rounded,
                  color: Color(0xFF666666),
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Arrival',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.destination,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.duration,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Flight Type and Direct Flight
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Direct Flight',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Private Charter',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7B1FA2),
                  ),
                ),
              ),
            ],
          ),
        ],
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

  Widget _buildSpecialRequests() {
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
            'Special Requests',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Onboard Dining Toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Onboard Dining',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Premium catering service',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _onboardDining,
                onChanged: (value) {
                  setState(() {
                    _onboardDining = value;
                  });
                },
                activeColor: Colors.black,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Ground Transportation Toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ground Transportation',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Airport pickup and drop-off',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _groundTransportation,
                onChanged: (value) {
                  setState(() {
                    _groundTransportation = value;
                  });
                },
                activeColor: Colors.black,
              ),
            ],
          ),
        ],
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

  Widget _buildPriceBreakdown() {
    final basePrice = widget.price;
    final diningCost = _onboardDining ? 150.0 : 0.0;
    final transportationCost = _groundTransportation ? 200.0 : 0.0;
    final taxes = (basePrice + diningCost + transportationCost) * 0.12;
    final totalPrice = basePrice + diningCost + transportationCost + taxes;

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
            'Price Breakdown',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceItem('Base Charter Cost', basePrice),
          if (_onboardDining) _buildPriceItem('Onboard Dining', diningCost),
          if (_groundTransportation)
            _buildPriceItem('Ground Transportation', transportationCost),
          _buildPriceItem('Taxes & Fees', taxes),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5E5E5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
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

  Widget _buildPriceItem(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF666666),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
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

  Widget _buildPaymentSection() {
    // Find the selected payment method details
    Map<String, dynamic>? selectedCard = _savedCards.firstWhere(
      (card) => card['name'] == _selectedPaymentMethod,
      orElse: () => {},
    );

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
                'Payment Method',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: _showChangePaymentMethod,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Change',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Selected Payment Method Display
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
                  child: Icon(
                    selectedCard.isNotEmpty
                        ? selectedCard['icon']
                        : Icons.credit_card,
                    size: 20,
                    color: const Color(0xFF666666),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedPaymentMethod,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      if (selectedCard.isNotEmpty &&
                          selectedCard['details'] != null)
                        const SizedBox(height: 4),
                      if (selectedCard.isNotEmpty &&
                          selectedCard['details'] != null)
                        Text(
                          selectedCard['details'],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF666666),
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 20,
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
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Payment Method',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddCard();
                    },
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: Colors.black,
                    ),
                    label: Text(
                      'Add Card',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Saved Cards
              if (_savedCards.isNotEmpty) ...[
                Text(
                  'Saved Cards',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 12),
                ..._savedCards.map((card) => _buildPaymentOption(
                    card['name'], card['icon'], card['details'])),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
              ],

              // Other Payment Methods
              Text(
                'Other Payment Methods',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 12),
              ..._paymentMethods.map((method) =>
                  _buildPaymentOption(method['name'], method['icon'], null)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String name, IconData icon, String? details) {
    final isSelected = _selectedPaymentMethod == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = name;
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF0EA5E9) : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF666666),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  if (details != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      details,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF0EA5E9),
                size: 20,
              ),
          ],
        ),
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

      // Get passengers from provider
      final passengerProvider =
          Provider.of<PassengerProvider>(context, listen: false);
      final passengers = passengerProvider.passengers;

      // Parse the date string to DateTime
      DateTime parsedDate;
      try {
        // Assuming the date comes in format "Dec 15" - we need to add year
        final currentYear = DateTime.now().year;
        final parts = widget.date.split(' ');
        final monthName = parts[0];
        final day = int.parse(parts[1]);

        final monthMap = {
          'Jan': 1,
          'Feb': 2,
          'Mar': 3,
          'Apr': 4,
          'May': 5,
          'Jun': 6,
          'Jul': 7,
          'Aug': 8,
          'Sep': 9,
          'Oct': 10,
          'Nov': 11,
          'Dec': 12
        };

        final month = monthMap[monthName] ?? 1;
        parsedDate = DateTime(currentYear, month, day);

        // If the date is in the past, assume next year
        if (parsedDate.isBefore(DateTime.now())) {
          parsedDate = DateTime(currentYear + 1, month, day);
        }
      } catch (e) {
        // Fallback to tomorrow if parsing fails
        parsedDate = DateTime.now().add(const Duration(days: 1));
      }

      // Create booking model
      final booking = BookingModel(
        departure: widget.departure,
        destination: widget.destination,
        departureDate: parsedDate,
        departureTime: widget.time,
        aircraft: widget.aircraft,
        totalPassengers: passengers.length,
        duration: widget.duration,
        basePrice: basePrice,
        totalPrice: totalPrice,
        onboardDining: _onboardDining,
        groundTransportation: _groundTransportation,
        billingRegion: _selectedBillingRegion,
        paymentMethod: _selectedPaymentMethod,
        passengers: passengers,
      );

      // Create booking through controller
      final bookingController =
          Provider.of<BookingController>(context, listen: false);
      final result = await bookingController.createBookingWithPassengers(
        departure: widget.departure,
        destination: widget.destination,
        departureDate: parsedDate,
        departureTime: widget.time,
        aircraft: widget.aircraft,
        duration: widget.duration,
        basePrice: basePrice,
        totalPrice: totalPrice,
        onboardDining: _onboardDining,
        groundTransportation: _groundTransportation,
        billingRegion: _selectedBillingRegion,
        paymentMethod: _selectedPaymentMethod,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result.isSuccess && result.booking != null) {
        // Navigate to booking confirmation page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  BookingConfirmationPage(booking: result.booking!),
            ),
          );
        }
      } else {
        // Show error dialog
        if (mounted) {
          _showErrorDialog(result.errorMessage ?? 'Failed to create booking. Please try again.');
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
}
