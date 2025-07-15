import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/booking_model.dart' as bookingModel;
import '../../core/models/passenger_model.dart';
import '../../core/models/payment_model.dart' as paymentModel;
import '../../core/controllers/booking_controller.dart';
import '../../core/services/payment_service.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/app_spinner.dart';
import '../mytrips/trips.dart';

class BookingConfirmationPage extends StatefulWidget {
  final bookingModel.BookingModel booking;

  const BookingConfirmationPage({
    super.key,
    required this.booking,
  });

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  final PaymentService _paymentService = PaymentService();
  paymentModel.PaymentMethod _selectedPaymentMethod =
      paymentModel.PaymentMethod.card;
  bool _isProcessingPayment = false;
  String? _paymentError;

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
          'Booking Confirmation',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingStatusCard(),
            const SizedBox(height: 24),
            _buildFlightDetailsCard(),
            const SizedBox(height: 24),
            _buildPassengersList(),
            const SizedBox(height: 24),
            _buildPricingBreakdown(),
            if (widget.booking.paymentStatus ==
                bookingModel.PaymentStatus.pending) ...[
              const SizedBox(height: 24),
              _buildPaymentOptions(),
              const SizedBox(height: 32),
              _buildPaymentButton(),
            ] else ...[
              const SizedBox(height: 32),
              _buildViewTripsButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingStatusCard() {
    final bool isPaid =
        widget.booking.paymentStatus == bookingModel.PaymentStatus.paid;
    final Color statusColor =
        isPaid ? const Color(0xFF2E7D32) : const Color(0xFFE65100);
    final Color backgroundColor =
        isPaid ? const Color(0xFFE8F5E8) : const Color(0xFFFFF3E0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            isPaid ? Icons.check_circle_rounded : Icons.access_time_rounded,
            size: 48,
            color: statusColor,
          ),
          const SizedBox(height: 12),
          Text(
            isPaid ? 'Booking Confirmed' : 'Awaiting Payment',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.booking.referenceNumber != null) ...[
            Text(
              'Booking Reference',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.booking.referenceNumber!,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlightDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
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
          _buildDetailRow('Route',
              '${widget.booking.departure} → ${widget.booking.destination}'),
          _buildDetailRow('Date', _formatDate(widget.booking.departureDate)),
          _buildDetailRow('Time', widget.booking.departureTime),
          _buildDetailRow(
              'Aircraft', 'Aircraft ID: ${widget.booking.aircraftId}'),
          _buildDetailRow('Duration', '${widget.booking.duration} minutes'),
          _buildDetailRow('Passengers', '${widget.booking.passengers.length}'),
          if (widget.booking.specialRequirements?.isNotEmpty == true)
            _buildDetailRow(
                'Special Requirements', widget.booking.specialRequirements!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
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
            'Passengers (${widget.booking.passengers.length})',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.booking.passengers.asMap().entries.map((entry) {
            final index = entry.key;
            final passenger = entry.value;
            return _buildPassengerCard(passenger, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildPassengerCard(PassengerModel passenger, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passenger.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                if (passenger.age != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Age: ${passenger.age}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
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
            'Pricing Breakdown',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Base Price', widget.booking.basePrice),
          if (widget.booking.onboardDining)
            _buildPriceRow('Onboard Dining', 50.0), // Example pricing
          if (widget.booking.groundTransportation)
            _buildPriceRow('Ground Transportation', 30.0), // Example pricing
          const Divider(height: 24, color: Color(0xFFE5E5E5)),
          _buildPriceRow('Total', widget.booking.totalPrice, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? Colors.black : const Color(0xFF666666),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
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
            'Payment Method',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodOption(paymentModel.PaymentMethod.card,
              'Credit/Debit Card', Icons.credit_card),
          _buildPaymentMethodOption(
              paymentModel.PaymentMethod.mpesa, 'M-Pesa', Icons.phone_android),
          _buildPaymentMethodOption(paymentModel.PaymentMethod.wallet, 'Wallet',
              Icons.account_balance_wallet),
          if (_paymentError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE57373)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFD32F2F), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _paymentError!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFFD32F2F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
      paymentModel.PaymentMethod method, String title, IconData icon) {
    final bool isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFE5E5E5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 24,
                color: isSelected ? Colors.black : const Color(0xFF666666)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.black : const Color(0xFF666666),
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : const Color(0xFF666666),
                  width: 2,
                ),
                color: isSelected ? Colors.black : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return CustomButton(
      text: _isProcessingPayment
          ? 'Processing...'
          : 'Pay Now (\$${widget.booking.totalPrice.toStringAsFixed(2)})',
      onPressed: _isProcessingPayment ? null : _processPayment,
      isLoading: _isProcessingPayment,
    );
  }

  Widget _buildViewTripsButton() {
    return CustomButton(
      text: 'View My Trips',
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TripsPage()),
          (route) => false,
        );
      },
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessingPayment = true;
      _paymentError = null;
    });

    try {
      // Calculate platform fee (example: 5% of total)
      final double platformFee = widget.booking.totalPrice * 0.05;

      // Create payment
      final paymentResult = await _paymentService.createPayment(
        bookingId: widget.booking.referenceNumber ?? '',
        paymentMethod: _selectedPaymentMethod,
        totalAmount: widget.booking.totalPrice,
        platformFee: platformFee,
        companyId: 1, // This should come from the booking/deal
      );

      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Update payment status to completed (in real app, this would be done by payment gateway)
      await _paymentService.updatePaymentStatus(
          paymentResult.id, paymentModel.PaymentStatus.completed);

      // Show success and navigate to trips
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _paymentError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Successful!',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your booking has been confirmed. You will receive a confirmation email shortly.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'View My Trips',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const TripsPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
