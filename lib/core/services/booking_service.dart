import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../models/payment_models.dart';
import '../error/app_exceptions.dart';
import '../network/api_client.dart';

class BookingService {
  final ApiClient _apiClient = ApiClient();

  /// Create a new booking with payment intent for seamless Stripe integration
  Future<BookingWithPaymentIntent> createBookingWithPaymentIntent(
      BookingModel booking) async {
    try {
      final response = await _apiClient.post(
        '/api/bookings',
        booking.toCreateJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        return BookingWithPaymentIntent.fromJson(response['data']);
      }

      throw ServerException('Failed to create booking with payment intent');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to create booking: ${e.toString()}');
    }
  }

  /// Process payment for a booking and populate points/reference (unified payment flow)
  Future<BookingModel> processPayment(
      String bookingId, String transactionId, String paymentMethod) async {
    try {
      final response = await _apiClient.post(
        '/api/bookings/$bookingId/process-payment',
        {
          'paymentTransactionId': transactionId,
          'paymentMethod': paymentMethod,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Failed to process payment');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to process payment: ${e.toString()}');
    }
  }

  /// Create a new booking with passengers (legacy method - kept for backward compatibility)
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final response = await _apiClient.post(
        '/api/bookings',
        booking.toCreateJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Failed to create booking');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to create booking: ${e.toString()}');
    }
  }

  /// Get all bookings for the current user
  Future<List<BookingModel>> fetchUserBookings() async {
    try {
      final response = await _apiClient.get('/api/bookings');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> bookingsJson = response['data'] as List;
        return bookingsJson.map((json) => BookingModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw NetworkException('Failed to fetch bookings: ${e.toString()}');
    }
  }

  /// Get a specific booking by ID
  Future<BookingModel> fetchBookingById(String bookingId) async {
    try {
      final response = await _apiClient.get('/api/bookings/$bookingId');

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Booking not found');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to fetch booking: ${e.toString()}');
    }
  }

  /// Get a booking by reference number
  Future<BookingModel> fetchBookingByReference(String reference) async {
    try {
      final response =
          await _apiClient.get('/api/bookings/reference/$reference');

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Booking not found');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to fetch booking: ${e.toString()}');
    }
  }

  /// Get booking status by reference number (public endpoint)
  Future<BookingStatusResponse> getBookingStatusByReference(
      String reference) async {
    try {
      final response = await _apiClient.get('/api/bookings/status/$reference');

      if (response['success'] == true && response['data'] != null) {
        return BookingStatusResponse.fromJson(response['data']);
      }

      throw ServerException('Booking not found');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to fetch booking status: ${e.toString()}');
    }
  }

  /// Cancel a booking
  Future<BookingModel> cancelBooking(String bookingId) async {
    try {
      final response =
          await _apiClient.put('/api/bookings/$bookingId/cancel', {});

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Failed to cancel booking');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to cancel booking: ${e.toString()}');
    }
  }

  /// Update booking status (admin/system use)
  Future<BookingModel> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    try {
      final response = await _apiClient.put('/api/bookings/$bookingId/status', {
        'status': status.name,
      });

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Failed to update booking status');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
          'Failed to update booking status: ${e.toString()}');
    }
  }

  /// Update payment status (legacy method - kept for backward compatibility)
  Future<BookingModel> updatePaymentStatus(
      String bookingId, PaymentStatus status) async {
    try {
      final response =
          await _apiClient.put('/api/bookings/$bookingId/payment-status', {
        'paymentStatus': status.name,
      });

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Failed to update payment status');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
          'Failed to update payment status: ${e.toString()}');
    }
  }

  /// Update loyalty points and wallet amount used for a booking
  Future<BookingModel> updateLoyaltyAndWallet(
    String bookingId, {
    int loyaltyPointsRedeemed = 0,
    double walletAmountUsed = 0,
  }) async {
    try {
      final response = await _apiClient.put(
        '/api/bookings/$bookingId/loyalty-wallet',
        {
          'loyaltyPointsRedeemed': loyaltyPointsRedeemed,
          'walletAmountUsed': walletAmountUsed,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Failed to update loyalty and wallet');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
          'Failed to update loyalty and wallet: ${e.toString()}');
    }
  }

  /// Get booking summary with loyalty and wallet information
  Future<BookingSummary> getBookingSummary(String bookingId) async {
    try {
      final response = await _apiClient.get('/api/bookings/$bookingId/summary');

      if (response['success'] == true && response['data'] != null) {
        return BookingSummary.fromJson(response['data']);
      }

      throw ServerException('Failed to fetch booking summary');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
          'Failed to fetch booking summary: ${e.toString()}');
    }
  }

  /// Get booking timeline
  Future<List<BookingTimelineEvent>> getBookingTimeline(
      String bookingId) async {
    try {
      final response =
          await _apiClient.get('/api/bookings/$bookingId/timeline');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> timelineJson = response['data'] as List;
        return timelineJson
            .map((json) => BookingTimelineEvent.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw NetworkException(
          'Failed to fetch booking timeline: ${e.toString()}');
    }
  }

  /// Get booking statistics
  Future<Map<String, int>> fetchBookingStats() async {
    try {
      final response = await _apiClient.get('/api/bookings/stats');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return {
          'total': data['total'] as int? ?? 0,
          'pending': data['pending'] as int? ?? 0,
          'confirmed': data['confirmed'] as int? ?? 0,
          'cancelled': data['cancelled'] as int? ?? 0,
          'completed': data['completed'] as int? ?? 0,
        };
      }

      return {};
    } catch (e) {
      throw NetworkException(
          'Failed to fetch booking statistics: ${e.toString()}');
    }
  }

  /// Complete payment for a booking using the unified payment endpoint
  Future<BookingModel> completePayment(
    String bookingId,
    String paymentIntentId, {
    String? paymentMethodId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/bookings/$bookingId/pay',
        {
          'paymentIntentId': paymentIntentId,
          if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']['booking']);
      }

      throw ServerException('Failed to complete payment');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to complete payment: ${e.toString()}');
    }
  }

  /// Create payment intent separately (alternative flow)
  Future<PaymentIntentModel> createPaymentIntent({
    required double amount,
    required String bookingId,
    required String userId,
    String currency = 'USD',
    String description = '',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/payments/create-intent',
        {
          'amount': amount,
          'currency': currency,
          'bookingId': bookingId,
          'userId': userId,
          'description': description,
          if (metadata != null) 'metadata': metadata,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return PaymentIntentModel.fromJson(response['data']);
      }

      throw ServerException('Failed to create payment intent');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
          'Failed to create payment intent: ${e.toString()}');
    }
  }

  /// Get payment status
  Future<PaymentConfirmationModel> getPaymentStatus(
      String paymentIntentId) async {
    try {
      final response =
          await _apiClient.get('/api/payments/status/$paymentIntentId');

      if (response['success'] == true && response['data'] != null) {
        return PaymentConfirmationModel.fromJson(response['data']);
      }

      throw ServerException('Failed to get payment status');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to get payment status: ${e.toString()}');
    }
  }

  /// Confirm payment with Stripe
  Future<PaymentConfirmationModel> confirmPayment({
    required String paymentIntentId,
    String? paymentMethodId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/payments/confirm',
        {
          'paymentIntentId': paymentIntentId,
          if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return PaymentConfirmationModel.fromJson(response['data']);
      }

      throw ServerException('Failed to confirm payment');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to confirm payment: ${e.toString()}');
    }
  }
}

