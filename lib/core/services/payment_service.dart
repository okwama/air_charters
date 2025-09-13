import 'package:air_charters/core/network/api_client.dart';
import 'package:air_charters/config/env/app_config.dart';

enum PaymentMethod {
  mpesa,
  card,
  bankTransfer,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  /// Initiate M-Pesa payment
  Future<Map<String, dynamic>> initiateMpesaPayment({
    required String bookingId,
    required double amount,
    required String phoneNumber,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.mpesaStkPushEndpoint,
        {
          'bookingId': bookingId,
          'amount': amount,
          'phoneNumber': phoneNumber,
          'description': description ?? 'Experience booking payment',
        },
      );

      if (response['success']) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        throw Exception(
            'Failed to initiate M-Pesa payment: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(
      String paymentIntentId) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.paymentStatusEndpoint}/$paymentIntentId',
      );

      if (response['success']) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        throw Exception(
            'Failed to check payment status: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Confirm payment
  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    String? paymentMethodId,
  }) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.paymentConfirmEndpoint}/$paymentIntentId/confirm',
        {
          'paymentMethodId': paymentMethodId,
        },
      );

      if (response['success']) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        throw Exception('Failed to confirm payment: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get(AppConfig.paymentMethodsEndpoint);

      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception(
            'Failed to load payment methods: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Create payment intent
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String bookingId,
    required PaymentMethod paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.paymentIntentEndpoint,
        {
          'amount': amount,
          'currency': currency,
          'bookingId': bookingId,
          'paymentMethod': paymentMethod.name,
          'metadata': metadata,
        },
      );

      if (response['success']) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        throw Exception(
            'Failed to create payment intent: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Refund payment
  Future<Map<String, dynamic>> refundPayment({
    required String paymentIntentId,
    double? amount,
    String? reason,
  }) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.paymentRefundEndpoint}/$paymentIntentId/refund',
        {
          'amount': amount,
          'reason': reason,
        },
      );

      if (response['success']) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        throw Exception('Failed to refund payment: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory({
    int? limit,
    int? offset,
    PaymentStatus? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (status != null) queryParams['status'] = status.name;

      String endpoint = AppConfig.paymentHistoryEndpoint;
      if (limit != null || offset != null || status != null) {
        final params = <String>[];
        if (limit != null) params.add('limit=$limit');
        if (offset != null) params.add('offset=$offset');
        if (status != null) params.add('status=${status.name}');
        endpoint += '?${params.join('&')}';
      }

      final response = await _apiClient.get(endpoint);

      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception(
            'Failed to load payment history: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
