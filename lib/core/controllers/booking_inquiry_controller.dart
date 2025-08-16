import 'package:flutter/material.dart';
import '../models/booking_inquiry_model.dart';
import '../services/booking_inquiry_service.dart';
import '../../shared/utils/session_manager.dart';

class BookingInquiryController extends ChangeNotifier {
  List<BookingInquiryModel> _inquiries = [];
  BookingInquiryModel? _currentInquiry;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BookingInquiryModel> get inquiries => _inquiries;
  BookingInquiryModel? get currentInquiry => _currentInquiry;
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
          await BookingInquiryService.getUserInquiries(token: authHeader);
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

      final inquiry = await BookingInquiryService.getInquiry(
        token: authHeader,
        inquiryId: inquiryId,
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
  Future<BookingInquiryModel?> createInquiry(
      CreateBookingInquiryRequest request) async {
    try {
      _setLoading(true);
      _clearError();

      final sessionManager = SessionManager();
      final authHeader = await sessionManager.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception('User not authenticated');
      }

      final inquiry = await BookingInquiryService.createInquiry(
        token: authHeader,
        request: request,
      );

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

      final result = await BookingInquiryService.confirmInquiry(
        token: authHeader,
        inquiryId: inquiryId,
      );

      // Update the inquiry in the list
      final index = _inquiries.indexWhere((i) => i.id == inquiryId);
      if (index != -1) {
        // Refresh the inquiry to get updated status
        final updatedInquiry = await BookingInquiryService.getInquiry(
          token: authHeader,
          inquiryId: inquiryId,
        );
        _inquiries[index] = updatedInquiry;
        if (_currentInquiry?.id == inquiryId) {
          _currentInquiry = updatedInquiry;
        }
        notifyListeners();
      }

      return result;
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

      final updatedInquiry = await BookingInquiryService.cancelInquiry(
        token: authHeader,
        inquiryId: inquiryId,
      );

      // Update the inquiry in the list
      final index = _inquiries.indexWhere((i) => i.id == inquiryId);
      if (index != -1) {
        _inquiries[index] = updatedInquiry;
        if (_currentInquiry?.id == inquiryId) {
          _currentInquiry = updatedInquiry;
        }
        notifyListeners();
      }

      return true;
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

      final updatedInquiry = await BookingInquiryService.updateInquiry(
        token: authHeader,
        inquiryId: inquiryId,
        updates: updates,
      );

      // Update the inquiry in the list
      final index = _inquiries.indexWhere((i) => i.id == inquiryId);
      if (index != -1) {
        _inquiries[index] = updatedInquiry;
        if (_currentInquiry?.id == inquiryId) {
          _currentInquiry = updatedInquiry;
        }
        notifyListeners();
      }

      return true;
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

      final result = await BookingInquiryService.getFlightDistance(
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
  List<BookingInquiryModel> getInquiriesByStatus(String status) {
    return _inquiries
        .where((inquiry) => inquiry.inquiryStatus == status)
        .toList();
  }

  // Get pending inquiries
  List<BookingInquiryModel> get pendingInquiries =>
      getInquiriesByStatus('pending');

  // Get priced inquiries
  List<BookingInquiryModel> get pricedInquiries =>
      getInquiriesByStatus('priced');

  // Get confirmed inquiries
  List<BookingInquiryModel> get confirmedInquiries =>
      getInquiriesByStatus('confirmed');

  // Get cancelled inquiries
  List<BookingInquiryModel> get cancelledInquiries =>
      getInquiriesByStatus('cancelled');
}
