import 'dart:convert';
import 'package:http/http.dart' as http;
// Paystack handled server-side - no client SDK needed
import '../../config/env/app_config.dart';
import '../../shared/utils/currency_utils.dart';
import '../../shared/utils/session_manager.dart';
import '../error/network_error_handler.dart';
import '../logging/app_logger.dart';

class PaystackService {
  static final PaystackService _instance = PaystackService._internal();
  factory PaystackService() => _instance;
  PaystackService._internal();

  // Paystack is handled server-side - no client initialization needed

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
          'Authorization':
              await SessionManager().getAuthorizationHeader() ?? '',
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
      AppLogger().log(
        'Payment initialization failed',
        level: LogLevel.error,
        category: LogCategory.payment,
        error: e,
      );
      final errorResult = NetworkErrorResult.fromException(e);
      throw Exception('Payment initialization failed: ${errorResult.message}');
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

      // Verify payment was initialized successfully
      if (paymentData['reference'] != null &&
          paymentData['authorization_url'] != null) {
        return PaystackResponse(
          status: 'success',
          reference: paymentData['reference'],
          message: 'Payment initialized successfully',
          data: paymentData,
        );
      } else {
        throw Exception('Invalid payment initialization response');
      }
    } catch (e) {
      AppLogger().log(
        'Card payment failed',
        level: LogLevel.error,
        category: LogCategory.payment,
        error: e,
      );
      final errorResult = NetworkErrorResult.fromException(e);
      return PaystackResponse(
        status: 'failed',
        message: errorResult.message,
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
      AppLogger().log(
        'M-Pesa payment failed',
        level: LogLevel.error,
        category: LogCategory.payment,
        error: e,
      );
      final errorResult = NetworkErrorResult.fromException(e);
      return PaystackResponse(
        status: 'failed',
        message: errorResult.message,
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
          'Authorization':
              await SessionManager().getAuthorizationHeader() ?? '',
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
      AppLogger().log(
        'Payment verification failed',
        level: LogLevel.error,
        category: LogCategory.payment,
        error: e,
      );
      final errorResult = NetworkErrorResult.fromException(e);
      throw Exception('Payment verification failed: ${errorResult.message}');
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

  /// Format amount for display using centralized utility
  String formatAmount(double amount, String currency) {
    return CurrencyUtils.formatAmount(amount, currency);
  }

  /// Get currency symbol using centralized utility
  String getCurrencySymbol(String currency) {
    return CurrencyUtils.getCurrencySymbol(currency);
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
