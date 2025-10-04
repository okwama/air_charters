import 'dart:math' as math show sin, cos, sqrt, atan2, pi, max;
import '../../core/models/location_model.dart';
import 'google_maps_service.dart';
import 'currency_service.dart';
import '../config/pricing_config.dart';

/// Service for calculating dynamic flight pricing based on actual route distance
class DynamicPricingService {
  static final DynamicPricingService _instance =
      DynamicPricingService._internal();
  factory DynamicPricingService() => _instance;
  DynamicPricingService._internal();

  final GoogleMapsService _googleMapsService = GoogleMapsService();

  /// Calculate flight price based on aircraft specs and route distance
  Future<FlightPricingResult?> calculateFlightPrice({
    required double pricePerHour,
    required double? aircraftSpeed, // km/h
    required LocationModel origin,
    required LocationModel destination,
    required bool isRoundTrip,
    List<LocationModel>? stops,
  }) async {
    try {
      // Check if we can calculate pricing
      if (pricePerHour <= 0) {
        return null; // Return null to indicate inquiry needed
      }

      if (origin.latitude == null ||
          origin.longitude == null ||
          destination.latitude == null ||
          destination.longitude == null) {
        return null; // Return null to indicate inquiry needed
      }

      // Calculate total distance including stops
      double totalDistance = 0.0;
      List<FlightSegment> segments = [];

      // Origin to first stop (or destination if no stops)
      if (stops != null && stops.isNotEmpty) {
        totalDistance += _calculateDistance(origin, stops.first);
        segments.add(FlightSegment(
          from: origin,
          to: stops.first,
          distance: _calculateDistance(origin, stops.first),
        ));

        // Between stops
        for (int i = 0; i < stops.length - 1; i++) {
          final segmentDistance = _calculateDistance(stops[i], stops[i + 1]);
          totalDistance += segmentDistance;
          segments.add(FlightSegment(
            from: stops[i],
            to: stops[i + 1],
            distance: segmentDistance,
          ));
        }

        // Last stop to destination
        final lastSegmentDistance = _calculateDistance(stops.last, destination);
        totalDistance += lastSegmentDistance;
        segments.add(FlightSegment(
          from: stops.last,
          to: destination,
          distance: lastSegmentDistance,
        ));
      } else {
        // Direct flight
        totalDistance = _calculateDistance(origin, destination);
        segments.add(FlightSegment(
          from: origin,
          to: destination,
          distance: totalDistance,
        ));
      }

      // Check if distance calculation failed
      if (totalDistance <= 0) {
        return null; // Return null to indicate inquiry needed
      }

      // Round trip calculation
      if (isRoundTrip) {
        totalDistance *= 2;
        // Add return segments (reverse order)
        for (int i = segments.length - 1; i >= 0; i--) {
          segments.add(FlightSegment(
            from: segments[i].to,
            to: segments[i].from,
            distance: segments[i].distance,
          ));
        }
      }

      // Calculate flight duration using Google Maps service
      double flightDurationHours;
      if (aircraftSpeed != null && aircraftSpeed > 0) {
        // Use aircraft's actual speed
        flightDurationHours = totalDistance / aircraftSpeed;
      } else {
        // Use Google Maps service to estimate duration
        flightDurationHours = _googleMapsService.estimateFlightDuration(
          totalDistance,
          'jet', // Default to jet aircraft
        );
      }

      // Check if duration calculation failed
      if (flightDurationHours <= 0) {
        return null; // Return null to indicate inquiry needed
      }

      // Apply minimum pricing from config
      double actualDurationHours =
          math.max(flightDurationHours, PricingConfig.minimumFlightHours);

      // Calculate base price with minimum 1-hour charge
      double basePrice = pricePerHour * actualDurationHours;

      // Apply pricing factors
      double finalPrice = _applyPricingFactors(
        basePrice: basePrice,
        distance: totalDistance,
        stops: stops?.length ?? 0,
        isRoundTrip: isRoundTrip,
      );

      return FlightPricingResult(
        totalPrice: finalPrice,
        basePrice: basePrice,
        flightDurationHours: actualDurationHours,
        totalDistanceKm: totalDistance,
        segments: segments,
        pricingBreakdown: _generatePricingBreakdown(
          basePrice: basePrice,
          distance: totalDistance,
          duration: actualDurationHours,
          stops: stops?.length ?? 0,
          isRoundTrip: isRoundTrip,
        ),
      );
    } catch (e) {
      return null; // Return null to indicate inquiry needed
    }
  }

