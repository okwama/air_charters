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
      final response = await _apiClient.post(
          AppConfig.experienceBookingsEndpoint, booking.toJson());

      if (response['success']) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        throw Exception('Failed to create booking: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
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
