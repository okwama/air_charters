import 'package:flutter/foundation.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/booking_service.dart';

/// Controller to handle all payment-related operations
/// Centralizes payment logic including Stripe integration, payment processing, and payment method management
class PaymentController {
  final BookingProvider _bookingProvider;
  final AuthProvider _authProvider;

  PaymentController({
    required BookingProvider bookingProvider,
    required AuthProvider authProvider,
  })  : _bookingProvider = bookingProvider,
        _authProvider = authProvider;

  /// Process payment for a booking using the unified payment flow
  /// This method handles the complete payment process including Stripe integration
  Future<PaymentProcessingResult> processBookingPayment({
    required String bookingId,
    required String transactionId,
    required String paymentMethod,
    String? paymentIntentId,
  }) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return PaymentProcessingResult.failure(
            'User must be authenticated to process payment');
      }

      // Validate required parameters
      if (bookingId.isEmpty) {
        return PaymentProcessingResult.failure('Booking ID is required');
      }
      if (transactionId.isEmpty) {
        return PaymentProcessingResult.failure('Transaction ID is required');
      }
      if (paymentMethod.isEmpty) {
        return PaymentProcessingResult.failure('Payment method is required');
      }

      // Process payment through booking provider
      final success = await _bookingProvider.processPayment(
        bookingId,
        transactionId,
        paymentMethod,
      );

      if (success) {
        return PaymentProcessingResult.success(
          transactionId: transactionId,
          paymentMethod: paymentMethod,
          paymentIntentId: paymentIntentId,
        );
      } else {
        return PaymentProcessingResult.failure(
          _bookingProvider.errorMessage ?? 'Failed to process payment',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('PaymentController.processBookingPayment error: $e');
      }
      return PaymentProcessingResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Update loyalty points and wallet amount used for a booking
  Future<LoyaltyWalletResult> updateLoyaltyAndWallet({
    required String bookingId,
    int loyaltyPointsRedeemed = 0,
    double walletAmountUsed = 0,
  }) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return LoyaltyWalletResult.failure(
            'User must be authenticated to update loyalty and wallet');
      }

      // Validate booking ID
      if (bookingId.isEmpty) {
        return LoyaltyWalletResult.failure('Booking ID is required');
      }

      // Validate amounts
      if (loyaltyPointsRedeemed < 0) {
        return LoyaltyWalletResult.failure('Loyalty points cannot be negative');
      }
      if (walletAmountUsed < 0) {
        return LoyaltyWalletResult.failure('Wallet amount cannot be negative');
      }

      // Update loyalty and wallet through booking provider
      final success = await _bookingProvider.updateLoyaltyAndWallet(
        bookingId,
        loyaltyPointsRedeemed: loyaltyPointsRedeemed,
        walletAmountUsed: walletAmountUsed,
      );

      if (success) {
        return LoyaltyWalletResult.success(
          loyaltyPointsRedeemed: loyaltyPointsRedeemed,
          walletAmountUsed: walletAmountUsed,
        );
      } else {
        return LoyaltyWalletResult.failure(
          _bookingProvider.errorMessage ??
              'Failed to update loyalty and wallet',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('PaymentController.updateLoyaltyAndWallet error: $e');
      }
      return LoyaltyWalletResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get booking summary with loyalty and wallet information
  Future<BookingSummaryResult> getBookingSummary(String bookingId) async {
    try {
      // Validate user is authenticated
      if (!_authProvider.isAuthenticated) {
        return BookingSummaryResult.failure(
            'User must be authenticated to get booking summary');
      }

      // Validate booking ID
      if (bookingId.isEmpty) {
        return BookingSummaryResult.failure('Booking ID is required');
      }

      // Get booking summary through booking provider
      final summary = await _bookingProvider.getBookingSummary(bookingId);

      if (summary != null) {
        return BookingSummaryResult.success(summary);
      } else {
        return BookingSummaryResult.failure(
          _bookingProvider.errorMessage ?? 'Failed to get booking summary',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('PaymentController.getBookingSummary error: $e');
      }
      return BookingSummaryResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get booking status by reference number (public endpoint)
  Future<BookingStatusResult> getBookingStatusByReference(
      String reference) async {
    try {
      // Validate reference number
      if (reference.isEmpty) {
        return BookingStatusResult.failure('Reference number is required');
      }

      // Get booking status through booking provider
      final statusResponse =
          await _bookingProvider.getBookingStatusByReference(reference);

      if (statusResponse != null) {
        return BookingStatusResult.success(statusResponse);
      } else {
        return BookingStatusResult.failure(
          _bookingProvider.errorMessage ?? 'Failed to get booking status',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('PaymentController.getBookingStatusByReference error: $e');
      }
      return BookingStatusResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Validate payment data before processing
  PaymentValidationResult validatePaymentData({
    required String bookingId,
    required String transactionId,
    required String paymentMethod,
    double? amount,
  }) {
    final errors = <String>[];

    // Basic validation
    if (bookingId.isEmpty) {
      errors.add('Booking ID is required');
    }

    if (transactionId.isEmpty) {
      errors.add('Transaction ID is required');
    }

    if (paymentMethod.isEmpty) {
      errors.add('Payment method is required');
    }

    // Payment method validation
    final validPaymentMethods = [
      'card',
      'apple_pay',
      'google_pay',
      'bank_transfer',
      'wallet'
    ];
    if (!validPaymentMethods.contains(paymentMethod.toLowerCase())) {
      errors.add(
          'Invalid payment method. Supported methods: ${validPaymentMethods.join(', ')}');
    }

    // Amount validation (if provided)
    if (amount != null && amount <= 0) {
      errors.add('Amount must be greater than 0');
    }

    return PaymentValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate loyalty and wallet data
  LoyaltyWalletValidationResult validateLoyaltyWalletData({
    required String bookingId,
    int loyaltyPointsRedeemed = 0,
    double walletAmountUsed = 0,
  }) {
    final errors = <String>[];

    // Basic validation
    if (bookingId.isEmpty) {
      errors.add('Booking ID is required');
    }

    // Amount validation
    if (loyaltyPointsRedeemed < 0) {
      errors.add('Loyalty points cannot be negative');
    }

    if (walletAmountUsed < 0) {
      errors.add('Wallet amount cannot be negative');
    }

    // Business logic validation
    if (loyaltyPointsRedeemed > 0 && walletAmountUsed > 0) {
      errors.add(
          'Cannot use both loyalty points and wallet amount simultaneously');
    }

    return LoyaltyWalletValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Get current payment state
  PaymentState get paymentState {
    if (_bookingProvider.isUpdating) {
      return PaymentState.processing;
    } else if (_bookingProvider.hasError) {
      return PaymentState.error;
    } else {
      return PaymentState.ready;
    }
  }

  /// Check if payment is being processed
  bool get isProcessingPayment => _bookingProvider.isUpdating;

  /// Get payment error message
  String? get paymentErrorMessage => _bookingProvider.errorMessage;

  /// Clear payment errors
  void clearPaymentError() {
    _bookingProvider.clearError();
  }

  /// Get current booking with payment intent
  BookingWithPaymentIntent? get currentBookingWithPaymentIntent =>
      _bookingProvider.currentBookingWithPaymentIntent;

  /// Check if user is authenticated
  bool get isAuthenticated => _authProvider.isAuthenticated;
}

/// Payment processing states
enum PaymentState {
  ready,
  processing,
  error,
}

/// Result of payment processing operation
class PaymentProcessingResult {
  final bool isSuccess;
  final String? transactionId;
  final String? paymentMethod;
  final String? paymentIntentId;
  final String? errorMessage;

  PaymentProcessingResult._({
    required this.isSuccess,
    this.transactionId,
    this.paymentMethod,
    this.paymentIntentId,
    this.errorMessage,
  });

  factory PaymentProcessingResult.success({
    String? transactionId,
    String? paymentMethod,
    String? paymentIntentId,
  }) {
    return PaymentProcessingResult._(
      isSuccess: true,
      transactionId: transactionId,
      paymentMethod: paymentMethod,
      paymentIntentId: paymentIntentId,
    );
  }

  factory PaymentProcessingResult.failure(String errorMessage) {
    return PaymentProcessingResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of loyalty and wallet update operation
class LoyaltyWalletResult {
  final bool isSuccess;
  final int? loyaltyPointsRedeemed;
  final double? walletAmountUsed;
  final String? errorMessage;

  LoyaltyWalletResult._({
    required this.isSuccess,
    this.loyaltyPointsRedeemed,
    this.walletAmountUsed,
    this.errorMessage,
  });

  factory LoyaltyWalletResult.success({
    int? loyaltyPointsRedeemed,
    double? walletAmountUsed,
  }) {
    return LoyaltyWalletResult._(
      isSuccess: true,
      loyaltyPointsRedeemed: loyaltyPointsRedeemed,
      walletAmountUsed: walletAmountUsed,
    );
  }

  factory LoyaltyWalletResult.failure(String errorMessage) {
    return LoyaltyWalletResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of booking summary retrieval
class BookingSummaryResult {
  final bool isSuccess;
  final BookingSummary? summary;
  final String? errorMessage;

  BookingSummaryResult._({
    required this.isSuccess,
    this.summary,
    this.errorMessage,
  });

  factory BookingSummaryResult.success(BookingSummary summary) {
    return BookingSummaryResult._(
      isSuccess: true,
      summary: summary,
    );
  }

  factory BookingSummaryResult.failure(String errorMessage) {
    return BookingSummaryResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of booking status retrieval
class BookingStatusResult {
  final bool isSuccess;
  final BookingStatusResponse? statusResponse;
  final String? errorMessage;

  BookingStatusResult._({
    required this.isSuccess,
    this.statusResponse,
    this.errorMessage,
  });

  factory BookingStatusResult.success(BookingStatusResponse statusResponse) {
    return BookingStatusResult._(
      isSuccess: true,
      statusResponse: statusResponse,
    );
  }

  factory BookingStatusResult.failure(String errorMessage) {
    return BookingStatusResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of payment validation
class PaymentValidationResult {
  final bool isValid;
  final List<String> errors;

  PaymentValidationResult({
    required this.isValid,
    required this.errors,
  });
}

/// Result of loyalty and wallet validation
class LoyaltyWalletValidationResult {
  final bool isValid;
  final List<String> errors;

  LoyaltyWalletValidationResult({
    required this.isValid,
    required this.errors,
  });
}
