import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../models/passenger_model.dart';
import '../providers/booking_provider.dart';
import '../providers/passengers_provider.dart';
import '../providers/auth_provider.dart';

/// Controller to handle booking creation business logic
/// Coordinates between BookingProvider and PassengerProvider
class BookingController {
  final BookingProvider _bookingProvider;
  final PassengerProvider _passengerProvider;
  final AuthProvider _authProvider;

  BookingController({
    required BookingProvider bookingProvider,
    required PassengerProvider passengerProvider,
    required AuthProvider authProvider,
  })  : _bookingProvider = bookingProvider,
        _passengerProvider = passengerProvider,
        _authProvider = authProvider;

  /// Create a complete booking with passengers
  Future<BookingCreationResult> createBookingWithPassengers({
    required String departure,
    required String destination,
    required DateTime departureDate,
    required String departureTime,
    required String aircraft,
    required String duration,
    required double basePrice,
    required double totalPrice,
    required bool onboardDining,
    required bool groundTransportation,
    String? specialRequirements,
    String? billingRegion,
    String? paymentMethod,
    int? charterDealId,
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
        departure: departure,
        destination: destination,
        departureDate: departureDate,
        departureTime: departureTime,
        aircraft: aircraft,
        totalPassengers: _passengerProvider.passengerCount,
        duration: duration,
        basePrice: basePrice,
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
        print('BookingController.createBookingWithPassengers error: $e');
      }
      return BookingCreationResult.failure(
          'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Initialize booking creation flow
  /// Sets up passengers with current user data
  void initializeBookingCreation() {
    final currentUser = _authProvider.currentUser;
    _passengerProvider.initializeForBooking(currentUser: currentUser);
  }

  /// Validate booking data before creation
  BookingValidationResult validateBookingData({
    required String departure,
    required String destination,
    required DateTime departureDate,
    required String departureTime,
    required String aircraft,
    required String duration,
    required double basePrice,
    required double totalPrice,
  }) {
    final errors = <String>[];

    // Basic validation
    if (departure.trim().isEmpty) {
      errors.add('Departure location is required');
    }

    if (destination.trim().isEmpty) {
      errors.add('Destination location is required');
    }

    if (departureDate.isBefore(DateTime.now())) {
      errors.add('Departure date cannot be in the past');
    }

    if (departureTime.trim().isEmpty) {
      errors.add('Departure time is required');
    }

    if (aircraft.trim().isEmpty) {
      errors.add('Aircraft information is required');
    }

    if (duration.trim().isEmpty) {
      errors.add('Flight duration is required');
    }

    if (basePrice <= 0) {
      errors.add('Base price must be greater than 0');
    }

    if (totalPrice <= 0) {
      errors.add('Total price must be greater than 0');
    }

    // Passenger validation
    if (!_passengerProvider.hasPassengers) {
      errors.add('At least one passenger is required');
    }

    // Validate each passenger
    for (int i = 0; i < _passengerProvider.passengers.length; i++) {
      final passenger = _passengerProvider.passengers[i];
      if (passenger.firstName.trim().isEmpty) {
        errors.add('Passenger ${i + 1}: First name is required');
      }
      if (passenger.lastName.trim().isEmpty) {
        errors.add('Passenger ${i + 1}: Last name is required');
      }
    }

    return BookingValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Get current passenger count
  int get passengerCount => _passengerProvider.passengerCount;

  /// Check if passengers are configured
  bool get hasPassengers => _passengerProvider.hasPassengers;

  /// Get current booking state
  BookingState get bookingState => _bookingProvider.state;

  /// Check if booking creation is in progress
  bool get isCreatingBooking => _bookingProvider.isCreating;

  /// Get booking creation error message
  String? get bookingErrorMessage => _bookingProvider.errorMessage;

  /// Clear any booking errors
  void clearBookingError() {
    _bookingProvider.clearError();
  }
}

/// Result of booking creation operation
class BookingCreationResult {
  final bool isSuccess;
  final BookingModel? booking;
  final String? errorMessage;

  BookingCreationResult._({
    required this.isSuccess,
    this.booking,
    this.errorMessage,
  });

  factory BookingCreationResult.success(BookingModel booking) {
    return BookingCreationResult._(
      isSuccess: true,
      booking: booking,
    );
  }

  factory BookingCreationResult.failure(String errorMessage) {
    return BookingCreationResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of booking validation
class BookingValidationResult {
  final bool isValid;
  final List<String> errors;

  BookingValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get firstError => errors.isNotEmpty ? errors.first : '';
  String get allErrors => errors.join('\n');
}
