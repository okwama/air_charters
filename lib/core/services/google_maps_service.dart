import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/env/app_config.dart';
import '../../config/env/maps_config.dart';
import '../../shared/utils/session_manager.dart';

/// Service for interacting with Google Maps APIs through our backend
class GoogleMapsService {
  static final GoogleMapsService _instance = GoogleMapsService._internal();
  factory GoogleMapsService() => _instance;
  GoogleMapsService._internal();

  /// Search for locations using Google Places API
  Future<List<GoogleLocation>> searchLocations({
    required String query,
    String? type,
    String? location,
    int? radius,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/google-earth-engine/search'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              await SessionManager().getAuthorizationHeader() ?? '',
        },
        body: jsonEncode({
          'query': query,
          'type': type,
          'location': location,
          'radius': radius,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is List) {
          // Direct Google API response (array of locations)
          return data
              .map((json) =>
                  GoogleLocation.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        } else if (data['success'] == true) {
          // Wrapped response from backend
          return (data['data'] as List)
              .map((json) => GoogleLocation.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to search locations');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error searching locations: $e');
      rethrow;
    }
  }

  /// Get place details by place ID
  Future<GoogleLocation> getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConfig.baseUrl}/api/google-earth-engine/place/$placeId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              await SessionManager().getAuthorizationHeader() ?? '',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('placeId')) {
          // Direct Google API response
          return GoogleLocation.fromJson(Map<String, dynamic>.from(data));
        } else if (data['success'] == true) {
          // Wrapped response from backend
          return GoogleLocation.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to get place details');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error getting place details: $e');
      rethrow;
    }
  }

  /// Reverse geocode coordinates to address
  Future<GoogleLocation> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${AppConfig.baseUrl}/api/google-earth-engine/reverse-geocode',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              await SessionManager().getAuthorizationHeader() ?? '',
        },
        body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('placeId')) {
          // Direct Google API response
          return GoogleLocation.fromJson(Map<String, dynamic>.from(data));
        } else if (data['success'] == true) {
          // Wrapped response from backend
          return GoogleLocation.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to reverse geocode');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
      rethrow;
    }
  }

  /// Calculate distance between two points
  Future<DistanceResult> calculateDistance({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    String mode = 'driving',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/google-earth-engine/distance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              await SessionManager().getAuthorizationHeader() ?? '',
        },
        body: jsonEncode({
          'origin': {'lat': originLat, 'lng': originLng},
          'destination': {'lat': destinationLat, 'lng': destinationLng},
          'mode': mode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('distance')) {
          // Direct Google API response
          return DistanceResult.fromJson(Map<String, dynamic>.from(data));
        } else if (data['success'] == true) {
          // Wrapped response from backend
          return DistanceResult.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to calculate distance');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error calculating distance: $e');
      rethrow;
    }
  }

  /// Calculate flight distance using Haversine formula
  double calculateFlightDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371; // Earth's radius in kilometers
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);

    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return R * c;
  }

  /// Estimate flight duration based on distance and aircraft type
  double estimateFlightDuration(double distanceKm, String aircraftType) {
    // Average speeds in km/h for different aircraft types
    const Map<String, double> speeds = {
      'jet': 800,
      'turboprop': 500,
      'helicopter': 250,
      'small': 300,
    };

    final double speed = speeds[aircraftType] ?? speeds['jet']!;
    return distanceKm / speed; // Return duration in hours
  }

  // Helper math functions
  double _toRadians(double degrees) => degrees * (3.14159265359 / 180);
  double _sin(double x) =>
      x -
      (x * x * x) / 6 +
      (x * x * x * x * x) / 120 -
      (x * x * x * x * x * x * x) / 5040;
  double _cos(double x) =>
      1 - (x * x) / 2 + (x * x * x * x) / 24 - (x * x * x * x * x * x) / 720;
  double _atan2(double y, double x) => y / x; // Simplified for small angles
  double _sqrt(double x) => x >= 0 ? x * x : 0; // Simplified
}

/// Google Location model
class GoogleLocation {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final List<String>? types;
  final double? rating;
  final int? userRatingsTotal;

  GoogleLocation({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.types,
    this.rating,
    this.userRatingsTotal,
  });

  factory GoogleLocation.fromJson(Map<String, dynamic> json) {
    return GoogleLocation(
      placeId: json['placeId'],
      name: json['name'],
      formattedAddress: json['formattedAddress'],
      latitude: json['location']['lat'],
      longitude: json['location']['lng'],
      types: json['types'] != null ? List<String>.from(json['types']) : null,
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['userRatingsTotal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'formattedAddress': formattedAddress,
      'location': {'lat': latitude, 'lng': longitude},
      'types': types,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
    };
  }

  /// Check if this is an airport
  bool get isAirport {
    return types?.any(
          (type) => type.contains('airport') || type.contains('establishment'),
        ) ??
        false;
  }

  /// Get location type for display
  String get locationType {
    if (isAirport) return 'airport';
    if (types?.any((type) => type.contains('locality')) ?? false) return 'city';
    if (types?.any((type) => type.contains('administrative_area_level_1')) ??
        false) {
      return 'region';
    }
    return 'location';
  }
}

/// Distance calculation result
class DistanceResult {
  final String distance;
  final String duration;
  final String status;

  DistanceResult({
    required this.distance,
    required this.duration,
    required this.status,
  });

  factory DistanceResult.fromJson(Map<String, dynamic> json) {
    return DistanceResult(
      distance: json['distance']['text'] ?? '',
      duration: json['duration']['text'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
