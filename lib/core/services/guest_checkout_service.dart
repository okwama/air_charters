import 'package:air_charters/core/models/booking_model.dart';
import 'package:air_charters/core/models/passenger_model.dart';
import 'package:air_charters/core/network/api_client.dart';
import 'package:flutter/foundation.dart';

/// Service for handling guest checkout without full registration
class GuestCheckoutService {
  final ApiClient _apiClient;

  GuestCheckoutService(this._apiClient);

  /// Create a guest booking with minimal information
  Future<GuestBookingResult> createGuestBooking({
    required GuestBookingData bookingData,
    required List<PassengerModel> passengers,
  }) async {
    try {
      if (kDebugMode) {
        print('GuestCheckoutService: Creating guest booking');
      }

      // Validate guest booking data
      final validationResult = _validateGuestBookingData(bookingData, passengers);
      if (!validationResult.isValid) {
        return GuestBookingResult.failure(validationResult.errorMessage ?? 'Unknown validation error');
      }

      // Prepare booking payload
      final bookingPayload = {
        'isGuestBooking': true,
        'guestEmail': bookingData.email,
        'guestPhone': bookingData.phone,
        'dealId': bookingData.dealId,
        'totalPrice': bookingData.totalPrice,
        'onboardDining': bookingData.onboardDining,
        'groundTransportation': bookingData.groundTransportation,
        'specialRequirements': bookingData.specialRequirements,
        'billingRegion': bookingData.billingRegion,
        'passengers': passengers.map((p) => p.toJson()).toList(),
        'guestPreferences': {
          'marketingConsent': bookingData.marketingConsent,
          'termsAccepted': bookingData.termsAccepted,
        },
      };

      // Create booking via API
      final response = await _apiClient.post('/api/bookings/guest', bookingPayload);

      if (response['success']) {
        final bookingData = response['data'];
        final booking = BookingModel.fromJson(bookingData);
        
        if (kDebugMode) {
          print('GuestCheckoutService: Guest booking created successfully');
        }

        return GuestBookingResult.success(booking, bookingData['guestBookingId']);
      } else {
        return GuestBookingResult.failure(response['message'] ?? 'Failed to create guest booking');
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestCheckoutService: Error creating guest booking: $e');
      }
      return GuestBookingResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Validate guest booking data
  GuestBookingValidationResult _validateGuestBookingData(
    GuestBookingData bookingData,
    List<PassengerModel> passengers,
  ) {
    // Validate email
    if (bookingData.email.isEmpty) {
      return GuestBookingValidationResult.failure('Email is required');
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(bookingData.email)) {
      return GuestBookingValidationResult.failure('Please enter a valid email address');
    }

    // Validate phone
    if (bookingData.phone.isEmpty) {
      return GuestBookingValidationResult.failure('Phone number is required');
    }

    // Validate passengers
    if (passengers.isEmpty) {
      return GuestBookingValidationResult.failure('At least one passenger is required');
    }

    // Validate terms acceptance
    if (!bookingData.termsAccepted) {
      return GuestBookingValidationResult.failure('You must accept the terms and conditions');
    }

    // Validate pricing
    if (bookingData.totalPrice <= 0) {
      return GuestBookingValidationResult.failure('Invalid booking amount');
    }

    return GuestBookingValidationResult.success();
  }

  /// Get guest booking by ID and email
  Future<GuestBookingResult> getGuestBooking({
    required String bookingId,
    required String email,
  }) async {
    try {
      final response = await _apiClient.get('/api/bookings/guest/$bookingId', queryParams: {
        'email': email,
      });

      if (response['success']) {
        final booking = BookingModel.fromJson(response['data']);
        return GuestBookingResult.success(booking, bookingId);
      } else {
        return GuestBookingResult.failure(response['message'] ?? 'Booking not found');
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestCheckoutService: Error getting guest booking: $e');
      }
      return GuestBookingResult.failure('Failed to retrieve booking: ${e.toString()}');
    }
  }

  /// Update guest booking
  Future<GuestBookingResult> updateGuestBooking({
    required String bookingId,
    required String email,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _apiClient.put('/api/bookings/guest/$bookingId', {
        'email': email,
        'updates': updates,
      });

      if (response['success']) {
        final booking = BookingModel.fromJson(response['data']);
        return GuestBookingResult.success(booking, bookingId);
      } else {
        return GuestBookingResult.failure(response['message'] ?? 'Failed to update booking');
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestCheckoutService: Error updating guest booking: $e');
      }
      return GuestBookingResult.failure('Failed to update booking: ${e.toString()}');
    }
  }

  /// Cancel guest booking
  Future<GuestBookingResult> cancelGuestBooking({
    required String bookingId,
    required String email,
    String? reason,
  }) async {
    try {
      final response = await _apiClient.delete('/api/bookings/guest/$bookingId', {
        'email': email,
        'reason': reason,
      });

      if (response['success']) {
        final booking = BookingModel.fromJson(response['data']);
        return GuestBookingResult.success(booking, bookingId);
      } else {
        return GuestBookingResult.failure(response['message'] ?? 'Failed to cancel booking');
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestCheckoutService: Error canceling guest booking: $e');
      }
      return GuestBookingResult.failure('Failed to cancel booking: ${e.toString()}');
    }
  }
}

/// Data class for guest booking information
class GuestBookingData {
  final String email;
  final String phone;
  final int dealId;
  final double totalPrice;
  final bool onboardDining;
  final bool groundTransportation;
  final String? specialRequirements;
  final String billingRegion;
  final bool marketingConsent;
  final bool termsAccepted;

  const GuestBookingData({
    required this.email,
    required this.phone,
    required this.dealId,
    required this.totalPrice,
    required this.onboardDining,
    required this.groundTransportation,
    this.specialRequirements,
    required this.billingRegion,
    required this.marketingConsent,
    required this.termsAccepted,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'dealId': dealId,
      'totalPrice': totalPrice,
      'onboardDining': onboardDining,
      'groundTransportation': groundTransportation,
      'specialRequirements': specialRequirements,
      'billingRegion': billingRegion,
      'marketingConsent': marketingConsent,
      'termsAccepted': termsAccepted,
    };
  }
}

/// Result class for guest booking operations
class GuestBookingResult {
  final bool isSuccess;
  final BookingModel? booking;
  final String? guestBookingId;
  final String? errorMessage;

  const GuestBookingResult._({
    required this.isSuccess,
    this.booking,
    this.guestBookingId,
    this.errorMessage,
  });

  factory GuestBookingResult.success(BookingModel booking, String guestBookingId) {
    return GuestBookingResult._(
      isSuccess: true,
      booking: booking,
      guestBookingId: guestBookingId,
    );
  }

  factory GuestBookingResult.failure(String errorMessage) {
    return GuestBookingResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Validation result for guest booking data
class GuestBookingValidationResult {
  final bool isValid;
  final String? errorMessage;

  const GuestBookingValidationResult._({
    required this.isValid,
    this.errorMessage,
  });

  factory GuestBookingValidationResult.success() {
    return const GuestBookingValidationResult._(isValid: true);
  }

  factory GuestBookingValidationResult.failure(String errorMessage) {
    return GuestBookingValidationResult._(
      isValid: false,
      errorMessage: errorMessage,
    );
  }
}