/// Model for booking with payment intent response
class BookingWithPaymentIntent {
  final BookingModel booking;
  final PaymentIntent? paymentIntent;
  final PaymentInstructions paymentInstructions;

  BookingWithPaymentIntent({
    required this.booking,
    this.paymentIntent,
    required this.paymentInstructions,
  });

  factory BookingWithPaymentIntent.fromJson(Map<String, dynamic> json) {
    return BookingWithPaymentIntent(
      booking: BookingModel.fromJson(json['booking']),
      paymentIntent: json['paymentIntent'] != null
          ? PaymentIntent.fromJson(json['paymentIntent'])
          : null,
      paymentInstructions:
          PaymentInstructions.fromJson(json['paymentInstructions']),
    );
  }
}

/// Model for Stripe payment intent
class PaymentIntent {
  final String id;
  final String clientSecret;
  final String status;
  final bool requiresAction;
  final Map<String, dynamic>? nextAction;

  PaymentIntent({
    required this.id,
    required this.clientSecret,
    required this.status,
    required this.requiresAction,
    this.nextAction,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      id: json['id'] ?? '',
      clientSecret: json['clientSecret'] ?? '',
      status: json['status'] ?? '',
      requiresAction: json['requiresAction'] ?? false,
      nextAction: json['nextAction'],
    );
  }
}

