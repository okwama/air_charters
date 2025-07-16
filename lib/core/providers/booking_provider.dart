import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../models/payment_models.dart';
import '../services/booking_service.dart';
import '../error/app_exceptions.dart';

enum BookingState {
  initial,
  loading,
  loaded,
  creating,
  updating,
  error,
}

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();

  // State management
  BookingState _state = BookingState.initial;
  String? _errorMessage;
  List<BookingModel> _bookings = [];
  BookingModel? _currentBooking;
  Map<String, int> _bookingStats = {};

  // New state for payment intent
  BookingWithPaymentIntent? _currentBookingWithPaymentIntent;

  // Getters
  BookingState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage; // Alias for error message
  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  BookingModel? get currentBooking => _currentBooking;
  BookingWithPaymentIntent? get currentBookingWithPaymentIntent =>
      _currentBookingWithPaymentIntent;
  Map<String, int> get bookingStats => Map.unmodifiable(_bookingStats);
  bool get isLoading => _state == BookingState.loading;
  bool get isCreating => _state == BookingState.creating;
  bool get isUpdating => _state == BookingState.updating;
  bool get hasError => _state == BookingState.error;
  bool get hasBookings => _bookings.isNotEmpty;
  int get bookingCount => _bookings.length;

  // Get upcoming bookings (future dates or confirmed/paid statuses)
  List<BookingModel> get upcomingBookings {
    final now = DateTime.now();
    return _bookings.where((booking) {
      // Check if the booking is in the future or is confirmed/paid regardless of date
      final isFutureDate = booking.departureDate?.isAfter(now) ?? false;
      final isConfirmedOrPaid =
          booking.bookingStatus == BookingStatus.confirmed ||
              booking.paymentStatus == PaymentStatus.paid;

      return (isFutureDate || isConfirmedOrPaid) &&
          booking.bookingStatus != BookingStatus.cancelled &&
          booking.bookingStatus != BookingStatus.completed;
    }).toList()
      ..sort((a, b) =>
          a.departureDate?.compareTo(b.departureDate ?? DateTime.now()) ?? 0);
  }

  // Get past bookings (completed or past dates)
  List<BookingModel> get pastBookings {
    final now = DateTime.now();
    return _bookings.where((booking) {
      final isPastDate = booking.departureDate?.isBefore(now) ?? false;
      final isCompleted = booking.bookingStatus == BookingStatus.completed;

      return (isPastDate && booking.bookingStatus != BookingStatus.pending) ||
          isCompleted ||
          booking.bookingStatus == BookingStatus.cancelled;
    }).toList()
      ..sort((a, b) =>
          b.departureDate?.compareTo(a.departureDate ?? DateTime.now()) ?? 0);
  }

  // Clear error state
  void clearError() {
    _errorMessage = null;
    if (_state == BookingState.error) {
      _state = BookingState.loaded;
      notifyListeners();
    }
  }

  /// Create a new booking with payment intent for seamless Stripe integration
  Future<BookingWithPaymentIntent?> createBookingWithPaymentIntent(
      BookingModel booking) async {
    try {
      _state = BookingState.creating;
      _errorMessage = null;
      notifyListeners();

      final result =
          await _bookingService.createBookingWithPaymentIntent(booking);

      // Add to local list
      _bookings.insert(0, result.booking);
      _currentBooking = result.booking;
      _currentBookingWithPaymentIntent = result;

      _state = BookingState.loaded;
      notifyListeners();

      return result;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Process payment for a booking and populate points/reference (unified payment flow)
  Future<bool> processPayment(
      String bookingId, String transactionId, String paymentMethod) async {
    try {
      _state = BookingState.updating;
      _errorMessage = null;
      notifyListeners();

      final updatedBooking = await _bookingService.processPayment(
          bookingId, transactionId, paymentMethod);

      // Update in list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index >= 0) {
        _bookings[index] = updatedBooking;
      }

      // Update current booking if it's the same
      if (_currentBooking?.id == bookingId) {
        _currentBooking = updatedBooking;
      }

      // Clear payment intent after successful processing
      if (_currentBookingWithPaymentIntent?.booking.id == bookingId) {
        _currentBookingWithPaymentIntent = null;
      }

      _state = BookingState.loaded;
      notifyListeners();

      return true;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Get booking status by reference number (public endpoint)
  Future<BookingStatusResponse?> getBookingStatusByReference(
      String reference) async {
    try {
      _state = BookingState.loading;
      _errorMessage = null;
      notifyListeners();

      final statusResponse =
          await _bookingService.getBookingStatusByReference(reference);

      _state = BookingState.loaded;
      notifyListeners();

      return statusResponse;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Update loyalty points and wallet amount used for a booking
  Future<bool> updateLoyaltyAndWallet(
    String bookingId, {
    int loyaltyPointsRedeemed = 0,
    double walletAmountUsed = 0,
  }) async {
    try {
      _state = BookingState.updating;
      _errorMessage = null;
      notifyListeners();

      final updatedBooking = await _bookingService.updateLoyaltyAndWallet(
        bookingId,
        loyaltyPointsRedeemed: loyaltyPointsRedeemed,
        walletAmountUsed: walletAmountUsed,
      );

      // Update in list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index >= 0) {
        _bookings[index] = updatedBooking;
      }

      // Update current booking if it's the same
      if (_currentBooking?.id == bookingId) {
        _currentBooking = updatedBooking;
      }

      _state = BookingState.loaded;
      notifyListeners();

      return true;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Get booking summary with loyalty and wallet information
  Future<BookingSummary?> getBookingSummary(String bookingId) async {
    try {
      _state = BookingState.loading;
      _errorMessage = null;
      notifyListeners();

      final summary = await _bookingService.getBookingSummary(bookingId);

      _state = BookingState.loaded;
      notifyListeners();

      return summary;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Get booking timeline
  Future<List<BookingTimelineEvent>> getBookingTimeline(
      String bookingId) async {
    try {
      final timeline = await _bookingService.getBookingTimeline(bookingId);
      return timeline;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load booking timeline: $e');
      }
      return [];
    }
  }

  /// Create a new booking (legacy method - kept for backward compatibility)
  Future<BookingModel?> createBooking(BookingModel booking) async {
    try {
      _state = BookingState.creating;
      _errorMessage = null;
      notifyListeners();

      final createdBooking = await _bookingService.createBooking(booking);

      // Add to local list
      _bookings.insert(0, createdBooking);
      _currentBooking = createdBooking;

      _state = BookingState.loaded;
      notifyListeners();

      return createdBooking;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Load all user bookings
  Future<void> loadUserBookings() async {
    try {
      _state = BookingState.loading;
      _errorMessage = null;
      notifyListeners();

      final bookings = await _bookingService.fetchUserBookings();
      _bookings = bookings;

      _state = BookingState.loaded;
      notifyListeners();
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Alias for loadUserBookings to match the method name used in TripsPage
  Future<void> fetchUserBookings() async {
    await loadUserBookings();
  }

  /// Load a specific booking by ID
  Future<void> loadBookingById(String bookingId) async {
    try {
      _state = BookingState.loading;
      _errorMessage = null;
      notifyListeners();

      final booking = await _bookingService.fetchBookingById(bookingId);
      _currentBooking = booking;

      // Update in list if exists
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index >= 0) {
        _bookings[index] = booking;
      }

      _state = BookingState.loaded;
      notifyListeners();
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Load booking by reference
  Future<void> loadBookingByReference(String reference) async {
    try {
      _state = BookingState.loading;
      _errorMessage = null;
      notifyListeners();

      final booking = await _bookingService.fetchBookingByReference(reference);
      _currentBooking = booking;

      // Update in list if exists
      final index = _bookings.indexWhere((b) => b.referenceNumber == reference);
      if (index >= 0) {
        _bookings[index] = booking;
      }

      _state = BookingState.loaded;
      notifyListeners();
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      _state = BookingState.updating;
      _errorMessage = null;
      notifyListeners();

      final cancelledBooking = await _bookingService.cancelBooking(bookingId);

      // Update in list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index >= 0) {
        _bookings[index] = cancelledBooking;
      }

      // Update current booking if it's the same
      if (_currentBooking?.id == bookingId) {
        _currentBooking = cancelledBooking;
      }

      _state = BookingState.loaded;
      notifyListeners();

      return true;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Update payment status (legacy method - kept for backward compatibility)
  Future<bool> updatePaymentStatus(
      String bookingId, PaymentStatus status) async {
    try {
      _state = BookingState.updating;
      _errorMessage = null;
      notifyListeners();

      final updatedBooking =
          await _bookingService.updatePaymentStatus(bookingId, status);

      // Update in list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index >= 0) {
        _bookings[index] = updatedBooking;
      }

      // Update current booking if it's the same
      if (_currentBooking?.id == bookingId) {
        _currentBooking = updatedBooking;
      }

      _state = BookingState.loaded;
      notifyListeners();

      return true;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Load booking statistics
  Future<void> loadBookingStats() async {
    try {
      final stats = await _bookingService.fetchBookingStats();
      _bookingStats = stats;
      notifyListeners();
    } catch (e) {
      // Don't update state for stats error, just log it
      if (kDebugMode) {
        print('Failed to load booking stats: $e');
      }
    }
  }

  /// Get bookings by status
  List<BookingModel> getBookingsByStatus(BookingStatus status) {
    return _bookings
        .where((booking) => booking.bookingStatus == status)
        .toList();
  }

  /// Refresh current data
  Future<void> refresh() async {
    await loadUserBookings();
    await loadBookingStats();
  }

  /// Reset state
  void reset() {
    _state = BookingState.initial;
    _errorMessage = null;
    _bookings.clear();
    _currentBooking = null;
    _currentBookingWithPaymentIntent = null;
    _bookingStats.clear();
    notifyListeners();
  }

  /// Complete payment for a booking using the unified payment endpoint
  Future<bool> completePayment(
    String bookingId,
    String paymentIntentId, {
    String? paymentMethodId,
  }) async {
    try {
      _state = BookingState.updating;
      _errorMessage = null;
      notifyListeners();

      final updatedBooking = await _bookingService.completePayment(
        bookingId,
        paymentIntentId,
        paymentMethodId: paymentMethodId,
      );

      // Update in list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index >= 0) {
        _bookings[index] = updatedBooking;
      }

      // Update current booking if it's the same
      if (_currentBooking?.id == bookingId) {
        _currentBooking = updatedBooking;
      }

      // Clear payment intent after successful completion
      if (_currentBookingWithPaymentIntent?.booking.id == bookingId) {
        _currentBookingWithPaymentIntent = null;
      }

      _state = BookingState.loaded;
      notifyListeners();

      return true;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Create payment intent separately (alternative flow)
  Future<PaymentIntentModel?> createPaymentIntent({
    required double amount,
    required String bookingId,
    required String userId,
    String currency = 'USD',
    String description = '',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _state = BookingState.creating;
      _errorMessage = null;
      notifyListeners();

      final paymentIntent = await _bookingService.createPaymentIntent(
        amount: amount,
        bookingId: bookingId,
        userId: userId,
        currency: currency,
        description: description,
        metadata: metadata,
      );

      _state = BookingState.loaded;
      notifyListeners();

      return paymentIntent;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Get payment status
  Future<PaymentConfirmationModel?> getPaymentStatus(
      String paymentIntentId) async {
    try {
      _state = BookingState.loading;
      _errorMessage = null;
      notifyListeners();

      final paymentStatus =
          await _bookingService.getPaymentStatus(paymentIntentId);

      _state = BookingState.loaded;
      notifyListeners();

      return paymentStatus;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Confirm payment with Stripe
  Future<PaymentConfirmationModel?> confirmPayment({
    required String paymentIntentId,
    String? paymentMethodId,
  }) async {
    try {
      _state = BookingState.updating;
      _errorMessage = null;
      notifyListeners();

      final paymentConfirmation = await _bookingService.confirmPayment(
        paymentIntentId: paymentIntentId,
        paymentMethodId: paymentMethodId,
      );

      _state = BookingState.loaded;
      notifyListeners();

      return paymentConfirmation;
    } catch (e) {
      _state = BookingState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Get error message from exception
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else {
      return error.toString();
    }
  }
}
