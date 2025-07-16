import '../../models/user_trip_model.dart';
import '../../services/trips_service.dart';
import '../../error/app_exceptions.dart';

class TripsController {
  final TripsService _tripsService = TripsService();

  /// Get all trips for the current user
  Future<List<UserTripModel>> getUserTrips() async {
    try {
      return await _tripsService.fetchUserTrips();
    } catch (e) {
      throw NetworkException('Failed to fetch user trips: ${e.toString()}');
    }
  }

  /// Get a specific trip by ID
  Future<UserTripModel?> getTripById(String tripId) async {
    try {
      return await _tripsService.fetchTripById(tripId);
    } catch (e) {
      if (e is ServerException && e.message.contains('not found')) {
        return null;
      }
      throw NetworkException('Failed to fetch trip: ${e.toString()}');
    }
  }

  /// Get trips by status
  Future<List<UserTripModel>> getTripsByStatus(UserTripStatus status) async {
    try {
      return await _tripsService.fetchTripsByStatus(status);
    } catch (e) {
      throw NetworkException(
          'Failed to fetch trips by status: ${e.toString()}');
    }
  }

  /// Create a new trip
  Future<UserTripModel> createTrip(UserTripModel trip) async {
    try {
      return await _tripsService.createTrip(trip);
    } catch (e) {
      throw NetworkException('Failed to create trip: ${e.toString()}');
    }
  }

  /// Update trip status
  Future<UserTripModel> updateTripStatus(
      String tripId, UserTripStatus status) async {
    try {
      return await _tripsService.updateTripStatus(tripId, status);
    } catch (e) {
      throw NetworkException('Failed to update trip status: ${e.toString()}');
    }
  }

  /// Cancel a trip
  Future<UserTripModel> cancelTrip(String tripId) async {
    try {
      return await _tripsService.cancelTrip(tripId);
    } catch (e) {
      throw NetworkException('Failed to cancel trip: ${e.toString()}');
    }
  }

  /// Complete a trip
  Future<UserTripModel> completeTrip(String tripId) async {
    try {
      return await _tripsService.completeTrip(tripId);
    } catch (e) {
      throw NetworkException('Failed to complete trip: ${e.toString()}');
    }
  }

  /// Add review and rating to a trip
  Future<UserTripModel> addTripReview(
    String tripId, {
    required int rating,
    required String review,
    String? photos,
    String? videos,
  }) async {
    try {
      return await _tripsService.addTripReview(
        tripId,
        rating: rating,
        review: review,
        photos: photos,
        videos: videos,
      );
    } catch (e) {
      throw NetworkException('Failed to add trip review: ${e.toString()}');
    }
  }

  /// Update trip review
  Future<UserTripModel> updateTripReview(
    String tripId, {
    int? rating,
    String? review,
    String? photos,
    String? videos,
  }) async {
    try {
      return await _tripsService.updateTripReview(
        tripId,
        rating: rating,
        review: review,
        photos: photos,
        videos: videos,
      );
    } catch (e) {
      throw NetworkException('Failed to update trip review: ${e.toString()}');
    }
  }

  /// Delete trip review
  Future<UserTripModel> deleteTripReview(String tripId) async {
    try {
      return await _tripsService.deleteTripReview(tripId);
    } catch (e) {
      throw NetworkException('Failed to delete trip review: ${e.toString()}');
    }
  }

  /// Get trip statistics
  Future<Map<String, dynamic>> getTripStatistics() async {
    try {
      return await _tripsService.getTripStatistics();
    } catch (e) {
      throw NetworkException(
          'Failed to fetch trip statistics: ${e.toString()}');
    }
  }
}
