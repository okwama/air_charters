import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/saved_card_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_system.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final String? clientSecret;
  final double amount;
  final String currency;
  final String? paymentIntentId;
  final SavedCardModel? savedCard;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    this.clientSecret,
    required this.amount,
    this.currency = 'USD',
    this.paymentIntentId,
    this.savedCard,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final CardFormEditController _cardController = CardFormEditController();
  bool _isProcessing = false;
  String? _errorMessage;
  bool _isCardFormComplete = false;

  @override
  void initState() {
    super.initState();
    _cardController.addListener(_onCardFormChanged);
    _prefillCardData();
  }

  @override
  void dispose() {
    _cardController.removeListener(_onCardFormChanged);
    _cardController.dispose();
    super.dispose();
  }

  void _onCardFormChanged() {
    setState(() {
      _isCardFormComplete = _cardController.details.complete;
    });
  }

  void _prefillCardData() {
    if (widget.savedCard != null) {
      print('=== SAVED CARD DETECTED ===');
      print('Card type: ${widget.savedCard!.cardType}');
      print('Cardholder: ${widget.savedCard!.cardholderName}');
      print('Expiry: ${widget.savedCard!.expiryDisplay}');
    }
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

    // Prevent multiple payment attempts
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final bookingProvider = context.read<BookingProvider>();
      final authProvider = context.read<AuthProvider>();

      print('=== PAYMENT PROCESSING STARTED ===');
      print('Client secret: ${widget.clientSecret!.substring(0, 20)}...');
      print('Payment intent ID: ${widget.paymentIntentId}');
      print('User name: ${authProvider.currentUser?.fullName}');
      print('User email: ${authProvider.currentUser?.email}');

      PaymentMethodParams paymentParams;

      if (widget.savedCard != null) {
        print('=== USING SAVED CARD DATA ===');
        paymentParams = PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: widget.savedCard!.cardholderName,
              email: authProvider.currentUser?.email ?? 'test@example.com',
            ),
          ),
        );
      } else {
        print('=== USING FORM DATA ===');
        paymentParams = PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: authProvider.currentUser?.fullName ?? 'Test User',
              email: authProvider.currentUser?.email ?? 'test@example.com',
            ),
          ),
        );
      }

      final paymentResult = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: widget.clientSecret!,
        data: paymentParams,
      );

      print('=== PAYMENT RESULT RECEIVED ===');
      print('Payment status: ${paymentResult.status}');
      print('Payment ID: ${paymentResult.id}');
      print('Payment method ID: ${paymentResult.paymentMethodId}');
      print('Payment result type: ${paymentResult.runtimeType}');
      print('Payment result toString: ${paymentResult.toString()}');

      if (paymentResult.status == PaymentIntentsStatus.Succeeded) {
        print('=== PAYMENT SUCCEEDED - COMPLETING BOOKING ===');

        // Extract payment intent ID from client secret
        final clientSecret = widget.clientSecret!;
        final paymentIntentId = clientSecret.split('_secret_')[0];

        print('Client secret: $clientSecret');
        print('Extracted payment intent ID: $paymentIntentId');
        print('Using payment method ID: ${paymentResult.paymentMethodId}');

        // Use unified payment system instead of legacy completion
        final unifiedResult = await bookingProvider.processUnifiedPayment(
          widget.bookingId,
          paymentIntentId,
          paymentMethodId: paymentResult.paymentMethodId,
        );

        if (unifiedResult != null) {
          print('=== UNIFIED PAYMENT COMPLETED SUCCESSFULLY ===');
          print('Transaction ID: ${unifiedResult.transactionId}');
          print('Payment Provider: ${unifiedResult.paymentProvider}');
          print('Company: ${unifiedResult.companyName}');
          print('Total Amount: ${unifiedResult.totalAmount}');
          print('Platform Fee: ${unifiedResult.platformFee}');
          print('Company Amount: ${unifiedResult.companyAmount}');
          print('Ledger Entries: ${unifiedResult.ledgerEntries.length}');

          if (mounted) {
            _showSuccessDialog();
          }
        } else {
          print('=== UNIFIED PAYMENT FAILED ===');
          print('Error message: ${bookingProvider.errorMessage}');
          setState(() {
            _errorMessage = bookingProvider.errorMessage ?? 'Payment failed';
          });
        }
      } else {
        print('=== PAYMENT NOT SUCCESSFUL ===');
        print('Payment status: ${paymentResult.status}');
        setState(() {
          _errorMessage =
              'Payment was not successful. Status: ${paymentResult.status}';
        });
      }
    } catch (e) {
      print('=== PAYMENT ERROR ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');

      // Handle specific Stripe errors
      String errorMessage = 'Payment error occurred';
      if (e.toString().contains('payment_intent_unexpected_state')) {
        errorMessage =
            'Payment has already been processed. Please check your booking status.';
      } else if (e.toString().contains('card_declined')) {
        errorMessage = 'Your card was declined. Please try a different card.';
      } else if (e.toString().contains('insufficient_funds')) {
        errorMessage =
            'Insufficient funds. Please try a different payment method.';
      } else {
        errorMessage = 'Payment error: ${e.toString()}';
      }

      setState(() {
        _errorMessage = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your booking has been confirmed and payment completed successfully.',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF666666),
                  height: 1.4,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 900;
    final padding = isDesktop
        ? 32.0
        : isTablet
            ? 24.0
            : 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isProcessing
          ? LoadingSystem.payment(
              message: 'Processing your payment securely...',
              showSecurityBadge: true,
            )
          : Consumer<BookingProvider>(
              builder: (context, bookingProvider, child) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 600 : double.infinity,
                      ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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

                          // Saved Card Information (if available)
                          if (widget.savedCard != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Using saved card',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        Text(
                                          '${widget.savedCard!.cardTypeDisplay} •••• ${widget.savedCard!.cardNumber.substring(widget.savedCard!.cardNumber.length - 4)}',
                                          style: TextStyle(
                                            color: Colors.green.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        // Clear saved card logic here
                                      });
                                    },
                                    child: Text(
                                      'Change',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Card Form - FIXED VERSION
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.credit_card,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Card Details',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Debug info for development
                                if (kDebugMode)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow.shade50,
                                      border: Border.all(
                                          color: Colors.yellow.shade200),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Card form complete: $_isCardFormComplete',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700),
                                    ),
                                  ),

                                // FIXED CARD FORM WITH BETTER STYLING
                                Container(
                                  constraints: const BoxConstraints(
                                    minHeight:
                                        120, // Minimum height for better visibility
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white, // White background
                                    border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1.5),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CardFormField(
                                    controller: _cardController,
                                    style: CardFormStyle(
                                      fontSize: 18, // Larger font size
                                      textColor:
                                          Colors.black, // Pure black text
                                      placeholderColor: Colors
                                          .black, // Black placeholder color
                                      borderColor: Colors
                                          .transparent, // Remove internal borders
                                      backgroundColor: Colors
                                          .transparent, // Transparent background
                                      cursorColor: Colors.black, // Black cursor
                                      textErrorColor: Colors.red.shade700,
                                      borderRadius:
                                          0, // No border radius conflicts
                                      borderWidth:
                                          0, // No border width conflicts
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Status indicator
                                Row(
                                  children: [
                                    Icon(
                                      _isCardFormComplete
                                          ? Icons.check_circle
                                          : Icons.credit_card,
                                      size: 16,
                                      color: _isCardFormComplete
                                          ? Colors.green
                                          : Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isCardFormComplete
                                          ? 'Card details are complete'
                                          : 'Enter your card details above',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _isCardFormComplete
                                            ? Colors.green.shade700
                                            : Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Error Message
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.error_outline,
                                      color: Colors.red[600],
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Payment Error',
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red[600],
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Test Card Information (for development)
                          if (kDebugMode)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.orange.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: Colors.orange.shade600,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Test Card Information',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Card: 4242 4242 4242 4242\nExpiry: Any future date (e.g., 12/25)\nCVC: Any 3 digits (e.g., 123)\nZIP: Any 5 digits (e.g., 12345)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                      fontFamily: 'Consolas',
                                    ),
                                  ),
                                ],
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
                    ),
                  ),
                );
              },
            ),
    );
  }
}