  /// Calculate distance between two locations using Haversine formula
  double _calculateDistance(LocationModel origin, LocationModel destination) {
    if (origin.latitude == null ||
        origin.longitude == null ||
        destination.latitude == null ||
        destination.longitude == null) {
      return 0.0;
    }

    const double earthRadius = 6371; // Earth's radius in kilometers

    final double lat1 = origin.latitude! * (math.pi / 180);
    final double lon1 = origin.longitude! * (math.pi / 180);
    final double lat2 = destination.latitude! * (math.pi / 180);
    final double lon2 = destination.longitude! * (math.pi / 180);

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Apply pricing factors based on distance, stops, etc.
  double _applyPricingFactors({
    required double basePrice,
    required double distance,
    required int stops,
    required bool isRoundTrip,
  }) {
    double finalPrice = basePrice;

    // No distance-based discounts - use actual pricing
    // Minimum 1-hour charge is already applied in main calculation

    // Stop-based factors - each stop adds actual costs
    if (stops > 0) {
      // Each stop adds complexity and fuel costs
      finalPrice *= (1 + (stops * PricingConfig.stopCostMultiplier));
    }

    // Round trip - actual 2x pricing (no discount)
    if (isRoundTrip) {
      finalPrice *=
          PricingConfig.roundTripMultiplier; // Full price for return leg
    }

    return finalPrice;
  }

  /// Generate detailed pricing breakdown
  Map<String, dynamic> _generatePricingBreakdown({
    required double basePrice,
    required double distance,
    required double duration,
    required int stops,
    required bool isRoundTrip,
  }) {
    return {
      'basePrice': basePrice,
      'distanceKm': distance,
      'durationHours': duration,
      'stopsCount': stops,
      'isRoundTrip': isRoundTrip,
      'minimumHourApplied': duration < 1.0,
      'stopsFactor': stops > 0 ? (1 + (stops * 0.15)) : 1.0,
      'roundTripFactor': isRoundTrip ? 2.0 : 1.0,
      'currency': 'USD',
    };
  }

  /// Check if aircraft supports dynamic pricing
  bool canCalculateDynamicPrice({
    required double? pricePerHour,
    required double? aircraftSpeed,
  }) {
    return pricePerHour != null && pricePerHour > 0;
  }

  /// Get pricing recommendation for aircraft without dynamic pricing
  PricingRecommendation getPricingRecommendation({
    required String aircraftName,
    required int capacity,
    required String? aircraftType,
  }) {
    // Base recommendations for different aircraft types
    double baseHourlyRate;
    String recommendation;

    switch (aircraftType?.toLowerCase()) {
      case 'helicopter':
        baseHourlyRate = 1500.0;
        recommendation =
            'Contact us for custom pricing. Helicopter charters require specialized planning.';
        break;
      case 'jet':
        baseHourlyRate = 3000.0;
        recommendation =
            'Premium jet service available. Contact for detailed quote including crew and fuel costs.';
        break;
      case 'fixedwing':
        baseHourlyRate = 800.0;
        recommendation =
            'Standard fixed-wing charter. Contact for route-specific pricing.';
        break;
      default:
        baseHourlyRate = 1000.0;
        recommendation =
            'Custom charter pricing available. Contact us for a personalized quote.';
    }

    return PricingRecommendation(
      suggestedHourlyRate: baseHourlyRate,
      recommendation: recommendation,
      requiresInquiry: true,
    );
  }
}

/// Result of flight pricing calculation
class FlightPricingResult {
  final double totalPrice;
  final double basePrice;
  final double flightDurationHours;
  final double totalDistanceKm;
  final List<FlightSegment> segments;
  final Map<String, dynamic> pricingBreakdown;

  FlightPricingResult({
    required this.totalPrice,
    required this.basePrice,
    required this.flightDurationHours,
    required this.totalDistanceKm,
    required this.segments,
    required this.pricingBreakdown,
  });

  /// Get formatted duration string
  String get formattedDuration {
    final hours = flightDurationHours.floor();
    final minutes = ((flightDurationHours - hours) * 60).round();

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get formatted distance string
  String get formattedDistance {
    if (totalDistanceKm < 1) {
      return '${(totalDistanceKm * 1000).round()}m';
    } else if (totalDistanceKm < 100) {
      return '${totalDistanceKm.toStringAsFixed(1)}km';
    } else {
      return '${totalDistanceKm.round()}km';
    }
  }

  /// Get formatted total price in USD
  String get formattedTotalPrice => '\$${totalPrice.toStringAsFixed(0)}';

  /// Get formatted base price in USD
  String get formattedBasePrice => '\$${basePrice.toStringAsFixed(0)}';

  /// Get dual currency pricing (USD and KES)
  Future<Map<String, String>> get dualCurrencyPricing async {
    return await CurrencyService.getDualCurrencyPrice(usdAmount: totalPrice);
  }

  /// Get formatted total price with KES conversion
  Future<String> get formattedTotalPriceWithKES async {
    final dualPricing = await dualCurrencyPricing;
    return '${dualPricing['USD']} (${dualPricing['KES']})';
  }
}

/// Individual flight segment
class FlightSegment {
  final LocationModel from;
  final LocationModel to;
  final double distance;

  FlightSegment({
    required this.from,
    required this.to,
    required this.distance,
  });

  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).round()}m';
    } else if (distance < 100) {
      return '${distance.toStringAsFixed(1)}km';
    } else {
      return '${distance.round()}km';
    }
  }
}

/// Pricing recommendation for aircraft without dynamic pricing
class PricingRecommendation {
  final double suggestedHourlyRate;
  final String recommendation;
  final bool requiresInquiry;

  PricingRecommendation({
    required this.suggestedHourlyRate,
    required this.recommendation,
    required this.requiresInquiry,
  });
}
