import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:air_charters/core/models/experience_booking_model.dart';
import 'package:air_charters/core/services/payment_service.dart';
import 'package:air_charters/core/network/api_client.dart';
import 'package:air_charters/core/services/experience_booking_service.dart';
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
  late PaymentService _paymentService;
  late ExperienceBookingService _bookingService;

  PaymentMethod _selectedPaymentMethod = PaymentMethod.mpesa;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _phoneNumber;

  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(ApiClient());
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
      String? paymentIntentId;

      if (_selectedPaymentMethod == PaymentMethod.mpesa) {
        // Process M-Pesa payment
        final mpesaResult = await _paymentService.initiateMpesaPayment(
          bookingId: widget.booking.experienceId.toString(),
          amount: widget.booking.totalPrice,
          phoneNumber: _phoneNumber!,
          description: 'Payment for ${widget.booking.experienceTitle}',
        );

        paymentIntentId = mpesaResult['paymentIntentId'];

        // Show M-Pesa instructions
        _showMpesaInstructions(mpesaResult);
      } else {
        // Create payment intent for other methods
        final paymentIntent = await _paymentService.createPaymentIntent(
          amount: widget.booking.totalPrice,
          currency: 'USD',
          bookingId: widget.booking.experienceId.toString(),
          paymentMethod: _selectedPaymentMethod,
          metadata: {
            'experienceTitle': widget.booking.experienceTitle,
            'passengersCount': widget.booking.passengersCount,
          },
        );

        paymentIntentId = paymentIntent['id'];
      }

      // Create the booking
      final bookingResult = await _bookingService.createBooking(widget.booking);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExperienceBookingConfirmation(
              bookingId: bookingResult['bookingId'],
              booking: widget.booking,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isProcessing = false;
      });
    }
  }

  void _showMpesaInstructions(Map<String, dynamic> mpesaResult) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Icon(
              Icons.phone_android,
              size: 48,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'M-Pesa Payment',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please check your phone and follow these steps:',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(1, 'Open M-Pesa app'),
            _buildInstructionStep(2, 'Enter your M-Pesa PIN'),
            _buildInstructionStep(3, 'Confirm the payment'),
            const SizedBox(height: 16),
            Text(
              'Amount: \$${widget.booking.totalPrice.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkPaymentStatus(mpesaResult['paymentIntentId']);
            },
            child: Text(
              'I\'ve Completed Payment',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int step, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$step',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkPaymentStatus(String paymentIntentId) async {
    try {
      final status = await _paymentService.checkPaymentStatus(paymentIntentId);

      if (status['status'] == 'completed') {
        // Payment successful, create booking
        final bookingResult =
            await _bookingService.createBooking(widget.booking);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ExperienceBookingConfirmation(
                bookingId: bookingResult['bookingId'],
                booking: widget.booking,
              ),
            ),
          );
        }
      } else {
        // Payment failed or pending
        setState(() {
          _errorMessage = 'Payment ${status['status']}. Please try again.';
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify payment: $e';
        _isProcessing = false;
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

