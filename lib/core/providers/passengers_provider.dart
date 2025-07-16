import 'package:flutter/foundation.dart';
import '../models/passenger_model.dart';
import '../services/passengers_service.dart';
import '../error/app_exceptions.dart';
import '../models/user_model.dart';

enum PassengerState {
  initial,
  loading,
  loaded,
  error,
  creating,
  updating,
  deleting,
}

class PassengerProvider with ChangeNotifier {
  final PassengerService _passengerService = PassengerService();

  // State management
  PassengerState _state = PassengerState.initial;
  String? _errorMessage;
  List<PassengerModel> _passengers = [];
  String? _currentBookingId;
  bool _isLocalMode = false; // Track if we're managing passengers locally

  // Getters
  PassengerState get state => _state;
  String? get errorMessage => _errorMessage;
  List<PassengerModel> get passengers => List.unmodifiable(_passengers);
  String? get currentBookingId => _currentBookingId;
  bool get isLoading => _state == PassengerState.loading;
  bool get hasError => _state == PassengerState.error;
  bool get hasPassengers => _passengers.isNotEmpty;
  int get passengerCount => _passengers.length;
  bool get isLocalMode => _isLocalMode;

  // Clear error state
  void clearError() {
    _errorMessage = null;
    if (_state == PassengerState.error) {
      _state = PassengerState.loaded;
      notifyListeners();
    }
  }

  // Load passengers for a specific booking
  Future<void> loadPassengersForBooking(String bookingId) async {
    try {
      _state = PassengerState.loading;
      _errorMessage = null;
      _currentBookingId = bookingId;
      notifyListeners();

      final passengers =
          await _passengerService.fetchPassengersByBookingId(bookingId);

      _passengers = passengers;
      _state = PassengerState.loaded;
      notifyListeners();
    } catch (e) {
      _state = PassengerState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  // Add a new passenger
  Future<bool> addPassenger(PassengerModel passenger) async {
    try {
      _state = PassengerState.creating;
      _errorMessage = null;
      notifyListeners();

      final createdPassenger =
          await _passengerService.createPassenger(passenger);

      _passengers.add(createdPassenger);
      _state = PassengerState.loaded;
      notifyListeners();

      return true;
    } catch (e) {
      _state = PassengerState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Update an existing passenger
  Future<bool> updatePassenger(
      int passengerId, PassengerModel passenger) async {
    try {
      _state = PassengerState.updating;
      _errorMessage = null;
      notifyListeners();

      final updatedPassenger =
          await _passengerService.updatePassenger(passengerId, passenger);

      final index = _passengers.indexWhere((p) => p.id == passengerId);
      if (index != -1) {
        _passengers[index] = updatedPassenger;
      }

      _state = PassengerState.loaded;
      notifyListeners();

      return true;
    } catch (e) {
      _state = PassengerState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Remove a passenger
  Future<bool> removePassenger(int passengerId) async {
    try {
      _state = PassengerState.deleting;
      _errorMessage = null;
      notifyListeners();

      await _passengerService.deletePassenger(passengerId);

      _passengers.removeWhere((p) => p.id == passengerId);
      _state = PassengerState.loaded;
      notifyListeners();

      return true;
    } catch (e) {
      _state = PassengerState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Remove all passengers for current booking
  Future<bool> removeAllPassengers() async {
    if (_currentBookingId == null) return false;

    try {
      _state = PassengerState.deleting;
      _errorMessage = null;
      notifyListeners();

      await _passengerService.deletePassengersByBookingId(_currentBookingId!);

      _passengers.clear();
      _state = PassengerState.loaded;
      notifyListeners();

      return true;
    } catch (e) {
      _state = PassengerState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Get passenger by ID
  PassengerModel? getPassengerById(int passengerId) {
    try {
      return _passengers.firstWhere((p) => p.id == passengerId);
    } catch (e) {
      return null;
    }
  }

  // Check if a passenger with similar name exists
  bool hasPassengerWithName(String firstName, String lastName,
      {int? excludeId}) {
    return _passengers.any((p) =>
        p.id != excludeId &&
        p.firstName.toLowerCase() == firstName.toLowerCase() &&
        p.lastName.toLowerCase() == lastName.toLowerCase());
  }

  // Add method to get primary passenger (user)
  PassengerModel? get primaryPassenger {
    try {
      return _passengers.firstWhere((p) => p.isUser == true);
    } catch (e) {
      return null;
    }
  }
  
  // Add method to get additional passengers
  List<PassengerModel> get additionalPassengers {
    return _passengers.where((p) => p.isUser != true).toList();
  }

  // Initialize for local booking creation (before booking exists)
  void initializeForBooking({UserModel? currentUser}) {
    _isLocalMode = true;
    _state = PassengerState.loaded;
    _errorMessage = null;
    _passengers.clear();
    _currentBookingId = null;

    // Don't add user automatically - backend will handle this
    // Only add additional passengers if any

    notifyListeners();
  }

  // Add passenger locally (for booking creation)
  void addPassengerLocally(PassengerModel passenger) {
    if (_isLocalMode) {
      _passengers.add(passenger.copyWith(
        id: null, // No backend ID yet
        bookingId: 'local_booking', // Temporary booking ID for local management
      ));
      notifyListeners();
    }
  }

  // Update passenger locally
  void updatePassengerLocally(int index, PassengerModel passenger) {
    if (_isLocalMode && index >= 0 && index < _passengers.length) {
      _passengers[index] = passenger.copyWith(
        id: _passengers[index].id, // Keep existing ID if any
        bookingId:
            _passengers[index].bookingId, // Keep existing booking ID if any
      );
      notifyListeners();
    }
  }

  // Remove passenger locally
  void removePassengerLocally(int index) {
    if (_isLocalMode && index >= 0 && index < _passengers.length) {
      _passengers.removeAt(index);
      notifyListeners();
    }
  }

  // Save all local passengers to backend when booking is created
  Future<void> saveLocalPassengersToBooking(String bookingId) async {
    if (!_isLocalMode || _passengers.isEmpty) return;

    try {
      _state = PassengerState.creating;
      _errorMessage = null;
      notifyListeners();

      final savedPassengers = <PassengerModel>[];

      for (final passenger in _passengers) {
        final passengerWithBooking = passenger.copyWith(bookingId: bookingId);
        final savedPassenger =
            await _passengerService.createPassenger(passengerWithBooking);
        savedPassengers.add(savedPassenger);
      }

      _passengers = savedPassengers;
      _currentBookingId = bookingId;
      _isLocalMode = false;
      _state = PassengerState.loaded;
      notifyListeners();
    } catch (e) {
      _state = PassengerState.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  // Reset state (useful when switching bookings)
  void reset() {
    _state = PassengerState.initial;
    _errorMessage = null;
    _passengers.clear();
    _currentBookingId = null;
    _isLocalMode = false;
    notifyListeners();
  }

  // Refresh current passengers
  Future<void> refresh() async {
    if (_currentBookingId != null) {
      await loadPassengersForBooking(_currentBookingId!);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
