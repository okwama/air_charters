import '../models/google_earth_location_model.dart';
import '../network/api_client.dart';

class GoogleEarthEngineService {
  final ApiClient _apiClient = ApiClient();

  Future<List<GoogleEarthLocationModel>> searchLocations(String query) async {
    try {
      final response = await _apiClient.get('/api/google-earth-engine/search/locations?query=$query');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => GoogleEarthLocationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search locations: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  Future<List<GoogleEarthLocationModel>> reverseGeocode(double latitude, double longitude) async {
    try {
      final response = await _apiClient.get('/api/google-earth-engine/geocode/reverse?latitude=$latitude&longitude=$longitude');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => GoogleEarthLocationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to reverse geocode: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Reverse geocoding failed: $e');
    }
  }

  Future<Map<String, dynamic>> calculateDistance({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    String mode = 'driving',
  }) async {
    try {
      final response = await _apiClient.get('/api/google-earth-engine/distance/calculate?origin[lat]=$originLat&origin[lng]=$originLng&destination[lat]=$destinationLat&destination[lng]=$destinationLng&mode=$mode');

      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception('Failed to calculate distance: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Distance calculation failed: $e');
    }
  }

  Future<Map<String, dynamic>> calculateFlightDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
    String aircraftType = 'jet',
  }) async {
    try {
      final response = await _apiClient.get('/api/google-earth-engine/distance/flight?lat1=$lat1&lon1=$lon1&lat2=$lat2&lon2=$lon2&aircraftType=$aircraftType');

      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception('Failed to calculate flight distance: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Flight distance calculation failed: $e');
    }
  }
} 