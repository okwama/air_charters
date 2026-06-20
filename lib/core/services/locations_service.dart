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

  /// Search locations by query with pagination
  Future<LocationSearchResult> searchLocations(String query,
      {int limit = 50, int offset = 0}) async {
    try {
      final response = await _apiClient
          .get('/api/locations/search?q=$query&limit=$limit&offset=$offset');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] as List;
        final int total = response['total'] ?? data.length;

        // Convert to LocationModel (handles both Google and database formats)
        final locations = data.map((json) {
          // Both Google and database results have 'location' object with lat/lng
          if (json['location'] != null) {
            return LocationModel(
              id: json['id'] ?? json['placeId']?.hashCode ?? 0,
              name: json['name'] as String,
              code: json['code'] ?? json['placeId'] ?? '',
              country: json['country'] ?? 
                      _extractCountryFromAddress(json['formattedAddress'] as String? ?? ''),
              type: json['types'] != null 
                  ? _determineTypeFromTypes(json['types'] as List?)
                  : _parseType(json['type'] as String?),
              latitude: json['location']['lat'] as double?,
              longitude: json['location']['lng'] as double?,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          } else {
            // Legacy format (shouldn't happen with current backend)
            return LocationModel.fromJson(json);
          }
        }).toList();

        return LocationSearchResult(
          locations: locations,
          total: total,
          hasMore: (offset + locations.length) < total,
        );
      }

      throw Exception('Failed to search locations');
    } catch (e) {
      throw Exception('Error searching locations: $e');
    }
  }

  String _extractCountryFromAddress(String address) {
    final parts = address.split(',');
    return parts.isNotEmpty ? parts.last.trim() : 'Unknown';
  }

  LocationType _determineTypeFromTypes(List? types) {
    if (types == null) return LocationType.other;

    final typeStrings = types.map((t) => t.toString().toLowerCase()).toList();

    if (typeStrings.any((t) => t.contains('airport'))) {
      return LocationType.airport;
    } else if (typeStrings
        .any((t) => t.contains('locality') || t.contains('city'))) {
      return LocationType.city;
    } else if (typeStrings.any((t) => t.contains('administrative_area'))) {
      return LocationType.region;
    }

    return LocationType.other;
  }

  LocationType _parseType(String? type) {
    if (type == null) return LocationType.other;
    
    switch (type.toLowerCase()) {
      case 'airport':
        return LocationType.airport;
      case 'city':
        return LocationType.city;
      case 'region':
        return LocationType.region;
      default:
        return LocationType.other;
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

/// Location search result with pagination support
class LocationSearchResult {
  final List<LocationModel> locations;
  final int total;
  final bool hasMore;

  LocationSearchResult({
    required this.locations,
    required this.total,
    required this.hasMore,
  });
}
