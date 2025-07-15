import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../error/app_exceptions.dart';
import '../network/api_client.dart';

class BookingService {
  final ApiClient _apiClient = ApiClient();

  /// Create a new booking with passengers
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final response = await _apiClient.post(
        '/api/bookings',
        booking.toCreateJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Failed to create booking');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to create booking: ${e.toString()}');
    }
  }

  /// Get all bookings for the current user
  Future<List<BookingModel>> fetchUserBookings() async {
    try {
      final response = await _apiClient.get('/api/bookings');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> bookingsJson = response['data'] as List;
        return bookingsJson.map((json) => BookingModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw NetworkException('Failed to fetch bookings: ${e.toString()}');
    }
  }

  /// Get a specific booking by ID
  Future<BookingModel> fetchBookingById(int bookingId) async {
    try {
      final response = await _apiClient.get('/api/bookings/$bookingId');

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Booking not found');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to fetch booking: ${e.toString()}');
    }
  }

  /// Get a booking by reference number
  Future<BookingModel> fetchBookingByReference(String reference) async {
    try {
      final response =
          await _apiClient.get('/api/bookings/reference/$reference');

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Booking not found');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to fetch booking: ${e.toString()}');
    }
  }

  /// Cancel a booking
  Future<BookingModel> cancelBooking(int bookingId) async {
    try {
      final response =
          await _apiClient.put('/api/bookings/$bookingId/cancel', {});

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Failed to cancel booking');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to cancel booking: ${e.toString()}');
    }
  }

  /// Update booking status (admin/system use)
  Future<BookingModel> updateBookingStatus(
      int bookingId, BookingStatus status) async {
    try {
      final response = await _apiClient.put('/api/bookings/$bookingId/status', {
        'status': status.name,
      });

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Failed to update booking status');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
          'Failed to update booking status: ${e.toString()}');
    }
  }

  /// Update payment status
  Future<BookingModel> updatePaymentStatus(
      int bookingId, PaymentStatus status) async {
    try {
      final response =
          await _apiClient.put('/api/bookings/$bookingId/payment-status', {
        'paymentStatus': status.name,
      });

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']);
      }

      throw ServerException('Failed to update payment status');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
          'Failed to update payment status: ${e.toString()}');
    }
  }

  /// Get booking statistics
  Future<Map<String, int>> fetchBookingStats() async {
    try {
      final response = await _apiClient.get('/api/bookings/stats');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return {
          'total': data['total'] as int? ?? 0,
          'pending': data['pending'] as int? ?? 0,
          'confirmed': data['confirmed'] as int? ?? 0,
          'cancelled': data['cancelled'] as int? ?? 0,
          'completed': data['completed'] as int? ?? 0,
        };
      }

      return {};
    } catch (e) {
      throw NetworkException(
          'Failed to fetch booking statistics: ${e.toString()}');
    }
  }
}
