import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/passengers_provider.dart';
import '../providers/auth_provider.dart';
import 'booking_service.dart';

/// Service to handle booking creation business logic
/// Coordinates between BookingProvider and PassengerProvider
class BookingBusinessService {
  final BookingProvider _bookingProvider;
  final PassengerProvider _passengerProvider;
  final AuthProvider _authProvider;

  BookingBusinessService({
    required BookingProvider bookingProvider,
    required PassengerProvider passengerProvider,
    required AuthProvider authProvider,
  })  : _bookingProvider = bookingProvider,
        _passengerProvider = passengerProvider,
        _authProvider = authProvider;

  /// Create a complete booking with payment intent for seamless Stripe integration
  Future<BookingCreationResult> createBookingWithPaymentIntent({
    required int dealId,
    required double totalPrice,
    required bool onboardDining,
    required bool groundTransportation,
    String? specialRequirements,
    String? billingRegion,
    PaymentMethod? paymentMethod,
  }) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return BookingCreationResult.failure(
            'User must be authenticated to create booking');
      }

      // Validate passengers exist
      if (!_passengerProvider.hasPassengers) {
        return BookingCreationResult.failure(
            'At least one passenger is required');
      }

      // Create booking model with passenger data
      final booking = BookingModel(
        userId: _authProvider.currentUser?.id ?? '',
        dealId: dealId,
        totalPrice: totalPrice,
        onboardDining: onboardDining,
        groundTransportation: groundTransportation,
        specialRequirements: specialRequirements,
        billingRegion: billingRegion,
        paymentMethod: paymentMethod,
        passengers: _passengerProvider.passengers,
      );

      // Create booking with payment intent
      final bookingWithPaymentIntent =
          await _bookingProvider.createBookingWithPaymentIntent(booking);

      if (bookingWithPaymentIntent != null) {
        // Reset passenger provider since booking is created
        _passengerProvider.reset();

        return BookingCreationResult.successWithPaymentIntent(
          bookingWithPaymentIntent.booking,
          bookingWithPaymentIntent,
        );
      } else {
        return BookingCreationResult.failure(_bookingProvider.errorMessage ??
            'Failed to create booking with payment intent');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            'BookingBusinessService.createBookingWithPaymentIntent error: $e');
      }
      return BookingCreationResult.failure(
          'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Create a complete booking with passengers (legacy method - kept for backward compatibility)
  Future<BookingCreationResult> createBookingWithPassengers({
    required int dealId,
    required double totalPrice,
    required bool onboardDining,
    required bool groundTransportation,
    String? specialRequirements,
    String? billingRegion,
    PaymentMethod? paymentMethod,
  }) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return BookingCreationResult.failure(
            'User must be authenticated to create booking');
      }

      // Validate passengers exist
      if (!_passengerProvider.hasPassengers) {
        return BookingCreationResult.failure(
            'At least one passenger is required');
      }

      // Create booking model with passenger data
      final booking = BookingModel(
        userId: _authProvider.currentUser?.id ?? '',
        dealId: dealId,
        totalPrice: totalPrice,
        onboardDining: onboardDining,
        groundTransportation: groundTransportation,
        specialRequirements: specialRequirements,
        billingRegion: billingRegion,
        paymentMethod: paymentMethod,
        passengers: _passengerProvider.passengers,
      );

      // Create booking
      final createdBooking = await _bookingProvider.createBooking(booking);

      if (createdBooking != null) {
        // Reset passenger provider since booking is created
        _passengerProvider.reset();

        return BookingCreationResult.success(createdBooking);
      } else {
        return BookingCreationResult.failure(
            _bookingProvider.errorMessage ?? 'Failed to create booking');
      }
    } catch (e) {
      if (kDebugMode) {
        print('BookingBusinessService.createBookingWithPassengers error: $e');
      }
      return BookingCreationResult.failure(
          'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Validate booking data before creation
  BookingValidationResult validateBookingData({
    required int dealId,
    required double totalPrice,
    required bool onboardDining,
    required bool groundTransportation,
    String? specialRequirements,
    String? billingRegion,
    PaymentMethod? paymentMethod,
  }) {
    final errors = <String>[];

    // Validate deal ID
    if (dealId <= 0) {
      errors.add('Invalid deal ID');
    }

    // Validate total price
    if (totalPrice <= 0) {
      errors.add('Total price must be greater than 0');
    }

    // Validate user authentication
    if (!_authProvider.isAuthenticated) {
      errors.add('User must be authenticated');
    }

    // Validate passengers
    if (!_passengerProvider.hasPassengers) {
      errors.add('At least one passenger is required');
    }

    // Validate special requirements length
    if (specialRequirements != null && specialRequirements.length > 500) {
      errors.add('Special requirements must be less than 500 characters');
    }

    return BookingValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Get booking summary for confirmation
  BookingSummary getBookingSummary({
    required int dealId,
    required double totalPrice,
    required bool onboardDining,
    required bool groundTransportation,
    String? specialRequirements,
    String? billingRegion,
    PaymentMethod? paymentMethod,
  }) {
    final passengerCount = _passengerProvider.passengers.length;
    final passengerNames = _passengerProvider.passengers
        .map((p) => '${p.firstName} ${p.lastName}')
        .join(', ');

    return BookingSummary(
      dealId: dealId,
      totalPrice: totalPrice,
      passengerCount: passengerCount,
      passengerNames: passengerNames,
      onboardDining: onboardDining,
      groundTransportation: groundTransportation,
      specialRequirements: specialRequirements,
      billingRegion: billingRegion,
      paymentMethod: paymentMethod,
    );
  }
}

/// Result class for booking creation operations
class BookingCreationResult {
  final bool isSuccess;
  final BookingModel? booking;
  final BookingWithPaymentIntent? bookingWithPaymentIntent;
  final String? errorMessage;

  BookingCreationResult._({
    required this.isSuccess,
    this.booking,
    this.bookingWithPaymentIntent,
    this.errorMessage,
  });

  factory BookingCreationResult.success(BookingModel booking) {
    return BookingCreationResult._(
      isSuccess: true,
      booking: booking,
    );
  }

  factory BookingCreationResult.successWithPaymentIntent(
    BookingModel booking,
    BookingWithPaymentIntent bookingWithPaymentIntent,
  ) {
    return BookingCreationResult._(
      isSuccess: true,
      booking: booking,
      bookingWithPaymentIntent: bookingWithPaymentIntent,
    );
  }

  factory BookingCreationResult.failure(String errorMessage) {
    return BookingCreationResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result class for booking validation
class BookingValidationResult {
  final bool isValid;
  final List<String> errors;

  BookingValidationResult({
    required this.isValid,
    required this.errors,
  });
}

/// Summary class for booking confirmation
class BookingSummary {
  final int dealId;
  final double totalPrice;
  final int passengerCount;
  final String passengerNames;
  final bool onboardDining;
  final bool groundTransportation;
  final String? specialRequirements;
  final String? billingRegion;
  final PaymentMethod? paymentMethod;

  BookingSummary({
    required this.dealId,
    required this.totalPrice,
    required this.passengerCount,
    required this.passengerNames,
    required this.onboardDining,
    required this.groundTransportation,
    this.specialRequirements,
    this.billingRegion,
    this.paymentMethod,
  });
}
