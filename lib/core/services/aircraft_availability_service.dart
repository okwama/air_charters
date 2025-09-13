import '../models/aircraft_availability_model.dart';
import '../network/api_client.dart';

class AircraftAvailabilityService {
  final ApiClient _apiClient = ApiClient();

  /// Search for available aircraft
  Future<List<AvailableAircraft>> searchAvailableAircraft({
    required int departureLocationId,
    required int arrivalLocationId,
    required DateTime departureDate,
    DateTime? returnDate,
    required int passengerCount,
    bool isRoundTrip = false,
  }) async {
    try {
      final searchData = {
        'departureLocationId': departureLocationId,
        'arrivalLocationId': arrivalLocationId,
        'departureDate': departureDate.toIso8601String(),
        'returnDate': returnDate?.toIso8601String(),
        'passengerCount': passengerCount,
        'isRoundTrip': isRoundTrip,
      };

      final response = await _apiClient.post(
          '/api/aircraft-availability/search', searchData);

      // Handle direct array response from backend
      if (response is List) {
        final aircraft = (response)
            .map((json) => AvailableAircraft.fromJson(json))
            .toList();
        return aircraft;
      }

      // Handle wrapped response format (if backend changes in future)
      if (response is Map && response['success'] == true) {
        final aircraft = (response['data'] as List)
            .map((json) => AvailableAircraft.fromJson(json))
            .toList();
        return aircraft;
      }

      throw Exception('Failed to search available aircraft');
    } catch (e) {
      throw Exception('Error searching available aircraft: $e');
    }
  }

  /// Check if specific aircraft is available
  Future<bool> checkAircraftAvailability({
    required int aircraftId,
    required DateTime startDate,
    required DateTime endDate,
    int? departureLocationId,
    int? arrivalLocationId,
  }) async {
    try {
      final queryParams = {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (departureLocationId != null)
          'departureLocationId': departureLocationId.toString(),
        if (arrivalLocationId != null)
          'arrivalLocationId': arrivalLocationId.toString(),
      };

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient
          .get('/api/aircraft-availability/check/$aircraftId?$queryString');

      if (response['success'] == true) {
        return response['data']['isAvailable'] ?? false;
      }

      throw Exception('Failed to check aircraft availability');
    } catch (e) {
      throw Exception('Error checking aircraft availability: $e');
    }
  }

  /// Create availability block for booking
  Future<void> createAvailabilityBlock({
    required int aircraftId,
    required String bookingId,
    required DateTime startDate,
    required DateTime endDate,
    required int departureLocationId,
    required int arrivalLocationId,
    required String bookingReference,
  }) async {
    try {
      final blockData = {
        'aircraftId': aircraftId,
        'bookingId': bookingId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'departureLocationId': departureLocationId,
        'arrivalLocationId': arrivalLocationId,
        'bookingReference': bookingReference,
      };

      await _apiClient.post('/api/aircraft-availability/block', blockData);
    } catch (e) {
      throw Exception('Error creating availability block: $e');
    }
  }

  /// Remove availability block for booking
  Future<void> removeAvailabilityBlock(String bookingId) async {
    try {
      await _apiClient.delete('/api/aircraft-availability/block/$bookingId');
    } catch (e) {
      throw Exception('Error removing availability block: $e');
    }
  }
}
