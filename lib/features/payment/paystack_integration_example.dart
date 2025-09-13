import 'package:flutter/material.dart';
import '../../core/services/paystack_service.dart';
import '../../shared/widgets/paystack_payment_widget.dart';

/// Example of how to integrate Paystack payments into existing payment pages
/// This shows how to use the PaystackPaymentWidget without altering your UI design
class PaystackIntegrationExample extends StatefulWidget {
  final String bookingId;
  final int companyId;
  final String userId;
  final double amount;
  final String currency;
  final String email;

  const PaystackIntegrationExample({
    super.key,
    required this.bookingId,
    required this.companyId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.email,
  });

  @override
  State<PaystackIntegrationExample> createState() => _PaystackIntegrationExampleState();
}

class _PaystackIntegrationExampleState extends State<PaystackIntegrationExample> {
  final PaystackService _paystackService = PaystackService();
  final bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Options'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Your existing payment summary UI
            _buildPaymentSummary(),
            
            const SizedBox(height: 24),
            
            // Payment method selection
            _buildPaymentMethodSelection(),
            
            const SizedBox(height: 24),
            
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Pay button
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Amount:'),
                Text(
                  _paystackService.formatAmount(widget.amount, widget.currency),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Currency:'),
                Text(widget.currency),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Booking ID:'),
                Text(widget.bookingId),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Card Payment Option
            _buildPaymentOption(
              icon: Icons.credit_card,
              title: 'Pay with Card',
              subtitle: 'Visa, Mastercard, Verve',
              onTap: () => _processCardPayment(),
            ),
            
            const SizedBox(height: 12),
            
            // M-Pesa Payment Option
            _buildPaymentOption(
              icon: Icons.phone_android,
              title: 'Pay with M-Pesa',
              subtitle: 'Mobile Money (Kenya)',
              onTap: () => _processMpesaPayment(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _showPaymentWidget,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Continue to Payment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  void _processCardPayment() {
    _showPaymentWidget(paymentMethod: 'card');
  }

  void _processMpesaPayment() {
    _showPaymentWidget(paymentMethod: 'mpesa');
  }

  void _showPaymentWidget({String? paymentMethod}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaystackPaymentWidget(
        bookingId: widget.bookingId,
        companyId: widget.companyId,
        userId: widget.userId,
        amount: widget.amount,
        currency: widget.currency,
        email: widget.email,
        preferredPaymentMethod: paymentMethod,
        onPaymentSuccess: (response) {
          Navigator.of(context).pop();
          _showSuccessDialog(response);
        },
        onPaymentError: (error) {
          Navigator.of(context).pop();
          setState(() {
            _errorMessage = error;
          });
        },
        onPaymentCancelled: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment cancelled')),
          );
        },
      ),
    );
  }

  void _showSuccessDialog(PaystackResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reference: ${response.reference ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Status: ${response.status}'),
            if (response.message != null) ...[
              const SizedBox(height: 8),
              Text('Message: ${response.message}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to booking confirmation or home
              Navigator.of(context).pop();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

/// Example of how to integrate into existing payment flow
/// This can be used in your existing payment pages
class ExistingPaymentPageIntegration {
  static void showPaystackPayment({
    required BuildContext context,
    required String bookingId,
    required int companyId,
    required String userId,
    required double amount,
    required String currency,
    required String email,
    String? preferredPaymentMethod,
    required Function(PaystackResponse) onSuccess,
    required Function(String) onError,
    required VoidCallback onCancelled,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaystackPaymentWidget(
        bookingId: bookingId,
        companyId: companyId,
        userId: userId,
        amount: amount,
        currency: currency,
        email: email,
        preferredPaymentMethod: preferredPaymentMethod,
        onPaymentSuccess: onSuccess,
        onPaymentError: onError,
        onPaymentCancelled: onCancelled,
      ),
    );
  }
}
