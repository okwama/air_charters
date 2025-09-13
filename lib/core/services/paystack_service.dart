import 'dart:convert';
import 'package:http/http.dart' as http;
// Paystack handled server-side - no client SDK needed
import '../../config/env/app_config.dart';

class PaystackService {
  static final PaystackService _instance = PaystackService._internal();
  factory PaystackService() => _instance;
  PaystackService._internal();

  // Paystack is handled server-side - no client initialization needed

  /// Get Paystack public key from backend
  Future<String> _getPublicKeyFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/payments/paystack/info'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.authToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']['publicKey'];
        } else {
          throw Exception(data['message'] ?? 'Failed to get public key');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error getting public key: $e');
      rethrow;
    }
  }

  /// Initialize a payment with the backend
  Future<Map<String, dynamic>> initializePayment({
    required double amount,
    required String currency,
    required String email,
    required String bookingId,
    required int companyId,
    required String userId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/payments/paystack/initialize'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.authToken}',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'email': email,
          'bookingId': bookingId,
          'companyId': companyId,
          'userId': userId,
          'description': description ?? 'Payment for booking $bookingId',
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Payment initialization failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Payment initialization error: $e');
      rethrow;
    }
  }

  /// Process card payment using Paystack
  Future<PaystackResponse> processCardPayment({
    required double amount,
    required String currency,
    required String email,
    required String bookingId,
    required int companyId,
    required String userId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Initialize payment with backend
      final paymentData = await initializePayment(
        amount: amount,
        currency: currency,
        email: email,
        bookingId: bookingId,
        companyId: companyId,
        userId: userId,
        description: description,
        metadata: metadata,
      );

      // Return success response with payment data
      return PaystackResponse(
        status: 'success',
        reference: paymentData['reference'],
        message: 'Payment initialized successfully',
        data: paymentData,
      );
    } catch (e) {
      print('Card payment error: $e');
      return PaystackResponse(
        status: 'failed',
        message: e.toString(),
      );
    }
  }

  /// Process M-Pesa payment using Paystack
  Future<PaystackResponse> processMpesaPayment({
    required double amount,
    required String currency,
    required String email,
    required String phoneNumber,
    required String bookingId,
    required int companyId,
    required String userId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Initialize payment with backend (M-Pesa specific)
      final paymentData = await initializePayment(
        amount: amount,
        currency: currency,
        email: email,
        bookingId: bookingId,
        companyId: companyId,
        userId: userId,
        description: description,
        metadata: {
          ...metadata ?? {},
          'phoneNumber': phoneNumber,
          'paymentMethod': 'mpesa',
        },
      );

      // Return success response with payment data
      return PaystackResponse(
        status: 'success',
        reference: paymentData['reference'],
        message: 'M-Pesa payment initialized successfully',
        data: paymentData,
      );
    } catch (e) {
      print('M-Pesa payment error: $e');
      return PaystackResponse(
        status: 'failed',
        message: e.toString(),
      );
    }
  }

  /// Verify payment status with backend
  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/api/payments/paystack/verify/$reference'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.authToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Payment verification failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Payment verification error: $e');
      rethrow;
    }
  }

  /// Get supported currencies
  List<String> getSupportedCurrencies() {
    return ['NGN', 'GHS', 'ZAR', 'KES', 'USD'];
  }

  /// Get supported payment methods
  List<String> getSupportedPaymentMethods() {
    return ['card', 'bank_transfer', 'ussd', 'qr', 'mobile_money'];
  }

  /// Check if currency is supported
  bool isCurrencySupported(String currency) {
    return getSupportedCurrencies().contains(currency.toUpperCase());
  }

  /// Check if payment method is supported
  bool isPaymentMethodSupported(String method) {
    return getSupportedPaymentMethods().contains(method.toLowerCase());
  }

  /// Format amount for display
  String formatAmount(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'NGN':
        return '₦${amount.toStringAsFixed(2)}';
      case 'GHS':
        return 'GH₵${amount.toStringAsFixed(2)}';
      case 'ZAR':
        return 'R${amount.toStringAsFixed(2)}';
      case 'KES':
        return 'KSh${amount.toStringAsFixed(2)}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      default:
        return '$currency ${amount.toStringAsFixed(2)}';
    }
  }

  /// Get currency symbol
  String getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'GHS':
        return 'GH₵';
      case 'ZAR':
        return 'R';
      case 'KES':
        return 'KSh';
      case 'USD':
        return '\$';
      default:
        return currency;
    }
  }
}

/// Paystack response model
class PaystackResponse {
  final String status;
  final String? reference;
  final String? message;
  final Map<String, dynamic>? data;

  PaystackResponse({
    required this.status,
    this.reference,
    this.message,
    this.data,
  });

  bool get isSuccess => status == 'success';
  bool get isCancelled => status == 'cancelled';
  bool get isFailed => status == 'failed';

  factory PaystackResponse.fromJson(Map<String, dynamic> json) {
    return PaystackResponse(
      status: json['status'] ?? 'failed',
      reference: json['reference'],
      message: json['message'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'reference': reference,
      'message': message,
      'data': data,
    };
  }
}
