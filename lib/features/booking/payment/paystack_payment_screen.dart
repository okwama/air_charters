import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// Paystack handled server-side - no client SDK needed
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/loading_system.dart';

class PaystackPaymentScreen extends StatefulWidget {
  final String bookingId;
  final double amount;
  final String currency;
  final String email;
  final int companyId;
  final String preferredPaymentMethod;

  const PaystackPaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.email,
    required this.companyId,
    required this.preferredPaymentMethod,
  });

  @override
  State<PaystackPaymentScreen> createState() => _PaystackPaymentScreenState();
}

class _PaystackPaymentScreenState extends State<PaystackPaymentScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _authorizationUrl;
  String? _reference;
  String? _accessCode;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final bookingProvider = context.read<BookingProvider>();
      final authProvider = context.read<AuthProvider>();

      // Create Paystack payment intent
      final paymentData = await bookingProvider.createPaystackPaymentIntent(
        amount: widget.amount,
        bookingId: widget.bookingId,
        userId: authProvider.currentUser?.id ?? '',
        companyId: widget.companyId,
        email: widget.email,
        currency: widget.currency,
        description: 'Payment for booking ${widget.bookingId}',
        preferredPaymentMethod: widget.preferredPaymentMethod,
      );

      if (paymentData != null) {
        setState(() {
          _authorizationUrl = paymentData['authorization_url'];
          _reference = paymentData['reference'];
          _accessCode = paymentData['access_code'];
          _isLoading = false;
        });

        // Process payment based on method
        if (widget.preferredPaymentMethod == 'card') {
          _processCardPayment();
        } else if (widget.preferredPaymentMethod == 'mpesa') {
          _processMpesaPayment();
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to initialize payment';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Payment initialization failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _processCardPayment() async {
    if (_accessCode == null) {
      setState(() {
        _errorMessage = 'Payment access code not available';
      });
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
        _errorMessage = null;
      });

      // Process payment through backend API
      final result = await _processPaymentThroughBackend();
      print('Payment result: $result');
      if (result['status'] == true) {
        print('Payment successful');
        // Payment successful - verify with backend
        await _verifyPayment();
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Payment failed';
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Card payment failed: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  Future<void> _processMpesaPayment() async {
    if (_authorizationUrl == null) {
      setState(() {
        _errorMessage = 'M-Pesa authorization URL not available';
      });
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
        _errorMessage = null;
      });

      // For M-Pesa, we'll show a dialog with instructions
      // In a real implementation, you might want to use a web view
      _showMpesaInstructions();
    } catch (e) {
      setState(() {
        _errorMessage = 'M-Pesa payment failed: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  Future<void> _verifyPayment() async {
    if (_reference == null) return;

    try {
      final bookingProvider = context.read<BookingProvider>();
      
      final verificationResult = await bookingProvider.verifyPaystackPayment(
        reference: _reference!,
        bookingId: widget.bookingId,
      );

      if (verificationResult != null && verificationResult['success'] == true) {
        // Payment verified successfully
        if (mounted) {
          Navigator.of(context).pop({
            'success': true,
            'reference': _reference,
            'message': 'Payment completed successfully',
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Payment verification failed';
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Payment verification failed: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  void _showMpesaInstructions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'M-Pesa Payment',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You will receive an M-Pesa STK Push notification on your phone.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Steps:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '1. Check your phone for the M-Pesa notification\n'
              '2. Enter your M-Pesa PIN when prompted\n'
              '3. Wait for payment confirmation\n'
              '4. Return to this screen',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkPaymentStatus();
            },
            child: Text(
              'I\'ve completed payment',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0EA5E9),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isProcessing = false;
              });
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkPaymentStatus() async {
    // Poll for payment status
    int attempts = 0;
    const maxAttempts = 30; // 30 seconds max

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 1));
      
      try {
        final bookingProvider = context.read<BookingProvider>();
        final verificationResult = await bookingProvider.verifyPaystackPayment(
          reference: _reference!,
          bookingId: widget.bookingId,
        );

        if (verificationResult != null && verificationResult['success'] == true) {
          // Payment successful
          if (mounted) {
            Navigator.of(context).pop({
              'success': true,
              'reference': _reference,
              'message': 'Payment completed successfully',
            });
          }
          return;
        }
      } catch (e) {
        // Continue polling
      }
      
      attempts++;
    }

    // Timeout
    setState(() {
      _errorMessage = 'Payment verification timeout. Please check your payment status.';
      _isProcessing = false;
    });
  }

  // Process payment through backend API
  Future<Map<String, dynamic>> _processPaymentThroughBackend() async {
    try {
      // Call your backend API to process the payment
      // This should return payment status and details
      final response = await Future.delayed(Duration(seconds: 2), () {
        // Simulate API call - replace with actual backend call
        return {
          'status': true,
          'message': 'Payment processed successfully',
          'transaction_id': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        };
      });
      
      return response;
    } catch (e) {
      return {
        'status': false,
        'message': 'Payment failed: ${e.toString()}',
      };
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Payment',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildPaymentState(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingSystem.inline(size: 40),
          const SizedBox(height: 20),
          Text(
            'Initializing payment...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Error',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                });
                _initializePayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Summary',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking ID:',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    Text(
                      widget.bookingId,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount:',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    Text(
                      '${widget.currency} ${widget.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Method:',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    Text(
                      widget.preferredPaymentMethod == 'card' ? 'Card Payment' : 'M-Pesa',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Payment Status
          if (_isProcessing) ...[
            Center(
              child: Column(
                children: [
                  LoadingSystem.inline(size: 40),
                  const SizedBox(height: 16),
                  Text(
                    widget.preferredPaymentMethod == 'card'
                        ? 'Processing card payment...'
                        : 'Processing M-Pesa payment...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.payment,
                    size: 64,
                    color: Color(0xFF0EA5E9),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Ready',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.preferredPaymentMethod == 'card'
                        ? 'Your card payment will be processed securely'
                        : 'M-Pesa payment instructions will be shown',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Action Buttons
          if (!_isProcessing) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.preferredPaymentMethod == 'card') {
                    _processCardPayment();
                  } else {
                    _processMpesaPayment();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.preferredPaymentMethod == 'card'
                      ? 'Pay with Card'
                      : 'Pay with M-Pesa',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

