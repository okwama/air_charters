import '../../../core/models/booking_model.dart';

class BookingReviewService {
  /// Calculate total price based on base price and add-ons
  static double calculateTotalPrice({
    required double basePrice,
    required bool onboardDining,
    required bool groundTransportation,
  }) {
    final diningCost = onboardDining ? 150.0 : 0.0;
    final transportationCost = groundTransportation ? 200.0 : 0.0;
    final taxes = (basePrice + diningCost + transportationCost) * 0.12;
    return basePrice + diningCost + transportationCost + taxes;
  }

  /// Parse payment method from string
  static String? parsePaymentMethod(String paymentMethodString) {
    if (paymentMethodString.contains('Card')) {
      return 'card';
    } else if (paymentMethodString.contains('MPesa')) {
      return 'mpesa';
    } else if (paymentMethodString.contains('Wallet')) {
      return 'wallet';
    }
    return null;
  }

  /// Validate booking data before creation
  static List<String> validateBookingData({
    required bool agreeToTerms,
    required int dealId,
    required double totalPrice,
    required bool hasPassengers,
  }) {
    final errors = <String>[];

    if (!agreeToTerms) {
      errors.add('You must agree to the terms and conditions');
    }

    if (dealId <= 0) {
      errors.add('Invalid deal selection');
    }

    if (totalPrice <= 0) {
      errors.add('Invalid price calculation');
    }

    if (!hasPassengers) {
      errors.add('At least one passenger is required');
    }

    return errors;
  }

  /// Get price breakdown details
  static Map<String, double> getPriceBreakdown({
    required double basePrice,
    required bool onboardDining,
    required bool groundTransportation,
  }) {
    final diningCost = onboardDining ? 150.0 : 0.0;
    final transportationCost = groundTransportation ? 200.0 : 0.0;
    final taxes = (basePrice + diningCost + transportationCost) * 0.12;
    final totalPrice = basePrice + diningCost + transportationCost + taxes;

    return {
      'basePrice': basePrice,
      'diningCost': diningCost,
      'transportationCost': transportationCost,
      'taxes': taxes,
      'totalPrice': totalPrice,
    };
  }
}
