import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodSelectionWidget extends StatelessWidget {
  final String selectedPaymentMethod;
  final String bookingId;
  final int companyId;
  final String userId;
  final double amount;
  final String currency;
  final String email;
  final Function(String) onPaymentMethodSelected;
  final VoidCallback onAddCard;

  const PaymentMethodSelectionWidget({
    super.key,
    required this.selectedPaymentMethod,
    required this.bookingId,
    required this.companyId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.email,
    required this.onPaymentMethodSelected,
    required this.onAddCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(
                  'Select Payment Method',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
            ),

            const SizedBox(height: 20),

            // Paystack Payment Methods
            Text(
              'Available Payment Methods',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 12),
            
            // Card Payment Option
            _buildPaystackPaymentOption(
              context,
              'Pay with Card',
              'Visa, Mastercard, Verve',
              Icons.credit_card,
              'card',
            ),
            
            const SizedBox(height: 8),
            
            // M-Pesa Payment Option
            _buildPaystackPaymentOption(
              context,
              'Pay with M-Pesa',
              'Mobile Money (Kenya)',
              Icons.phone_android,
              'mpesa',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaystackPaymentOption(
    BuildContext context,
    String name,
    String subtitle,
    IconData icon,
    String paymentMethod,
  ) {
    final isSelected = selectedPaymentMethod == paymentMethod;

    return GestureDetector(
      onTap: () => _handlePaystackPayment(context, paymentMethod),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0EA5E9) : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
              icon,
              size: 20,
                color: const Color(0xFF0EA5E9),
              ),
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
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                    const SizedBox(height: 2),
                    Text(
                    subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF666666),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: const Color(0xFF666666),
              ),
          ],
        ),
      ),
    );
  }

  void _handlePaystackPayment(BuildContext context, String paymentMethod) {
    // Call the payment method selected callback
    onPaymentMethodSelected(paymentMethod);
    
    // Navigate to Paystack payment screen
    Navigator.pushNamed(
      context,
      '/paystack-payment',
      arguments: {
        'bookingId': bookingId,
        'companyId': companyId,
        'userId': userId,
        'amount': amount,
        'currency': currency,
        'email': email,
        'preferredPaymentMethod': paymentMethod,
      },
    );
  }
}
