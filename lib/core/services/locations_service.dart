import 'dart:math' show sin, cos, sqrt, atan2, pi;
import '../models/location_model.dart';
import '../network/api_client.dart';

class LocationsService {
  final ApiClient _apiClient = ApiClient();

  /// Get all locations
  Future<List<LocationModel>> getAllLocations() async {
    try {
      final response = await _apiClient.get('/api/locations');

      if (response['success'] == true) {
        final locations = (response['data'] as List)
            .map((json) => LocationModel.fromJson(json))
            .toList();
        return locations;
      }

      throw Exception('Failed to load locations');
    } catch (e) {
      throw Exception('Error fetching locations: $e');
    }
  }

  /// Search locations by query
  Future<List<LocationModel>> searchLocations(String query) async {
    try {
      final response = await _apiClient.get('/api/locations/search?q=$query');

      if (response['success'] == true) {
        final locations = (response['data'] as List)
            .map((json) => LocationModel.fromJson(json))
            .toList();
        return locations;
      }

      throw Exception('Failed to search locations');
    } catch (e) {
      throw Exception('Error searching locations: $e');
    }
  }

  /// Get popular locations
  Future<List<LocationModel>> getPopularLocations() async {
    try {
      final response = await _apiClient.get('/api/locations/popular');

      if (response['success'] == true) {
        final locations = (response['data'] as List)
            .map((json) => LocationModel.fromJson(json))
            .toList();
        return locations;
      }

      throw Exception('Failed to load popular locations');
    } catch (e) {
      throw Exception('Error fetching popular locations: $e');
    }
  }

  /// Get route information between two locations
  Future<Map<String, dynamic>> getRouteInfo(
      String originCode, String destinationCode) async {
    try {
      final response = await _apiClient
          .get('/api/locations/route/$originCode/$destinationCode');

      if (response['success'] == true) {
        return response['data'];
      }

      throw Exception('Failed to get route information');
    } catch (e) {
      throw Exception('Error fetching route info: $e');
    }
  }

  /// Calculate distance between two locations using Haversine formula
  double calculateDistance(LocationModel origin, LocationModel destination) {
    if (origin.latitude == null ||
        origin.longitude == null ||
        destination.latitude == null ||
        destination.longitude == null) {
      return 0.0;
    }

    const double earthRadius = 6371; // Earth's radius in kilometers

    final double lat1 = origin.latitude! * (pi / 180);
    final double lat2 = destination.latitude! * (pi / 180);
    final double deltaLat =
        (destination.latitude! - origin.latitude!) * (pi / 180);
    final double deltaLon =
        (destination.longitude! - origin.longitude!) * (pi / 180);

    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Estimate flight duration based on distance
  int estimateFlightDuration(double distanceKm) {
    // Rough estimation: 800 km/h average speed for charter flights
    const double averageSpeed = 800; // km/h
    final double durationHours = distanceKm / averageSpeed;
    return (durationHours * 60).round(); // Convert to minutes
  }
}
