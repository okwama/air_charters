import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_trip_model.dart';
import '../error/app_exceptions.dart';
import '../network/api_client.dart';

class TripsService {
  final ApiClient _apiClient = ApiClient();

  /// Get all trips for the current user
  Future<List<UserTripModel>> fetchUserTrips() async {
    try {
      final response = await _apiClient.get('/api/user-trips');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> tripsJson = response['data'] as List;
        return tripsJson.map((json) => UserTripModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw NetworkException('Failed to fetch trips: ${e.toString()}');
    }
  }

  /// Get a specific trip by ID
  Future<UserTripModel> fetchTripById(String tripId) async {
    try {
      final response = await _apiClient.get('/api/user-trips/$tripId');

      if (response['success'] == true && response['data'] != null) {
        return UserTripModel.fromJson(response['data']);
      }

      throw ServerException('Trip not found');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to fetch trip: ${e.toString()}');
    }
  }

  /// Get trips by status
  Future<List<UserTripModel>> fetchTripsByStatus(UserTripStatus status) async {
    try {
      final response =
          await _apiClient.get('/api/user-trips/status/${status.name}');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> tripsJson = response['data'] as List;
        return tripsJson.map((json) => UserTripModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw NetworkException(
          'Failed to fetch trips by status: ${e.toString()}');
    }
  }

  /// Create a new trip
  Future<UserTripModel> createTrip(UserTripModel trip) async {
    try {
      final response = await _apiClient.post(
        '/api/user-trips',
        trip.toCreateJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        return UserTripModel.fromJson(response['data']);
      }

      throw ServerException('Failed to create trip');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to create trip: ${e.toString()}');
    }
  }

  /// Update trip status
  Future<UserTripModel> updateTripStatus(
      String tripId, UserTripStatus status) async {
    try {
      final response = await _apiClient.put('/api/user-trips/$tripId/status', {
        'status': status.name,
      });

      if (response['success'] == true && response['data'] != null) {
        return UserTripModel.fromJson(response['data']);
      }

      throw ServerException('Failed to update trip status');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to update trip status: ${e.toString()}');
    }
  }

  /// Cancel a trip
  Future<UserTripModel> cancelTrip(String tripId) async {
    try {
      final response =
          await _apiClient.put('/api/user-trips/$tripId/cancel', {});

      if (response['success'] == true && response['data'] != null) {
        return UserTripModel.fromJson(response['data']);
      }

      throw ServerException('Failed to cancel trip');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to cancel trip: ${e.toString()}');
    }
  }

  /// Complete a trip
  Future<UserTripModel> completeTrip(String tripId) async {
    try {
      final response =
          await _apiClient.put('/api/user-trips/$tripId/complete', {});

      if (response['success'] == true && response['data'] != null) {
        return UserTripModel.fromJson(response['data']);
      }

      throw ServerException('Failed to complete trip');
    } catch (e) {
      if (e is AppException) rethrow;
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
      final response = await _apiClient.put('/api/user-trips/$tripId/review', {
        'rating': rating,
        'review': review,
        if (photos != null) 'photos': photos,
        if (videos != null) 'videos': videos,
      });

      if (response['success'] == true && response['data'] != null) {
        return UserTripModel.fromJson(response['data']);
      }

      throw ServerException('Failed to add trip review');
    } catch (e) {
      if (e is AppException) rethrow;
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
      final Map<String, dynamic> updateData = {};
      if (rating != null) updateData['rating'] = rating;
      if (review != null) updateData['review'] = review;
      if (photos != null) updateData['photos'] = photos;
      if (videos != null) updateData['videos'] = videos;

      final response =
          await _apiClient.put('/api/user-trips/$tripId/review', updateData);

      if (response['success'] == true && response['data'] != null) {
        return UserTripModel.fromJson(response['data']);
      }

      throw ServerException('Failed to update trip review');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to update trip review: ${e.toString()}');
    }
  }

  /// Delete trip review
  Future<UserTripModel> deleteTripReview(String tripId) async {
    try {
      final response =
          await _apiClient.delete('/api/user-trips/$tripId/review');

      if (response['success'] == true && response['data'] != null) {
        return UserTripModel.fromJson(response['data']);
      }

      throw ServerException('Failed to delete trip review');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to delete trip review: ${e.toString()}');
    }
  }

  /// Get trip statistics for the current user
  Future<Map<String, dynamic>> getTripStatistics() async {
    try {
      final response = await _apiClient.get('/api/user-trips/statistics');

      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }

      return {};
    } catch (e) {
      throw NetworkException(
          'Failed to fetch trip statistics: ${e.toString()}');
    }
  }
}
