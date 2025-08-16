import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_inquiry_model.dart';
import '../../config/env/app_config.dart';

class BookingInquiryService {
  static String get baseUrl => AppConfig.fullBackendUrl;

  // Create a new booking inquiry
  static Future<BookingInquiryModel> createInquiry({
    required String token,
    required CreateBookingInquiryRequest request,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/booking-inquiries'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return BookingInquiryModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create inquiry');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user's booking inquiries
  static Future<List<BookingInquiryModel>> getUserInquiries({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/booking-inquiries'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List)
            .map((item) => BookingInquiryModel.fromJson(item))
            .toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch inquiries');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get a specific booking inquiry
  static Future<BookingInquiryModel> getInquiry({
    required String token,
    required int inquiryId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/booking-inquiries/$inquiryId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BookingInquiryModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch inquiry');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Confirm a booking inquiry
  static Future<Map<String, dynamic>> confirmInquiry({
    required String token,
    required int inquiryId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/booking-inquiries/$inquiryId/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to confirm inquiry');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Cancel a booking inquiry
  static Future<BookingInquiryModel> cancelInquiry({
    required String token,
    required int inquiryId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/booking-inquiries/$inquiryId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BookingInquiryModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to cancel inquiry');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update a booking inquiry
  static Future<BookingInquiryModel> updateInquiry({
    required String token,
    required int inquiryId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/booking-inquiries/$inquiryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BookingInquiryModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update inquiry');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get distance calculation from Google Earth Engine
  static Future<Map<String, dynamic>> getFlightDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
    required String aircraftType,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/google-earth-engine/distance/flight?'
          'lat1=$lat1&lon1=$lon1&lat2=$lat2&lon2=$lon2&aircraftType=$aircraftType',
        ),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to calculate distance');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
