import 'package:air_charters/core/network/api_client.dart';
import 'package:air_charters/core/models/experience_booking_model.dart';
import 'package:air_charters/config/env/app_config.dart';

class ExperienceBookingService {
  final ApiClient _apiClient;

  ExperienceBookingService(this._apiClient);

  /// Create a new experience booking
  Future<Map<String, dynamic>> createBooking(
      ExperienceBookingModel booking) async {
    try {
      print('📤 Creating experience booking...');
      print('   - Experience ID: ${booking.experienceId}');
      print('   - Company ID: ${booking.companyId}');

      // Use the standardized bookings endpoint with experience data
      final response = await _apiClient.post('/api/bookings', {
        'bookingType': 'experience', // ✅ Required by backend
        'experienceTemplateId': booking.experienceId, // ✅ Correct field name
        'companyId': booking.companyId, // ✅ Required field
        'totalPrice': booking.totalPrice,
        'subtotal': booking.totalPrice, // Same as totalPrice for experiences
        'taxType': null,
        'taxAmount': 0,
        'departureDateTime': booking.selectedDate.toIso8601String(),
        'totalAdults': booking.passengers.where((p) => p.isAdult).length,
        'totalChildren': booking.passengers.where((p) => p.isChild).length,
        'onboardDining': false,
        'specialRequirements': booking.specialRequests,
        'passengers': booking.passengers.map((p) => p.toJson()).toList(),
      });

      print('✅ Booking response received');
      print('   - Response: $response');

      // Better null safety check
      if (response != null && response['success'] == true) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        final errorMessage = response?['message'] ?? 'Unknown error';
        throw Exception('Failed to create booking: $errorMessage');
      }
    } catch (e) {
      print('❌ Booking creation error: $e');
      rethrow; // Don't wrap in generic exception to preserve specific error types
    }
  }

  /// Get user's experience bookings
  Future<List<Map<String, dynamic>>> getUserBookings() async {
    try {
      final response =
          await _apiClient.get(AppConfig.experienceBookingsEndpoint);

      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('Failed to load bookings: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get booking details by ID
  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    try {
      final response = await _apiClient
          .get('${AppConfig.experienceBookingDetailsEndpoint}/$bookingId');

      if (response['success']) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        throw Exception(
            'Failed to load booking details: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Cancel an experience booking
  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    try {
      final response = await _apiClient.put(
          '${AppConfig.experienceBookingCancelEndpoint}/$bookingId/cancel', {});

      if (response['success']) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        throw Exception('Failed to cancel booking: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get available time slots for an experience
  Future<List<Map<String, dynamic>>> getAvailableTimeSlots(
      int experienceId, DateTime date) async {
    try {
      final response = await _apiClient.get(
          '${AppConfig.experienceSchedulesEndpoint}/$experienceId/schedules?date=${date.toIso8601String().split('T')[0]}');

      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('Failed to load time slots: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Check availability for a specific date and time
  Future<Map<String, dynamic>> checkAvailability(
      int experienceId, DateTime date, String time) async {
    try {
      final response = await _apiClient.post(
          '${AppConfig.experienceAvailabilityEndpoint}/$experienceId/check-availability',
          {
            'date': date.toIso8601String().split('T')[0],
            'time': time,
          });

      if (response['success']) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        throw Exception('Failed to check availability: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get booking confirmation details
  Future<Map<String, dynamic>> getBookingConfirmation(String bookingId) async {
    try {
      final response = await _apiClient.get(
          '${AppConfig.experienceBookingConfirmationEndpoint}/$bookingId/confirmation');

      if (response['success']) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        throw Exception('Failed to load confirmation: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
