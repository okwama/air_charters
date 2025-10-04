/// Configuration class for dynamic pricing parameters
/// This allows business users to adjust pricing without code changes
class PricingConfig {
  static const PricingConfig _instance = PricingConfig._internal();
  const PricingConfig._internal();
  factory PricingConfig() => _instance;

  // Stop-based pricing factors
  static const double stopCostMultiplier = 0.15; // 15% additional cost per stop
  static const double roundTripMultiplier = 2.0; // 2x cost for round trips

  // Minimum pricing
  static const double minimumFlightHours = 1.0; // Minimum 1-hour charge

  // Distance-based factors (for future use)
  static const double shortHaulThreshold = 100.0; // km
  static const double mediumHaulThreshold = 500.0; // km
  static const double longHaulThreshold = 1000.0; // km

  // Short haul pricing factors
  static const double shortHaulMultiplier = 1.0; // No discount
  static const double mediumHaulMultiplier = 1.0; // No discount
  static const double longHaulMultiplier = 1.0; // No discount

  // Fuel surcharge factors
  static const double fuelSurchargeRate = 0.0; // No fuel surcharge currently

  // Tax rates
  static const double vatRate = 0.0; // No VAT currently
  static const double serviceTaxRate = 0.0; // No service tax currently

  // Currency conversion
  static const String baseCurrency = 'USD';
  static const String localCurrency = 'KES';
  static const double usdToKesRate = 150.0; // Approximate rate

  /// Get all pricing factors as a map for easy configuration
  static Map<String, dynamic> getAllFactors() {
    return {
      'stopCostMultiplier': stopCostMultiplier,
      'roundTripMultiplier': roundTripMultiplier,
      'minimumFlightHours': minimumFlightHours,
      'shortHaulThreshold': shortHaulThreshold,
      'mediumHaulThreshold': mediumHaulThreshold,
      'longHaulThreshold': longHaulThreshold,
      'shortHaulMultiplier': shortHaulMultiplier,
      'mediumHaulMultiplier': mediumHaulMultiplier,
      'longHaulMultiplier': longHaulMultiplier,
      'fuelSurchargeRate': fuelSurchargeRate,
      'vatRate': vatRate,
      'serviceTaxRate': serviceTaxRate,
      'baseCurrency': baseCurrency,
      'localCurrency': localCurrency,
      'usdToKesRate': usdToKesRate,
    };
  }

  /// Update pricing factors (for future admin panel integration)
  static void updateFactors(Map<String, dynamic> newFactors) {
    // This would be implemented when admin panel is ready
    // For now, factors are constants
    throw UnimplementedError(
        'Dynamic pricing configuration not yet implemented');
  }

  /// Validate pricing factors
  static bool validateFactors(Map<String, dynamic> factors) {
    // Validate that all required factors are present and valid
    final requiredFactors = [
      'stopCostMultiplier',
      'roundTripMultiplier',
      'minimumFlightHours',
    ];

    for (final factor in requiredFactors) {
      if (!factors.containsKey(factor)) {
        return false;
      }

      final value = factors[factor];
      if (value is! num || value < 0) {
        return false;
      }
    }

    return true;
  }
}
