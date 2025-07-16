import '../models/payment_model.dart';
import '../network/api_client.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<PaymentModel> createPayment({
    required String bookingId,
    required PaymentMethod paymentMethod,
    required double totalAmount,
    required double platformFee,
    String currency = 'USD',
    String? transactionId,
    Map<String, dynamic>? paymentGatewayResponse,
  }) async {
    try {
      final response =
          await _apiClient.post('/api/payments', {
        'bookingId': bookingId,
        'paymentMethod': paymentMethod.name,
        'totalAmount': totalAmount,
        'platformFee': platformFee,
        'currency': currency,
        if (transactionId != null) 'transactionId': transactionId,
        if (paymentGatewayResponse != null)
          'paymentGatewayResponse': paymentGatewayResponse,
      });

      if (response['success'] == true && response['data'] != null) {
        return PaymentModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to create payment');
      }
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }

  Future<List<PaymentModel>> getUserPayments() async {
    try {
      final response = await _apiClient.get('/api/payments');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> paymentData = response['data'];
        return paymentData.map((json) => PaymentModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch payments');
      }
    } catch (e) {
      throw Exception('Error fetching user payments: $e');
    }
  }

  Future<List<PaymentModel>> getBookingPayments(String bookingId) async {
    try {
      final response = await _apiClient.get('/api/payments/booking/$bookingId');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> paymentData = response['data'];
        return paymentData.map((json) => PaymentModel.fromJson(json)).toList();
      } else {
        throw Exception(
            response['message'] ?? 'Failed to fetch booking payments');
      }
    } catch (e) {
      throw Exception('Error fetching booking payments: $e');
    }
  }

  Future<PaymentModel> getPayment(String paymentId) async {
    try {
      final response = await _apiClient.get('/api/payments/$paymentId');

      if (response['success'] == true && response['data'] != null) {
        return PaymentModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Payment not found');
      }
    } catch (e) {
      throw Exception('Error fetching payment: $e');
    }
  }

  Future<PaymentModel> updatePaymentStatus(
    String paymentId,
    PaymentStatus status, {
    String? transactionId,
  }) async {
    try {
      final response = await _apiClient.put('/api/payments/$paymentId/status', {
        'status': status.name,
        if (transactionId != null) 'transactionId': transactionId,
      });

      if (response['success'] == true && response['data'] != null) {
        return PaymentModel.fromJson(response['data']);
      } else {
        throw Exception(
            response['message'] ?? 'Failed to update payment status');
      }
    } catch (e) {
      throw Exception('Error updating payment status: $e');
    }
  }

  Future<PaymentModel> updateGatewayResponse(
    String paymentId,
    Map<String, dynamic> gatewayResponse,
  ) async {
    try {
      final response = await _apiClient.put(
        '/api/payments/$paymentId/gateway-response',
        gatewayResponse,
      );

      if (response['success'] == true && response['data'] != null) {
        return PaymentModel.fromJson(response['data']);
      } else {
        throw Exception(
            response['message'] ?? 'Failed to update gateway response');
      }
    } catch (e) {
      throw Exception('Error updating gateway response: $e');
    }
  }

  Future<PaymentModel> refundPayment(String paymentId) async {
    try {
      final response =
          await _apiClient.put('/api/payments/$paymentId/refund', {});

      if (response['success'] == true && response['data'] != null) {
        return PaymentModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to process refund');
      }
    } catch (e) {
      throw Exception('Error processing refund: $e');
    }
  }

  Future<Map<String, dynamic>> getPaymentStats({int? companyId}) async {
    try {
      final queryParams = companyId != null ? '?companyId=$companyId' : '';
      final response = await _apiClient.get('/api/payments/stats$queryParams');

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch payment stats');
      }
    } catch (e) {
      throw Exception('Error fetching payment stats: $e');
    }
  }
}
