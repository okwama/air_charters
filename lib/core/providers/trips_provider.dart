import 'package:flutter/foundation.dart';
import '../models/user_trip_model.dart';
import '../services/trips_service.dart';
import '../error/app_exceptions.dart';

class TripsProvider extends ChangeNotifier {
  final TripsService _tripsService = TripsService();

  List<UserTripModel> _trips = [];
  List<UserTripModel> _upcomingTrips = [];
  List<UserTripModel> _completedTrips = [];
  List<UserTripModel> _cancelledTrips = [];
  UserTripModel? _selectedTrip;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _statistics = {};

  // Getters
  List<UserTripModel> get trips => _trips;
  List<UserTripModel> get upcomingTrips => _upcomingTrips;
  List<UserTripModel> get completedTrips => _completedTrips;
  List<UserTripModel> get cancelledTrips => _cancelledTrips;
  UserTripModel? get selectedTrip => _selectedTrip;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get statistics => _statistics;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set selected trip
  void setSelectedTrip(UserTripModel? trip) {
    _selectedTrip = trip;
    notifyListeners();
  }

  // Group trips by status
  void _groupTripsByStatus() {
    _upcomingTrips =
        _trips.where((trip) => trip.status == UserTripStatus.upcoming).toList();
    _completedTrips = _trips
        .where((trip) => trip.status == UserTripStatus.completed)
        .toList();
    _cancelledTrips = _trips
        .where((trip) => trip.status == UserTripStatus.cancelled)
        .toList();
  }

  /// Fetch all trips for the current user
  Future<void> fetchUserTrips() async {
    try {
      _setLoading(true);
      _setError(null);

      _trips = await _tripsService.fetchUserTrips();
      _groupTripsByStatus();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  /// Fetch trip by ID
  Future<void> fetchTripById(String tripId) async {
    try {
      _setLoading(true);
      _setError(null);

      final trip = await _tripsService.fetchTripById(tripId);
      setSelectedTrip(trip);

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  /// Fetch trips by status
  Future<void> fetchTripsByStatus(UserTripStatus status) async {
    try {
      _setLoading(true);
      _setError(null);

      final trips = await _tripsService.fetchTripsByStatus(status);

      switch (status) {
        case UserTripStatus.upcoming:
          _upcomingTrips = trips;
          break;
        case UserTripStatus.completed:
          _completedTrips = trips;
          break;
        case UserTripStatus.cancelled:
          _cancelledTrips = trips;
          break;
      }

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  /// Create a new trip
  Future<bool> createTrip(UserTripModel trip) async {
    try {
      _setLoading(true);
      _setError(null);

      final newTrip = await _tripsService.createTrip(trip);
      _trips.add(newTrip);
      _groupTripsByStatus();

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  /// Update trip status
  Future<bool> updateTripStatus(String tripId, UserTripStatus status) async {
    try {
      _setLoading(true);
      _setError(null);

      final updatedTrip = await _tripsService.updateTripStatus(tripId, status);

      // Update the trip in the list
      final index = _trips.indexWhere((trip) => trip.id == tripId);
      if (index != -1) {
        _trips[index] = updatedTrip;
      }

      // Update selected trip if it's the same one
      if (_selectedTrip?.id == tripId) {
        setSelectedTrip(updatedTrip);
      }

      _groupTripsByStatus();

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  /// Cancel a trip
  Future<bool> cancelTrip(String tripId) async {
    try {
      _setLoading(true);
      _setError(null);

      final cancelledTrip = await _tripsService.cancelTrip(tripId);

      // Update the trip in the list
      final index = _trips.indexWhere((trip) => trip.id == tripId);
      if (index != -1) {
        _trips[index] = cancelledTrip;
      }

      // Update selected trip if it's the same one
      if (_selectedTrip?.id == tripId) {
        setSelectedTrip(cancelledTrip);
      }

      _groupTripsByStatus();

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  /// Complete a trip
  Future<bool> completeTrip(String tripId) async {
    try {
      _setLoading(true);
      _setError(null);

      final completedTrip = await _tripsService.completeTrip(tripId);

      // Update the trip in the list
      final index = _trips.indexWhere((trip) => trip.id == tripId);
      if (index != -1) {
        _trips[index] = completedTrip;
      }

      // Update selected trip if it's the same one
      if (_selectedTrip?.id == tripId) {
        setSelectedTrip(completedTrip);
      }

      _groupTripsByStatus();

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  /// Add review and rating to a trip
  Future<bool> addTripReview(
    String tripId, {
    required int rating,
    required String review,
    String? photos,
    String? videos,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final updatedTrip = await _tripsService.addTripReview(
        tripId,
        rating: rating,
        review: review,
        photos: photos,
        videos: videos,
      );

      // Update the trip in the list
      final index = _trips.indexWhere((trip) => trip.id == tripId);
      if (index != -1) {
        _trips[index] = updatedTrip;
      }

      // Update selected trip if it's the same one
      if (_selectedTrip?.id == tripId) {
        setSelectedTrip(updatedTrip);
      }

      _groupTripsByStatus();

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  /// Update trip review
  Future<bool> updateTripReview(
    String tripId, {
    int? rating,
    String? review,
    String? photos,
    String? videos,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final updatedTrip = await _tripsService.updateTripReview(
        tripId,
        rating: rating,
        review: review,
        photos: photos,
        videos: videos,
      );

      // Update the trip in the list
      final index = _trips.indexWhere((trip) => trip.id == tripId);
      if (index != -1) {
        _trips[index] = updatedTrip;
      }

      // Update selected trip if it's the same one
      if (_selectedTrip?.id == tripId) {
        setSelectedTrip(updatedTrip);
      }

      _groupTripsByStatus();

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  /// Delete trip review
  Future<bool> deleteTripReview(String tripId) async {
    try {
      _setLoading(true);
      _setError(null);

      final updatedTrip = await _tripsService.deleteTripReview(tripId);

      // Update the trip in the list
      final index = _trips.indexWhere((trip) => trip.id == tripId);
      if (index != -1) {
        _trips[index] = updatedTrip;
      }

      // Update selected trip if it's the same one
      if (_selectedTrip?.id == tripId) {
        setSelectedTrip(updatedTrip);
      }

      _groupTripsByStatus();

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  /// Fetch trip statistics
  Future<void> fetchTripStatistics() async {
    try {
      _setLoading(true);
      _setError(null);

      _statistics = await _tripsService.getTripStatistics();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  /// Refresh all trip data
  Future<void> refreshTrips() async {
    await fetchUserTrips();
    await fetchTripStatistics();
  }

  /// Clear all data
  void clearData() {
    _trips = [];
    _upcomingTrips = [];
    _completedTrips = [];
    _cancelledTrips = [];
    _selectedTrip = null;
    _statistics = {};
    _error = null;
    notifyListeners();
  }
}
