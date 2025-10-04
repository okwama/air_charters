import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_inquiry_model.dart';
import '../models/location_model.dart';
import '../../config/env/app_config.dart';

/// Service for handling booking inquiries
class BookingInquiryService {
  static final BookingInquiryService _instance =
      BookingInquiryService._internal();
  factory BookingInquiryService() => _instance;
  BookingInquiryService._internal();

  final String _baseUrl = AppConfig.backendUrl;

  /// Create a booking inquiry (creates a charter_booking with pending status)
  Future<BookingInquiryResult> createInquiry({
    required int aircraftId,
    required int requestedSeats,
    required LocationModel origin,
    required LocationModel destination,
    required DateTime departureDate,
    DateTime? returnDate,
    String? specialRequirements,
    bool onboardDining = false,
    bool groundTransportation = false,
    String? billingRegion,
    String? userNotes,
    List<LocationModel>? stops,
    required String authToken,
    String bookingType = 'direct', // 'direct', 'deal', 'experience'
    int? dealId,
    int? experienceScheduleId,
    double? estimatedPrice,
    List<Map<String, dynamic>>? passengers, // Add passenger data
  }) async {
    try {
      // Debug logging for stops
      print('=== BOOKING INQUIRY SERVICE: STOPS DEBUG ===');
      print('stops parameter: $stops');
      print('stops is null: ${stops == null}');
      print('stops is empty: ${stops?.isEmpty ?? true}');
      print('stops length: ${stops?.length ?? 0}');
      
      // Prepare booking stops
      List<CreateBookingStopRequest> bookingStops = [];

      // Add origin as first stop
      bookingStops.add(CreateBookingStopRequest(
        stopName: origin.name,
        longitude: origin.longitude!,
        latitude: origin.latitude!,
        datetime: departureDate.toIso8601String(),
        stopOrder: 1,
        locationCode: origin.code,
      ));

      // Add intermediate stops if any
      if (stops != null && stops.isNotEmpty) {
        for (int i = 0; i < stops.length; i++) {
          bookingStops.add(CreateBookingStopRequest(
            stopName: stops[i].name,
            longitude: stops[i].longitude!,
            latitude: stops[i].latitude!,
            datetime:
                departureDate.add(Duration(hours: i + 1)).toIso8601String(),
            stopOrder: i + 2,
            locationCode: stops[i].code,
          ));
        }
      }

      // Add destination as last stop
      bookingStops.add(CreateBookingStopRequest(
        stopName: destination.name,
        longitude: destination.longitude!,
        latitude: destination.latitude!,
        datetime: returnDate?.toIso8601String() ??
            departureDate
                .add(Duration(hours: stops?.length ?? 1))
                .toIso8601String(),
        stopOrder: (stops?.length ?? 0) + 2,
        locationCode: destination.code,
      ));

      // Determine endpoint and request body based on booking type
      String endpoint;
      Map<String, dynamic> requestBody;

      switch (bookingType.toLowerCase()) {
        case 'direct':
          // Use direct-charter endpoint for direct aircraft bookings
          endpoint = '$_baseUrl/api/direct-charter/book';
          requestBody = {
            'aircraftId': aircraftId,
            'origin': origin.name,
            'destination': destination.name,
            'departureDateTime': departureDate.toIso8601String(),
            'returnDateTime': returnDate?.toIso8601String(),
            'passengerCount': requestedSeats,
            'totalPrice':
                0.0, // Always 0 for inquiries - admin will set final price
            'pricePerHour': 0.0, // Will be calculated by admin
            'repositioningCost': 0.0,
            'tripType': returnDate != null ? 'roundtrip' : 'oneway',
            'specialRequests': specialRequirements,
            'passengers': passengers ?? [], // Include passenger data
          };
          
          // Add stops if provided
          if (stops != null && stops.isNotEmpty) {
            print('=== BOOKING INQUIRY: ADDING STOPS ===');
            print('Stops count: ${stops.length}');
            print('Stops: $stops');
            
            requestBody['stops'] = stops.map((stop) => {
              'stopName': stop.name,
              'longitude': stop.longitude ?? 0.0,
              'latitude': stop.latitude ?? 0.0,
              'datetime': departureDate.add(Duration(hours: stops.indexOf(stop) + 1)).toIso8601String(),
              'stopOrder': stops.indexOf(stop) + 1,
              'locationType': 'custom',
              'locationCode': stop.code,
            }).toList();
            
            print('Processed stops for request: ${requestBody['stops']}');
          } else {
            print('=== BOOKING INQUIRY: NO STOPS PROVIDED ===');
          }
          break;

        case 'deal':
          // Use bookings endpoint for deal-based bookings
          endpoint = '$_baseUrl/api/bookings';
          requestBody = {
            'dealId': dealId ?? 0,
            'totalPrice': estimatedPrice ?? 0.0,
            'onboardDining': onboardDining,
            'specialRequirements': specialRequirements,
            'billingRegion': billingRegion,
            'passengers': [], // Will be populated by backend
          };
          break;

        case 'experience':
          // Use bookings endpoint for experience bookings
          endpoint = '$_baseUrl/api/bookings';
          requestBody = {
            'dealId': 0, // No deal for experiences
            'experienceScheduleId':
                aircraftId, // Use aircraftId as experienceScheduleId for experiences
            'totalPrice': estimatedPrice ?? 0.0,
            'onboardDining': onboardDining,
            'specialRequirements': specialRequirements,
            'billingRegion': billingRegion,
            'passengers': [], // Will be populated by backend
          };
          break;

        default:
          // Default to direct charter
          endpoint = '$_baseUrl/api/direct-charter/book';
          requestBody = {
            'aircraftId': aircraftId,
            'origin': origin.name,
            'destination': destination.name,
            'departureDateTime': departureDate.toIso8601String(),
            'returnDateTime': returnDate?.toIso8601String(),
            'passengerCount': requestedSeats,
            'totalPrice':
                0.0, // Always 0 for inquiries - admin will set final price
            'pricePerHour': 0.0,
            'repositioningCost': 0.0,
            'tripType': returnDate != null ? 'roundtrip' : 'oneway',
            'specialRequests': specialRequirements,
          };
          
          // Add stops if provided
          if (stops != null && stops.isNotEmpty) {
            print('=== BOOKING INQUIRY: ADDING STOPS ===');
            print('Stops count: ${stops.length}');
            print('Stops: $stops');
            
            requestBody['stops'] = stops.map((stop) => {
              'stopName': stop.name,
              'longitude': stop.longitude ?? 0.0,
              'latitude': stop.latitude ?? 0.0,
              'datetime': departureDate.add(Duration(hours: stops.indexOf(stop) + 1)).toIso8601String(),
              'stopOrder': stops.indexOf(stop) + 1,
              'locationType': 'custom',
              'locationCode': stop.code,
            }).toList();
            
            print('Processed stops for request: ${requestBody['stops']}');
          } else {
            print('=== BOOKING INQUIRY: NO STOPS PROVIDED ===');
          }
      }

      // Log the request details
      print('=== BOOKING INQUIRY REQUEST ===');
      print('Endpoint: $endpoint');
      print('Booking Type: $bookingType');
      print('Request Body: ${jsonEncode(requestBody)}');
      print('Headers: ${{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken.substring(0, 20)}...',
      }}');

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      // Log the response details
      print('=== BOOKING INQUIRY RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('=== PARSING SUCCESS RESPONSE ===');
        print('Response Data: $responseData');

        // Handle different response structures based on booking type
        Map<String, dynamic> inquiryData;
        if (bookingType.toLowerCase() == 'direct') {
          // Direct charter returns booking data nested under 'booking' key
          inquiryData = responseData['data']?['booking'] ?? responseData['data'] ?? responseData;
          print('Direct charter - Using data: ${responseData['data']?['booking'] != null ? 'responseData[\'data\'][\'booking\']' : 'responseData[\'data\']'}');
        } else {
          // Deal/experience bookings return structured response
          inquiryData = responseData['data']?['booking'] ?? responseData;
          print('Deal/Experience - Using data: ${responseData['data']?['booking'] != null ? 'responseData[\'data\'][\'booking\']' : 'responseData'}');
        }

        print('Final inquiry data: $inquiryData');
        print('Inquiry ID: ${inquiryData['id']}');
        print('Reference Number: ${inquiryData['referenceNumber']}');

        // Ensure inquiryData has required fields
        if (inquiryData['id'] == null || inquiryData['referenceNumber'] == null) {
          print('ERROR: Missing required fields in inquiry data');
          print('Available keys in inquiryData: ${inquiryData.keys.toList()}');
          return BookingInquiryResult(
            success: false,
            message: 'Invalid response data from server',
          );
        }

        try {
          final inquiry = BookingInquiry.fromJson(inquiryData);
          print('Successfully parsed BookingInquiry: ${inquiry.referenceNumber}');
          
          return BookingInquiryResult(
            success: true,
            inquiry: inquiry,
            message: responseData['message'] ?? 'Inquiry created successfully',
          );
        } catch (e) {
          print('ERROR parsing BookingInquiry: $e');
          return BookingInquiryResult(
            success: false,
            message: 'Failed to parse inquiry data: $e',
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        print('=== ERROR RESPONSE ===');
        print('Error Data: $errorData');
        
        return BookingInquiryResult(
          success: false,
          message: errorData['message'] ?? 'Failed to create inquiry',
        );
      }
    } catch (e) {
      print('=== BOOKING INQUIRY ERROR ===');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('Stack Trace: ${StackTrace.current}');
      
      return BookingInquiryResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Create a direct charter inquiry
  Future<BookingInquiryResult> createDirectCharterInquiry({
    required int aircraftId,
    required int requestedSeats,
    required LocationModel origin,
    required LocationModel destination,
    required DateTime departureDate,
    DateTime? returnDate,
    String? specialRequirements,
    bool onboardDining = false,
    String? billingRegion,
    String? userNotes,
    required String authToken,
    double? estimatedPrice,
  }) async {
    return createInquiry(
      aircraftId: aircraftId,
      requestedSeats: requestedSeats,
      origin: origin,
      destination: destination,
      departureDate: departureDate,
      returnDate: returnDate,
      specialRequirements: specialRequirements,
      onboardDining: onboardDining,
      billingRegion: billingRegion,
      userNotes: userNotes,
      authToken: authToken,
      bookingType: 'direct',
      estimatedPrice: estimatedPrice,
    );
  }

  /// Create a deal-based inquiry
  Future<BookingInquiryResult> createDealInquiry({
    required int dealId,
    required int requestedSeats,
    String? specialRequirements,
    bool onboardDining = false,
    String? billingRegion,
    String? userNotes,
    required String authToken,
    double? estimatedPrice,
  }) async {
    return createInquiry(
      aircraftId: 0, // Not needed for deal bookings
      requestedSeats: requestedSeats,
      origin: LocationModel(
        id: 0,
        name: 'N/A',
        code: 'N/A',
        country: 'N/A',
        type: LocationType.other,
        latitude: 0,
        longitude: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ), // Not needed for deal bookings
      destination: LocationModel(
        id: 0,
        name: 'N/A',
        code: 'N/A',
        country: 'N/A',
        type: LocationType.other,
        latitude: 0,
        longitude: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ), // Not needed for deal bookings
      departureDate: DateTime.now(), // Not needed for deal bookings
      specialRequirements: specialRequirements,
      onboardDining: onboardDining,
      billingRegion: billingRegion,
      userNotes: userNotes,
      authToken: authToken,
      bookingType: 'deal',
      dealId: dealId,
      estimatedPrice: estimatedPrice,
    );
  }

  /// Create an experience inquiry
  Future<BookingInquiryResult> createExperienceInquiry({
    required int experienceScheduleId,
    required int requestedSeats,
    String? specialRequirements,
    bool onboardDining = false,
    String? billingRegion,
    String? userNotes,
    required String authToken,
    double? estimatedPrice,
  }) async {
    return createInquiry(
      aircraftId: 0, // Not needed for experience bookings
      requestedSeats: requestedSeats,
      origin: LocationModel(
        id: 0,
        name: 'N/A',
        code: 'N/A',
        country: 'N/A',
        type: LocationType.other,
        latitude: 0,
        longitude: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ), // Not needed for experience bookings
      destination: LocationModel(
        id: 0,
        name: 'N/A',
        code: 'N/A',
        country: 'N/A',
        type: LocationType.other,
        latitude: 0,
        longitude: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ), // Not needed for experience bookings
      departureDate: DateTime.now(), // Not needed for experience bookings
      specialRequirements: specialRequirements,
      onboardDining: onboardDining,
      billingRegion: billingRegion,
      userNotes: userNotes,
      authToken: authToken,
      bookingType: 'experience',
      experienceScheduleId: experienceScheduleId,
      estimatedPrice: estimatedPrice,
    );
  }

  /// Get user's inquiries (charter_bookings with pending/priced status)
  Future<List<BookingInquiry>> getUserInquiries(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/bookings?status=pending,priced'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BookingInquiry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch inquiries');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get inquiry by ID (charter_booking by ID)
  Future<BookingInquiry> getInquiryById(int inquiryId, String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/bookings/$inquiryId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BookingInquiry.fromJson(data);
      } else {
        throw Exception('Failed to fetch inquiry');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Confirm an inquiry (update charter_booking status to confirmed)
  Future<BookingInquiryResult> confirmInquiry(
      int inquiryId, String authToken) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/charter-bookings/$inquiryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'bookingStatus': 'confirmed',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BookingInquiryResult(
          success: true,
          inquiry: BookingInquiry.fromJson(responseData),
          message: 'Inquiry confirmed successfully',
        );
      } else {
        final errorData = jsonDecode(response.body);
        return BookingInquiryResult(
          success: false,
          message: errorData['message'] ?? 'Failed to confirm inquiry',
        );
      }
    } catch (e) {
      return BookingInquiryResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Cancel an inquiry (update charter_booking status to cancelled)
  Future<BookingInquiryResult> cancelInquiry(
      int inquiryId, String authToken) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/charter-bookings/$inquiryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'bookingStatus': 'cancelled',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BookingInquiryResult(
          success: true,
          inquiry: BookingInquiry.fromJson(responseData),
          message: 'Inquiry cancelled successfully',
        );
      } else {
        final errorData = jsonDecode(response.body);
        return BookingInquiryResult(
          success: false,
          message: errorData['message'] ?? 'Failed to cancel inquiry',
        );
      }
    } catch (e) {
      return BookingInquiryResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Update an inquiry
  Future<BookingInquiryResult> updateInquiry(
      int inquiryId, Map<String, dynamic> updates, String authToken) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/charter-bookings/$inquiryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BookingInquiryResult(
          success: true,
          inquiry: BookingInquiry.fromJson(responseData),
          message: 'Inquiry updated successfully',
        );
      } else {
        final errorData = jsonDecode(response.body);
        return BookingInquiryResult(
          success: false,
          message: errorData['message'] ?? 'Failed to update inquiry',
        );
      }
    } catch (e) {
      return BookingInquiryResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Get flight distance calculation
  Future<Map<String, dynamic>?> getFlightDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
    required String aircraftType,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/flight-distance?lat1=$lat1&lon1=$lon1&lat2=$lat2&lon2=$lon2&aircraftType=$aircraftType'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get aircraft availability for inquiry dates
  Future<Map<String, dynamic>> getAircraftAvailabilityForInquiry({
    required int aircraftId,
    required DateTime startDate,
    required DateTime endDate,
    required String authToken,
  }) async {
    try {
      final queryParams = {
        'startDate':
            startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
        'endDate': endDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      };

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/booking-inquiries/aircraft/$aircraftId/availability?$queryString'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get aircraft availability');
      }
    } catch (e) {
      throw Exception('Error getting aircraft availability: $e');
    }
  }

  /// Check if aircraft is available for inquiry dates
  Future<bool> isAircraftAvailableForInquiry({
    required int aircraftId,
    required DateTime departureDate,
    DateTime? returnDate,
    required String authToken,
  }) async {
    try {
      final endDate = returnDate ?? departureDate;
      final availability = await getAircraftAvailabilityForInquiry(
        aircraftId: aircraftId,
        startDate: departureDate,
        endDate: endDate,
        authToken: authToken,
      );

      final availabilityData =
          availability['data']['availability'] as Map<String, dynamic>;

      // Check if all dates in the range are available
      DateTime currentDate = departureDate;
      while (currentDate.isBefore(endDate) ||
          currentDate.isAtSameMomentAs(endDate)) {
        final dateKey = currentDate.toIso8601String().split('T')[0];
        if (availabilityData[dateKey]?['isAvailable'] != true) {
          return false;
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return true;
    } catch (e) {
      throw Exception('Error checking aircraft availability: $e');
    }
  }

  /// Get available dates for aircraft in a month (for inquiry)
  Future<List<DateTime>> getAvailableDatesForInquiry({
    required int aircraftId,
    required DateTime month, // Any date in the target month
    required String authToken,
  }) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      final availability = await getAircraftAvailabilityForInquiry(
        aircraftId: aircraftId,
        startDate: startOfMonth,
        endDate: endOfMonth,
        authToken: authToken,
      );

      final availableDates = <DateTime>[];
      final availabilityData =
          availability['data']['availability'] as Map<String, dynamic>;

      availabilityData.forEach((dateKey, dayData) {
        if (dayData['isAvailable'] == true) {
          availableDates.add(DateTime.parse(dateKey));
        }
      });

      return availableDates;
    } catch (e) {
      throw Exception('Error getting available dates: $e');
    }
  }
}

/// Result of booking inquiry operations
class BookingInquiryResult {
  final bool success;
  final BookingInquiry? inquiry;
  final String message;

  BookingInquiryResult({
    required this.success,
    this.inquiry,
    required this.message,
  });
}
