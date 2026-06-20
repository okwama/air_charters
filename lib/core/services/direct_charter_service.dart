import '../models/direct_charter_model.dart';
import '../models/booking_stop_model.dart' as booking_stop;
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

  // Create inquiry for direct charter (no price yet)
  Future<DirectCharterBookingResponse> createInquiry({
    required int aircraftId,
    required String origin,
    required String destination,
    double? originLatitude,
    double? originLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    required DateTime departureDateTime,
    DateTime? returnDateTime,
    required int passengerCount,
    double? estimatedPrice, // For reference only
    required double pricePerHour,
    double? repositioningCost,
    required String tripType,
    String? specialRequests,
    List<booking_stop.BookingStopModel>? stops,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/bookings', // Use standard bookings endpoint
        {
          'aircraftId': aircraftId,
          'originName': origin,
          'destinationName': destination,
          if (originLatitude != null) 'originLatitude': originLatitude,
          if (originLongitude != null) 'originLongitude': originLongitude,
          if (destinationLatitude != null)
            'destinationLatitude': destinationLatitude,
          if (destinationLongitude != null)
            'destinationLongitude': destinationLongitude,
          'departureDateTime': departureDateTime.toIso8601String(),
          if (returnDateTime != null)
            'returnDateTime': returnDateTime.toIso8601String(),
          'totalAdults': passengerCount,
          'totalChildren': 0,
          'totalPrice': 0, // INQUIRY - no price yet
          'bookingStatus': 'pending',
          'paymentStatus': 'pending',
          'bookingType': 'direct_charter',
          'tripType': tripType,
          if (specialRequests != null) 'specialRequirements': specialRequests,
          'onboardDining': false,
          'groundTransportation': false,
          'billingRegion': 'US',
          'passengers': [], // Will be added later if needed
          if (stops != null && stops.isNotEmpty)
            'stops': stops
                .map((stop) => {
                      'stopName': stop.stopName,
                      'longitude': stop.longitude,
                      'latitude': stop.latitude,
                      'datetime': stop.datetime?.toIso8601String(),
                      'stopOrder': stop.stopOrder,
                      'locationType': stop.locationType.name,
                      'locationCode': stop.locationCode,
                    })
                .toList(),
        },
      );

      if (response['success'] == true) {
        return DirectCharterBookingResponse.fromJson(response['data']);
      } else {
        final message = response['message'];
        if (message is List) {
          throw Exception(message.join(', '));
        } else {
          throw Exception(message?.toString() ?? 'Failed to create inquiry');
        }
      }
    } catch (e) {
      throw Exception('Error creating inquiry: $e');
    }
  }

  // Book a direct charter flight (used for deals with fixed price)
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
    List<booking_stop.BookingStopModel>? stops,
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
          if (stops != null && stops.isNotEmpty)
            'stops': stops
                .map((stop) => {
                      'stopName': stop.stopName,
                      'longitude': stop.longitude,
                      'latitude': stop.latitude,
                      'datetime': stop.datetime?.toIso8601String(),
                      'stopOrder': stop.stopOrder,
                      'locationType': stop.locationType.name,
                      'locationCode': stop.locationCode,
                    })
                .toList(),
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
