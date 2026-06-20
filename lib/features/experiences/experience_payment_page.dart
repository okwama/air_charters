import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/core/models/experience_booking_model.dart';
import 'package:air_charters/core/services/payment_service.dart';
import 'package:air_charters/core/network/api_client.dart';
import 'package:air_charters/core/services/experience_booking_service.dart';
import 'package:air_charters/features/booking/payment/in_app_checkout_screen.dart';
import 'package:air_charters/config/env/app_config.dart';
import 'package:air_charters/core/providers/auth_provider.dart';
import 'experience_booking_confirmation.dart';

class ExperiencePaymentPage extends StatefulWidget {
  final ExperienceBookingModel booking;

  const ExperiencePaymentPage({
    super.key,
    required this.booking,
  });

  @override
  State<ExperiencePaymentPage> createState() => _ExperiencePaymentPageState();
}

class _ExperiencePaymentPageState extends State<ExperiencePaymentPage> {
  late ExperienceBookingService _bookingService;

  PaymentMethod _selectedPaymentMethod = PaymentMethod.mpesa;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _phoneNumber;

  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bookingService = ExperienceBookingService(ApiClient());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == PaymentMethod.mpesa &&
        (_phoneNumber?.isEmpty ?? true)) {
      setState(() {
        _errorMessage = 'Please enter your phone number for M-Pesa payment';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      print('🔵 EXPERIENCE PAYMENT: Starting payment process...');
      print('🔵 Booking Details:');
      print('   - Experience ID: ${widget.booking.experienceId}');
      print('   - Company ID: ${widget.booking.companyId}');
      print('   - Amount: ${widget.booking.totalPrice}');
      print('   - Passengers: ${widget.booking.passengers.length}');

      // Create the booking first
      final bookingResult = await _bookingService.createBooking(widget.booking);
      print('🔵 Booking created successfully!');

      // Backend returns 'id', not 'bookingId'
      final bookingId = bookingResult['id'] ?? bookingResult['bookingId'];
      print('   - Booking ID: $bookingId');
      print('   - Response: $bookingResult');

      if (bookingId != null) {
        // Get user email from AuthProvider
        final authProvider = context.read<AuthProvider>();
        final user = authProvider.currentUser;
        final userEmail = user?.email ?? 'customer@example.com';

        print('🔵 User details:');
        print('   - Email: $userEmail');
        print('   - User ID: ${user?.id}');

        print('🔵 Navigating to InAppCheckoutScreen...');

        // Navigate to Paystack payment screen
        if (mounted) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InAppCheckoutScreen(
                bookingId: bookingId.toString(),
                amount: widget.booking.totalPrice,
                currency: AppConfig.paystackCurrency.toUpperCase(), // Use KES
                email: userEmail, // Use real user email
                companyId:
                    widget.booking.companyId ?? 1, // Use actual company ID
                preferredPaymentMethod:
                    _selectedPaymentMethod == PaymentMethod.mpesa
                        ? 'mpesa'
                        : 'card',
              ),
            ),
          );

          print('🔵 Payment screen returned with result: $result');
          print('   - Result type: ${result.runtimeType}');

          // Handle payment result
          // InAppCheckoutScreen returns a Map like {'action': 'done'} or {'action': 'view_ticket'}
          // or false if payment failed
          final bool paymentSuccessful = result != null &&
              result != false &&
              (result is Map &&
                  (result['action'] == 'done' ||
                      result['action'] == 'view_ticket'));

          if (paymentSuccessful) {
            print('✅ Payment successful! Navigating to confirmation...');
            // Payment successful, navigate to confirmation
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ExperienceBookingConfirmation(
                    bookingId: bookingId,
                    booking: widget.booking,
                  ),
                ),
              );
            }
          } else {
            print('⚠️ Payment not completed. Result: $result');
            setState(() {
              _isProcessing = false;
              _errorMessage = result == false
                  ? 'Payment was cancelled or failed. Please try again.'
                  : 'Payment was not completed. Please try again.';
            });
          }
        }
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      print('❌ EXPERIENCE PAYMENT ERROR: $e');

      // Check if it's an authentication error
      String errorMessage = e.toString();
      if (errorMessage.contains('401') ||
          errorMessage.contains('Authentication') ||
          errorMessage.contains('Unauthorized')) {
        errorMessage = 'Your session has expired. Please log in again.';
        // Optionally: Navigate to login screen
        // Navigator.pushReplacementNamed(context, '/login');
      } else if (errorMessage.contains('Network error')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      }

      setState(() {
        _errorMessage = errorMessage;
        _isProcessing = false;
      });
    }
  }

  // These methods are kept for potential future M-Pesa direct integration
  // Currently using Paystack WebView flow which handles M-Pesa internally

  // void _showMpesaInstructions(Map<String, dynamic> mpesaResult) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       // ... M-Pesa instructions dialog
  //     ),
  //   );
  // }

  // Future<void> _checkPaymentStatus(String paymentIntentId) async {
  //   // ... Payment status checking logic
  // }

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
          'Payment',
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

                  // Payment Methods
                  _buildPaymentMethods(),
                  const SizedBox(height: 24),

                  // Phone Number Input (for M-Pesa)
                  if (_selectedPaymentMethod == PaymentMethod.mpesa) ...[
                    _buildPhoneInput(),
                    const SizedBox(height: 24),
                  ],

                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
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
                    const SizedBox(height: 24),
                  ],
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
                'Total Amount',
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

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodOption(
          PaymentMethod.mpesa,
          'M-Pesa',
          'Pay with mobile money',
          Icons.phone_android,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodOption(
          PaymentMethod.card,
          'Credit/Debit Card',
          'Pay with card',
          Icons.credit_card,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodOption(
          PaymentMethod.bankTransfer,
          'Bank Transfer',
          'Pay via bank transfer',
          Icons.account_balance,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter your phone number',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _phoneNumber = value;
            });
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the phone number registered with M-Pesa',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Pay ${widget.booking.formattedTotalPrice}',
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
