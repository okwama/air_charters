import 'package:flutter/material.dart';
import '../models/booking_inquiry_model.dart';
import '../models/location_model.dart';
import '../services/booking_inquiry_service.dart';
import '../../shared/utils/session_manager.dart';

class BookingInquiryController extends ChangeNotifier {
  List<BookingInquiry> _inquiries = [];
  BookingInquiry? _currentInquiry;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BookingInquiry> get inquiries => _inquiries;
  BookingInquiry? get currentInquiry => _currentInquiry;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get user's inquiries
  Future<void> fetchUserInquiries() async {
    try {
      _setLoading(true);
      _clearError();

      final sessionManager = SessionManager();
      final authHeader = await sessionManager.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception('User not authenticated');
      }

      final inquiries =
          await BookingInquiryService().getUserInquiries(authHeader);
      _inquiries = inquiries;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get a specific inquiry
  Future<void> fetchInquiry(int inquiryId) async {
    try {
      _setLoading(true);
      _clearError();

      final sessionManager = SessionManager();
      final authHeader = await sessionManager.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception('User not authenticated');
      }

      final inquiry = await BookingInquiryService().getInquiryById(
        inquiryId,
        authHeader,
      );
      _currentInquiry = inquiry;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create a new inquiry
  Future<BookingInquiry?> createInquiry({
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
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final sessionManager = SessionManager();
      final authHeader = await sessionManager.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception('User not authenticated');
      }

      final result = await BookingInquiryService().createInquiry(
        aircraftId: aircraftId,
        requestedSeats: requestedSeats,
        origin: origin,
        destination: destination,
        departureDate: departureDate,
        returnDate: returnDate,
        specialRequirements: specialRequirements,
        onboardDining: onboardDining,
        groundTransportation: groundTransportation,
        billingRegion: billingRegion,
        userNotes: userNotes,
        stops: stops,
        authToken: authHeader,
      );

      if (!result.success || result.inquiry == null) {
        throw Exception(result.message);
      }

      final inquiry = result.inquiry!;

      // Add to the list
      _inquiries.insert(0, inquiry);
      _currentInquiry = inquiry;
      notifyListeners();

      return inquiry;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Confirm an inquiry
  Future<Map<String, dynamic>?> confirmInquiry(int inquiryId) async {
    try {
      _setLoading(true);
      _clearError();

      final sessionManager = SessionManager();
      final authHeader = await sessionManager.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception('User not authenticated');
      }

      final result = await BookingInquiryService().confirmInquiry(
        inquiryId,
        authHeader,
      );

      if (result.success && result.inquiry != null) {
        // Update the inquiry in the list
        final index = _inquiries.indexWhere((i) => i.id == inquiryId);
        if (index != -1) {
          _inquiries[index] = result.inquiry!;
          if (_currentInquiry?.id == inquiryId) {
            _currentInquiry = result.inquiry!;
          }
          notifyListeners();
        }
      }

      return {
        'success': result.success,
        'message': result.message,
        'inquiry': result.inquiry?.toJson(),
      };
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel an inquiry
  Future<bool> cancelInquiry(int inquiryId) async {
    try {
      _setLoading(true);
      _clearError();

      final sessionManager = SessionManager();
      final authHeader = await sessionManager.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception('User not authenticated');
      }

      final result = await BookingInquiryService().cancelInquiry(
        inquiryId,
        authHeader,
      );

      if (result.success && result.inquiry != null) {
        // Update the inquiry in the list
        final index = _inquiries.indexWhere((i) => i.id == inquiryId);
        if (index != -1) {
          _inquiries[index] = result.inquiry!;
          if (_currentInquiry?.id == inquiryId) {
            _currentInquiry = result.inquiry!;
          }
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an inquiry
  Future<bool> updateInquiry(
      int inquiryId, Map<String, dynamic> updates) async {
    try {
      _setLoading(true);
      _clearError();

      final sessionManager = SessionManager();
      final authHeader = await sessionManager.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception('User not authenticated');
      }

      final result = await BookingInquiryService().updateInquiry(
        inquiryId,
        updates,
        authHeader,
      );

      if (result.success && result.inquiry != null) {
        // Update the inquiry in the list
        final index = _inquiries.indexWhere((i) => i.id == inquiryId);
        if (index != -1) {
          _inquiries[index] = result.inquiry!;
          if (_currentInquiry?.id == inquiryId) {
            _currentInquiry = result.inquiry!;
          }
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get flight distance calculation
  Future<Map<String, dynamic>?> getFlightDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
    required String aircraftType,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await BookingInquiryService().getFlightDistance(
        lat1: lat1,
        lon1: lon1,
        lat2: lat2,
        lon2: lon2,
        aircraftType: aircraftType,
      );

      return result;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCurrentInquiry() {
    _currentInquiry = null;
    notifyListeners();
  }

  // Get inquiries by status
  List<BookingInquiry> getInquiriesByStatus(String status) {
    return _inquiries
        .where((inquiry) => inquiry.bookingStatus.name == status)
        .toList();
  }

  // Get pending inquiries
  List<BookingInquiry> get pendingInquiries => getInquiriesByStatus('pending');

  // Get priced inquiries
  List<BookingInquiry> get pricedInquiries => getInquiriesByStatus('priced');

  // Get confirmed inquiries
  List<BookingInquiry> get confirmedInquiries =>
      getInquiriesByStatus('confirmed');

  // Get cancelled inquiries
  List<BookingInquiry> get cancelledInquiries =>
      getInquiriesByStatus('cancelled');
}
