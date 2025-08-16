import '../models/direct_charter_model.dart';
import '../network/api_client.dart';

class DirectCharterService {
  final ApiClient _apiClient = ApiClient();

  // Search for available aircraft for direct charter
  Future<List<DirectCharterAircraft>> searchAvailableAircraft({
    required String origin,
    required String destination,
    required DateTime departureDateTime,
    DateTime? returnDateTime,
    required int passengerCount,
    String tripType = 'oneway',
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/direct-charter/search',
        {
          'origin': origin,
          'destination': destination,
          'departureDateTime': departureDateTime.toIso8601String(),
          if (returnDateTime != null)
            'returnDateTime': returnDateTime.toIso8601String(),
          'passengerCount': passengerCount,
          'tripType': tripType,
        },
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data
            .map((json) => DirectCharterAircraft.fromJson(json))
            .toList();
      } else {
        final message = response['message'];
        if (message is List) {
          throw Exception(message.join(', '));
        } else {
          throw Exception(
              message?.toString() ?? 'Failed to search for available aircraft');
        }
      }
    } catch (e) {
      throw Exception('Error searching for available aircraft: $e');
    }
  }

  // Book a direct charter flight
  Future<DirectCharterBookingResponse> bookDirectCharter({
    required int aircraftId,
    required String origin,
    required String destination,
    required DateTime departureDateTime,
    DateTime? returnDateTime,
    required int passengerCount,
    required double totalPrice,
    required double pricePerHour,
    double? repositioningCost,
    required String tripType,
    String? specialRequests,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/direct-charter/book',
        {
          'aircraftId': aircraftId,
          'origin': origin,
          'destination': destination,
          'departureDateTime': departureDateTime.toIso8601String(),
          if (returnDateTime != null)
            'returnDateTime': returnDateTime.toIso8601String(),
          'passengerCount': passengerCount,
          'totalPrice': totalPrice,
          'pricePerHour': pricePerHour,
          if (repositioningCost != null) 'repositioningCost': repositioningCost,
          'tripType': tripType,
          if (specialRequests != null) 'specialRequests': specialRequests,
        },
      );

      if (response['success'] == true) {
        return DirectCharterBookingResponse.fromJson(response['data']);
      } else {
        final message = response['message'];
        if (message is List) {
          throw Exception(message.join(', '));
        } else {
          throw Exception(
              message?.toString() ?? 'Failed to book direct charter');
        }
      }
    } catch (e) {
      throw Exception('Error booking direct charter: $e');
    }
  }

  // Check service health
  Future<bool> checkHealth() async {
    try {
      final response = await _apiClient.get('/api/direct-charter/health');
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
