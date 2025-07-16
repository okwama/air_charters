import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../error/app_exceptions.dart';

enum PaymentState {
  initial,
  loading,
  processing,
  success,
  error,
}

enum PaymentMethodType {
  card,
  applePay,
  googlePay,
  bankTransfer,
  wallet,
  mpesa,
}

class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String? brand;
  final String? last4;
  final int? expiryMonth;
  final int? expiryYear;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    this.brand,
    this.last4,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: PaymentMethodType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentMethodType.card,
      ),
      brand: json['brand'],
      last4: json['last4'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'brand': brand,
      'last4': last4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
    };
  }
}

class PaymentProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();

  // State management
  PaymentState _state = PaymentState.initial;
  String? _errorMessage;

  // Payment data
  List<PaymentMethod> _paymentMethods = [];
  PaymentMethod? _selectedPaymentMethod;
  BookingWithPaymentIntent? _currentPaymentIntent;
  PaymentIntent? _activePaymentIntent;

  // Payment history
  List<Map<String, dynamic>> _paymentHistory = [];

  // Settings
  bool _savePaymentMethods = true;
  String _defaultCurrency = 'USD';

  // Getters
  PaymentState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage; // Alias for error message
  List<PaymentMethod> get paymentMethods => List.unmodifiable(_paymentMethods);
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  BookingWithPaymentIntent? get currentPaymentIntent => _currentPaymentIntent;
  PaymentIntent? get activePaymentIntent => _activePaymentIntent;
  List<Map<String, dynamic>> get paymentHistory =>
      List.unmodifiable(_paymentHistory);
  bool get savePaymentMethods => _savePaymentMethods;
  String get defaultCurrency => _defaultCurrency;

  // State checks
  bool get isLoading => _state == PaymentState.loading;
  bool get isProcessing => _state == PaymentState.processing;
  bool get isSuccess => _state == PaymentState.success;
  bool get hasError => _state == PaymentState.error;
  bool get hasPaymentMethods => _paymentMethods.isNotEmpty;
  bool get hasActivePaymentIntent => _activePaymentIntent != null;

  /// Set current payment intent from booking creation
  void setCurrentPaymentIntent(BookingWithPaymentIntent paymentIntent) {
    _currentPaymentIntent = paymentIntent;
    _activePaymentIntent = paymentIntent.paymentIntent;
    notifyListeners();
  }

  /// Clear current payment intent
  void clearCurrentPaymentIntent() {
    _currentPaymentIntent = null;
    _activePaymentIntent = null;
    notifyListeners();
  }

  /// Select a payment method
  void selectPaymentMethod(PaymentMethod paymentMethod) {
    _selectedPaymentMethod = paymentMethod;
    notifyListeners();
  }

  /// Clear selected payment method
  void clearSelectedPaymentMethod() {
    _selectedPaymentMethod = null;
    notifyListeners();
  }

  /// Add a new payment method
  void addPaymentMethod(PaymentMethod paymentMethod) {
    // Remove default flag from other methods if this is default
    if (paymentMethod.isDefault) {
      _paymentMethods = _paymentMethods
          .map((pm) => PaymentMethod(
                id: pm.id,
                type: pm.type,
                brand: pm.brand,
                last4: pm.last4,
                expiryMonth: pm.expiryMonth,
                expiryYear: pm.expiryYear,
                isDefault: false,
              ))
          .toList();
    }

    _paymentMethods.add(paymentMethod);
    notifyListeners();
  }

  /// Remove a payment method
  void removePaymentMethod(String paymentMethodId) {
    _paymentMethods.removeWhere((pm) => pm.id == paymentMethodId);

    // Clear selection if it was the selected method
    if (_selectedPaymentMethod?.id == paymentMethodId) {
      _selectedPaymentMethod = null;
    }

    notifyListeners();
  }

  /// Set default payment method
  void setDefaultPaymentMethod(String paymentMethodId) {
    _paymentMethods = _paymentMethods
        .map((pm) => PaymentMethod(
              id: pm.id,
              type: pm.type,
              brand: pm.brand,
              last4: pm.last4,
              expiryMonth: pm.expiryMonth,
              expiryYear: pm.expiryYear,
              isDefault: pm.id == paymentMethodId,
            ))
        .toList();

    notifyListeners();
  }

  /// Process payment for a booking
  Future<bool> processPayment({
    required String bookingId,
    required String transactionId,
    required String paymentMethod,
  }) async {
    try {
      _state = PaymentState.processing;
      _errorMessage = null;
      notifyListeners();

      final updatedBooking = await _bookingService.processPayment(
        bookingId,
        transactionId,
        paymentMethod,
      );

      // Add to payment history
      _paymentHistory.insert(0, {
        'bookingId': bookingId,
        'transactionId': transactionId,
        'paymentMethod': paymentMethod,
        'amount': updatedBooking.totalPrice,
        'status': 'success',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Clear current payment intent after successful processing
      clearCurrentPaymentIntent();

      _state = PaymentState.success;
      notifyListeners();

      return true;
    } catch (e) {
      _state = PaymentState.error;
      _errorMessage = _getErrorMessage(e);

      // Add failed payment to history
      _paymentHistory.insert(0, {
        'bookingId': bookingId,
        'transactionId': transactionId,
        'paymentMethod': paymentMethod,
        'status': 'failed',
        'error': _errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      });

      notifyListeners();
      return false;
    }
  }

  /// Update loyalty points and wallet amount
  Future<bool> updateLoyaltyAndWallet({
    required String bookingId,
    int loyaltyPointsRedeemed = 0,
    double walletAmountUsed = 0,
  }) async {
    try {
      _state = PaymentState.processing;
      _errorMessage = null;
      notifyListeners();

      final updatedBooking = await _bookingService.updateLoyaltyAndWallet(
        bookingId,
        loyaltyPointsRedeemed: loyaltyPointsRedeemed,
        walletAmountUsed: walletAmountUsed,
      );

      _state = PaymentState.success;
      notifyListeners();

      return true;
    } catch (e) {
      _state = PaymentState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Get booking summary
  Future<BookingSummary?> getBookingSummary(String bookingId) async {
    try {
      _state = PaymentState.loading;
      _errorMessage = null;
      notifyListeners();

      final summary = await _bookingService.getBookingSummary(bookingId);

      _state = PaymentState.success;
      notifyListeners();

      return summary;
    } catch (e) {
      _state = PaymentState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Get booking status by reference
  Future<BookingStatusResponse?> getBookingStatusByReference(
      String reference) async {
    try {
      _state = PaymentState.loading;
      _errorMessage = null;
      notifyListeners();

      final statusResponse =
          await _bookingService.getBookingStatusByReference(reference);

      _state = PaymentState.success;
      notifyListeners();

      return statusResponse;
    } catch (e) {
      _state = PaymentState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  /// Load saved payment methods (mock implementation)
  Future<void> loadPaymentMethods() async {
    try {
      _state = PaymentState.loading;
      _errorMessage = null;
      notifyListeners();

      // Mock payment methods - in real app, this would come from backend
      await Future.delayed(const Duration(milliseconds: 500));

      _paymentMethods = [
        PaymentMethod(
          id: 'pm_1',
          type: PaymentMethodType.card,
          brand: 'visa',
          last4: '4242',
          expiryMonth: 12,
          expiryYear: 2025,
          isDefault: true,
        ),
        PaymentMethod(
          id: 'pm_2',
          type: PaymentMethodType.card,
          brand: 'mastercard',
          last4: '5555',
          expiryMonth: 10,
          expiryYear: 2026,
          isDefault: false,
        ),
      ];

      // Set default selected method
      _selectedPaymentMethod = _paymentMethods.firstWhere((pm) => pm.isDefault);

      _state = PaymentState.success;
      notifyListeners();
    } catch (e) {
      _state = PaymentState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Load payment history (mock implementation)
  Future<void> loadPaymentHistory() async {
    try {
      _state = PaymentState.loading;
      _errorMessage = null;
      notifyListeners();

      // Mock payment history - in real app, this would come from backend
      await Future.delayed(const Duration(milliseconds: 300));

      _paymentHistory = [
        {
          'bookingId': 'BK-16JUL25-131023-LPX01',
          'transactionId': 'txn_123456789',
          'paymentMethod': 'card',
          'amount': 1500.00,
          'status': 'success',
          'timestamp': '2025-01-15T10:30:00Z',
        },
        {
          'bookingId': 'BK-14JUL25-091523-MNX02',
          'transactionId': 'txn_987654321',
          'paymentMethod': 'wallet',
          'amount': 750.00,
          'status': 'success',
          'timestamp': '2025-01-10T14:15:00Z',
        },
      ];

      _state = PaymentState.success;
      notifyListeners();
    } catch (e) {
      _state = PaymentState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Update payment settings
  void updateSettings({
    bool? savePaymentMethods,
    String? defaultCurrency,
  }) {
    if (savePaymentMethods != null) {
      _savePaymentMethods = savePaymentMethods;
    }
    if (defaultCurrency != null) {
      _defaultCurrency = defaultCurrency;
    }
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    if (_state == PaymentState.error) {
      _state = PaymentState.initial;
      notifyListeners();
    }
  }

  /// Reset state
  void reset() {
    _state = PaymentState.initial;
    _errorMessage = null;
    _paymentMethods.clear();
    _selectedPaymentMethod = null;
    _currentPaymentIntent = null;
    _activePaymentIntent = null;
    _paymentHistory.clear();
    notifyListeners();
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

  /// Get payment methods by type
  List<PaymentMethod> getPaymentMethodsByType(PaymentMethodType type) {
    return _paymentMethods.where((pm) => pm.type == type).toList();
  }

  /// Get default payment method
  PaymentMethod? get defaultPaymentMethod {
    try {
      return _paymentMethods.firstWhere((pm) => pm.isDefault);
    } catch (e) {
      return _paymentMethods.isNotEmpty ? _paymentMethods.first : null;
    }
  }

  /// Check if payment method exists
  bool hasPaymentMethod(String paymentMethodId) {
    return _paymentMethods.any((pm) => pm.id == paymentMethodId);
  }

  /// Get payment method by ID
  PaymentMethod? getPaymentMethodById(String paymentMethodId) {
    try {
      return _paymentMethods.firstWhere((pm) => pm.id == paymentMethodId);
    } catch (e) {
      return null;
    }
  }
}
