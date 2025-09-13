import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/paystack_service.dart';

class PaystackPaymentWidget extends StatefulWidget {
  final double amount;
  final String currency;
  final String email;
  final String bookingId;
  final int companyId;
  final String userId;
  final String? description;
  final Map<String, dynamic>? metadata;
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;
  final VoidCallback? onCancel;

  const PaystackPaymentWidget({
    super.key,
    required this.amount,
    required this.currency,
    required this.email,
    required this.bookingId,
    required this.companyId,
    required this.userId,
    this.description,
    this.metadata,
    this.onSuccess,
    this.onFailure,
    this.onCancel, required Function(PaystackResponse p1) onPaymentSuccess, required VoidCallback onPaymentCancelled, String? preferredPaymentMethod, required Function(String p1) onPaymentError,
  });

  @override
  State<PaystackPaymentWidget> createState() => _PaystackPaymentWidgetState();
}

class _PaystackPaymentWidgetState extends State<PaystackPaymentWidget> {
  final PaystackService _paystackService = PaystackService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payment,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paystack Payment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Secure payment processing',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Payment Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Amount:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _paystackService.formatAmount(widget.amount, widget.currency),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Currency:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      widget.currency.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Email:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Error Message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Payment Buttons
          Row(
            children: [
              // Card Payment Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _processCardPayment,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.credit_card, size: 18),
                  label: Text(_isLoading ? 'Processing...' : 'Pay with Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // M-Pesa Payment Button (if currency is KES)
              if (widget.currency.toUpperCase() == 'KES')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _processMpesaPayment,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.phone_android, size: 18),
                    label: Text(_isLoading ? 'Processing...' : 'Pay with M-Pesa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Cancel Button
          TextButton(
            onPressed: _isLoading ? null : widget.onCancel,
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Security Notice
          Row(
            children: [
              Icon(
                Icons.security,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your payment is secured by Paystack',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _processCardPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _paystackService.processCardPayment(
        amount: widget.amount,
        currency: widget.currency,
        email: widget.email,
        bookingId: widget.bookingId,
        companyId: widget.companyId,
        userId: widget.userId,
        description: widget.description,
        metadata: widget.metadata,
      );

      if (response.isSuccess) {
        // Verify payment with backend
        final verification = await _paystackService.verifyPayment(response.reference!);
        
        if (verification['status'] == 'succeeded') {
          Get.snackbar(
            'Success',
            'Payment completed successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          widget.onSuccess?.call();
        } else {
          throw Exception('Payment verification failed');
        }
      } else if (response.isCancelled) {
        Get.snackbar(
          'Cancelled',
          'Payment was cancelled',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        widget.onCancel?.call();
      } else {
        throw Exception(response.message ?? 'Payment failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      Get.snackbar(
        'Error',
        'Payment failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      widget.onFailure?.call();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processMpesaPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // For M-Pesa, we need a phone number
      // You might want to show a dialog to get the phone number
      final phoneNumber = await _getPhoneNumber();
      if (phoneNumber == null) return;

      final response = await _paystackService.processMpesaPayment(
        amount: widget.amount,
        currency: widget.currency,
        email: widget.email,
        phoneNumber: phoneNumber,
        bookingId: widget.bookingId,
        companyId: widget.companyId,
        userId: widget.userId,
        description: widget.description,
        metadata: widget.metadata,
      );

      if (response.isSuccess) {
        // Verify payment with backend
        final verification = await _paystackService.verifyPayment(response.reference!);
        
        if (verification['status'] == 'succeeded') {
          Get.snackbar(
            'Success',
            'M-Pesa payment completed successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          widget.onSuccess?.call();
        } else {
          throw Exception('Payment verification failed');
        }
      } else if (response.isCancelled) {
        Get.snackbar(
          'Cancelled',
          'M-Pesa payment was cancelled',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        widget.onCancel?.call();
      } else {
        throw Exception(response.message ?? 'M-Pesa payment failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      Get.snackbar(
        'Error',
        'M-Pesa payment failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      widget.onFailure?.call();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _getPhoneNumber() async {
    String? phoneNumber;
    
    await Get.dialog(
      AlertDialog(
        title: const Text('Enter Phone Number'),
        content: TextField(
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'e.g., +254712345678',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => phoneNumber = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    
    return phoneNumber;
  }
}
