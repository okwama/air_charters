import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/payment_models.dart';
import '../../../shared/widgets/app_spinner.dart';
import '../../../shared/widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final String? clientSecret;
  final double amount;
  final String currency;
  final String? paymentIntentId;

  const PaymentScreen({
    Key? key,
    required this.bookingId,
    this.clientSecret,
    required this.amount,
    this.currency = 'USD',
    this.paymentIntentId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final CardFormEditController _cardController = CardFormEditController();
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (widget.clientSecret == null) {
      setState(() {
        _errorMessage = 'Payment configuration is not available';
      });
      return;
    }

    if (!_cardController.details.complete) {
      setState(() {
        _errorMessage = 'Please complete all card details';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final bookingProvider = context.read<BookingProvider>();
      final authProvider = context.read<AuthProvider>();

      // Confirm payment with Stripe
      final paymentResult = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: widget.clientSecret!,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: authProvider.currentUser?.fullName,
              email: authProvider.currentUser?.email,
            ),
          ),
        ),
      );

      if (paymentResult.status == PaymentIntentsStatus.Succeeded) {
        // Complete booking payment with backend
        final success = await bookingProvider.completePayment(
          widget.bookingId,
          widget.paymentIntentId ?? paymentResult.id,
          paymentMethodId: paymentResult.paymentMethodId,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment completed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return success
          }
        } else {
          setState(() {
            _errorMessage = bookingProvider.errorMessage ?? 'Payment failed';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Payment was not successful';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Payment error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Payment Summary
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
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
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Amount:'),
                            Text(
                              '\$${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Card Form
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Card Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CardFormField(
                          controller: _cardController,
                          style: CardFormStyle(
                            fontSize: 16,
                            textColor: Colors.black,
                            placeholderColor: Colors.grey,
                            borderColor: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),

                const SizedBox(height: 24),

                // Process Payment Button
                CustomButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  text: _isProcessing ? 'Processing...' : 'Pay Now',
                  isLoading: _isProcessing,
                ),

                const SizedBox(height: 16),

                // Security Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security,
                          color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your payment is secured by Stripe. We never store your card details.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
