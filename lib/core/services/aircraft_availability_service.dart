import '../network/api_client.dart';
import '../logging/app_logger.dart';
import '../models/aircraft_availability_model.dart';

class AircraftAvailabilityService {
  final ApiClient _apiClient = ApiClient();

  /// Get booked dates for a specific aircraft
  Future<List<DateTime>> getBookedDates({
    required int aircraftId,
    required String authToken,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger().log(
        'Fetching booked dates for aircraft $aircraftId',
        level: LogLevel.info,
        category: LogCategory.booking,
      );

      // Build query string
      final queryParams = <String>[];
      if (startDate != null) {
        queryParams.add('startDate=${startDate.toIso8601String()}');
      }
      if (endDate != null) {
        queryParams.add('endDate=${endDate.toIso8601String()}');
      }

      final queryString =
          queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final endpoint =
          '/direct-charter/aircraft/$aircraftId/booked-dates$queryString';

      final response = await _apiClient.get(endpoint);

      if (response != null && response['success'] == true) {
        final bookedDates = (response['data'] as List)
            .map((dateString) => DateTime.parse(dateString))
            .toList();

        AppLogger().log(
          'Successfully fetched ${bookedDates.length} booked dates',
          level: LogLevel.info,
          category: LogCategory.booking,
        );

        return bookedDates;
      } else {
        AppLogger().log(
          'Failed to fetch booked dates: ${response?['message'] ?? 'Unknown error'}',
          level: LogLevel.warning,
          category: LogCategory.booking,
        );
        return [];
      }
    } catch (e) {
      AppLogger().log(
        'Error fetching booked dates',
        level: LogLevel.error,
        category: LogCategory.booking,
        error: e,
      );
      return [];
    }
  }

  /// Check if a specific date is available for booking
  Future<bool> isDateAvailable({
    required int aircraftId,
    required DateTime date,
    required String authToken,
  }) async {
    try {
      final bookedDates = await getBookedDates(
        aircraftId: aircraftId,
        authToken: authToken,
        startDate: DateTime(date.year, date.month, date.day),
        endDate: DateTime(date.year, date.month, date.day, 23, 59, 59),
      );

      return !bookedDates.any((bookedDate) =>
          bookedDate.year == date.year &&
          bookedDate.month == date.month &&
          bookedDate.day == date.day);
    } catch (e) {
      AppLogger().log(
        'Error checking date availability',
        level: LogLevel.error,
        category: LogCategory.booking,
        error: e,
      );
      return true; // Assume available if we can't check
    }
  }

  /// Get availability status for a range of dates
  Future<Map<DateTime, bool>> getAvailabilityStatus({
    required int aircraftId,
    required DateTime startDate,
    required DateTime endDate,
    required String authToken,
  }) async {
    try {
      final bookedDates = await getBookedDates(
        aircraftId: aircraftId,
        authToken: authToken,
        startDate: startDate,
        endDate: endDate,
      );

      final availabilityMap = <DateTime, bool>{};
      DateTime currentDate =
          DateTime(startDate.year, startDate.month, startDate.day);
      final finalDate = DateTime(endDate.year, endDate.month, endDate.day);

      while (currentDate.isBefore(finalDate) ||
          currentDate.isAtSameMomentAs(finalDate)) {
        final isBooked = bookedDates.any((bookedDate) =>
            bookedDate.year == currentDate.year &&
            bookedDate.month == currentDate.month &&
            bookedDate.day == currentDate.day);

        availabilityMap[DateTime(
            currentDate.year, currentDate.month, currentDate.day)] = !isBooked;
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return availabilityMap;
    } catch (e) {
      AppLogger().log(
        'Error getting availability status',
        level: LogLevel.error,
        category: LogCategory.booking,
        error: e,
      );
      return {};
    }
  }

  /// Search for available aircraft for a specific route and dates
  Future<List<AvailableAircraft>> searchAvailableAircraft({
    required int departureLocationId,
    required int arrivalLocationId,
    required DateTime departureDate,
    DateTime? returnDate,
    required int passengerCount,
    required bool isRoundTrip,
  }) async {
    try {
      AppLogger().log(
        'Searching available aircraft for route $departureLocationId -> $arrivalLocationId',
        level: LogLevel.info,
        category: LogCategory.booking,
      );

      final queryParams = <String>[
        'departureLocationId=$departureLocationId',
        'arrivalLocationId=$arrivalLocationId',
        'departureDate=${departureDate.toIso8601String()}',
        'passengerCount=$passengerCount',
        'isRoundTrip=$isRoundTrip',
      ];

      if (returnDate != null) {
        queryParams.add('returnDate=${returnDate.toIso8601String()}');
      }

      final queryString = queryParams.join('&');
      final endpoint = '/aircraft-availability/search?$queryString';

      final response = await _apiClient.get(endpoint);

      if (response != null && response['success'] == true) {
        final aircraftList = (response['data'] as List)
            .map((json) => AvailableAircraft.fromJson(json))
            .toList();

        AppLogger().log(
          'Successfully found ${aircraftList.length} available aircraft',
          level: LogLevel.info,
          category: LogCategory.booking,
        );

        return aircraftList;
      } else {
        AppLogger().log(
          'No aircraft available for the specified criteria',
          level: LogLevel.warning,
          category: LogCategory.booking,
        );
        return [];
      }
    } catch (e) {
      AppLogger().log(
        'Error searching available aircraft',
        level: LogLevel.error,
        category: LogCategory.booking,
        error: e,
      );
      return [];
    }
  }
}
