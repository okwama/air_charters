import '../models/google_earth_location_model.dart';
import '../network/api_client.dart';

class GoogleEarthEngineService {
  final ApiClient _apiClient = ApiClient();

  Future<List<GoogleEarthLocationModel>> searchLocations(String query) async {
    try {
      print('🔍 GoogleEarthEngineService: Searching for "$query"');
      final response = await _apiClient
          .get('/api/google-earth-engine/search/locations?query=$query');

      print('🔍 GoogleEarthEngineService: Raw response type: ${response.runtimeType}');
      print('🔍 GoogleEarthEngineService: Raw response: $response');

      // Handle both response formats: direct array or wrapped in success/data
      List<dynamic> data;
      if (response is List) {
        // Direct array response
        data = response;
        print('🔍 GoogleEarthEngineService: Using direct array response, length: ${data.length}');
      } else if (response['success'] == true) {
        // Wrapped response
        data = response['data'] ?? [];
        print('🔍 GoogleEarthEngineService: Using wrapped response, data length: ${data.length}');
      } else {
        print('🔍 GoogleEarthEngineService: Error response: $response');
        throw Exception('Failed to search locations: ${response['message'] ?? 'Unknown error'}');
      }

      final results = data
          .map((json) => GoogleEarthLocationModel.fromJson(json))
          .toList();
      
      print('🔍 GoogleEarthEngineService: Parsed ${results.length} results');
      return results;
    } catch (e) {
      print('🔍 GoogleEarthEngineService: Search error: $e');
      throw Exception('Search failed: $e');
    }
  }

  Future<List<GoogleEarthLocationModel>> reverseGeocode(
      double latitude, double longitude) async {
    try {
      print('🔍 GoogleEarthEngineService: Reverse geocoding lat: $latitude, lng: $longitude');
      final response = await _apiClient.get(
          '/api/google-earth-engine/geocode/reverse?latitude=$latitude&longitude=$longitude');

      print('🔍 GoogleEarthEngineService: Reverse geocode response type: ${response.runtimeType}');
      print('🔍 GoogleEarthEngineService: Reverse geocode response: $response');

      // Handle different response formats
      List<dynamic> data;
      if (response is List) {
        // Direct array response
        data = response;
        print('🔍 GoogleEarthEngineService: Using direct array response, length: ${data.length}');
      } else if (response is Map && response.containsKey('placeId')) {
        // Single object response (most common for reverse geocoding)
        data = [response];
        print('🔍 GoogleEarthEngineService: Using single object response');
      } else if (response['success'] == true) {
        // Wrapped response
        data = response['data'] ?? [];
        print('🔍 GoogleEarthEngineService: Using wrapped response, data length: ${data.length}');
      } else {
        print('🔍 GoogleEarthEngineService: Error response: $response');
        throw Exception('Failed to reverse geocode: ${response['message'] ?? 'Unknown error'}');
      }

      final results = data
          .map((json) => GoogleEarthLocationModel.fromJson(json))
          .toList();
      
      print('🔍 GoogleEarthEngineService: Parsed ${results.length} reverse geocode results');
      return results;
    } catch (e) {
      print('🔍 GoogleEarthEngineService: Reverse geocode error: $e');
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
      final response = await _apiClient.get(
          '/api/google-earth-engine/distance/calculate?origin[lat]=$originLat&origin[lng]=$originLng&destination[lat]=$destinationLat&destination[lng]=$destinationLng&mode=$mode');

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
      final response = await _apiClient.get(
          '/api/google-earth-engine/distance/flight?lat1=$lat1&lon1=$lon1&lat2=$lat2&lon2=$lon2&aircraftType=$aircraftType');

      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(
            'Failed to calculate flight distance: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Flight distance calculation failed: $e');
    }
  }
}