/// Model for payment instructions
class PaymentInstructions {
  final double amount;
  final String currency;
  final List<String> paymentMethods;
  final List<String> nextSteps;
  final Map<String, String> apiEndpoints;

  PaymentInstructions({
    required this.amount,
    required this.currency,
    required this.paymentMethods,
    required this.nextSteps,
    required this.apiEndpoints,
  });

  factory PaymentInstructions.fromJson(Map<String, dynamic> json) {
    return PaymentInstructions(
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      paymentMethods: List<String>.from(json['paymentMethods']),
      nextSteps: List<String>.from(json['nextSteps']),
      apiEndpoints: Map<String, String>.from(json['apiEndpoints']),
    );
  }
}

/// Model for booking status response (public endpoint)
class BookingStatusResponse {
  final String referenceNumber;
  final String bookingStatus;
  final String paymentStatus;
  final String flightDate;
  final String flightTime;
  final String origin;
  final String destination;
  final String aircraftName;
  final String companyName;
  final String totalPrice;
  final int passengerCount;
  final String createdAt;
  final String updatedAt;

  BookingStatusResponse({
    required this.referenceNumber,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.flightDate,
    required this.flightTime,
    required this.origin,
    required this.destination,
    required this.aircraftName,
    required this.companyName,
    required this.totalPrice,
    required this.passengerCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingStatusResponse.fromJson(Map<String, dynamic> json) {
    return BookingStatusResponse(
      referenceNumber: json['referenceNumber'],
      bookingStatus: json['bookingStatus'],
      paymentStatus: json['paymentStatus'],
      flightDate: json['flightDate'],
      flightTime: json['flightTime'],
      origin: json['origin'],
      destination: json['destination'],
      aircraftName: json['aircraftName'],
      companyName: json['companyName'],
      totalPrice: json['totalPrice'],
      passengerCount: json['passengerCount'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

/// Model for booking summary
class BookingSummary {
  final String id;
  final String referenceNumber;
  final double totalPrice;
  final int loyaltyPointsEarned;
  final int loyaltyPointsRedeemed;
  final double walletAmountUsed;
  final double netAmount;
  final Map<String, dynamic> company;
  final Map<String, dynamic> deal;
  final List<Map<String, dynamic>> passengers;
  final String status;
  final String paymentStatus;

  BookingSummary({
    required this.id,
    required this.referenceNumber,
    required this.totalPrice,
    required this.loyaltyPointsEarned,
    required this.loyaltyPointsRedeemed,
    required this.walletAmountUsed,
    required this.netAmount,
    required this.company,
    required this.deal,
    required this.passengers,
    required this.status,
    required this.paymentStatus,
  });

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    return BookingSummary(
      id: json['id'],
      referenceNumber: json['referenceNumber'],
      totalPrice: json['totalPrice'].toDouble(),
      loyaltyPointsEarned: json['loyaltyPointsEarned'],
      loyaltyPointsRedeemed: json['loyaltyPointsRedeemed'],
      walletAmountUsed: json['walletAmountUsed'].toDouble(),
      netAmount: json['netAmount'].toDouble(),
      company: json['company'],
      deal: json['deal'],
      passengers: List<Map<String, dynamic>>.from(json['passengers']),
      status: json['status'],
      paymentStatus: json['paymentStatus'],
    );
  }
}

/// Model for booking timeline event
class BookingTimelineEvent {
  final String id;
  final String bookingId;
  final String eventType;
  final String title;
  final String description;
  final String? oldValue;
  final String? newValue;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  BookingTimelineEvent({
    required this.id,
    required this.bookingId,
    required this.eventType,
    required this.title,
    required this.description,
    this.oldValue,
    this.newValue,
    this.metadata,
    required this.createdAt,
  });

  factory BookingTimelineEvent.fromJson(Map<String, dynamic> json) {
    return BookingTimelineEvent(
      id: json['id'],
      bookingId: json['bookingId'],
      eventType: json['eventType'],
      title: json['title'],
      description: json['description'],
      oldValue: json['oldValue'],
      newValue: json['newValue'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
