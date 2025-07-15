import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/passenger_model.dart';
import '../error/app_exceptions.dart';
import '../network/api_client.dart';

class PassengerService {
  final ApiClient _apiClient = ApiClient();

  Future<List<PassengerModel>> fetchPassengersByBookingId(
      String bookingId) async {
    try {
      final response =
          await _apiClient.get('/api/passengers/booking/$bookingId');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> passengersJson = response['data'] as List;
        return passengersJson
            .map((json) => PassengerModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw NetworkException('Failed to fetch passengers: ${e.toString()}');
    }
  }

  Future<PassengerModel> createPassenger(PassengerModel passenger) async {
    try {
      final response = await _apiClient.post(
        '/api/passengers',
        passenger.toCreateJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        return PassengerModel.fromJson(response['data']);
      }

      throw ServerException('Failed to create passenger');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to create passenger: ${e.toString()}');
    }
  }

  Future<PassengerModel> updatePassenger(
      int passengerId, PassengerModel passenger) async {
    try {
      final response = await _apiClient.put(
        '/api/passengers/$passengerId',
        passenger.toUpdateJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        return PassengerModel.fromJson(response['data']);
      }

      throw ServerException('Failed to update passenger');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to update passenger: ${e.toString()}');
    }
  }

  Future<void> deletePassenger(int passengerId) async {
    try {
      await _apiClient.delete('/api/passengers/$passengerId');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to delete passenger: ${e.toString()}');
    }
  }

  Future<void> deletePassengersByBookingId(String bookingId) async {
    try {
      await _apiClient.delete('/api/passengers/booking/$bookingId');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to delete passengers: ${e.toString()}');
    }
  }

  Future<PassengerModel> fetchPassengerById(int passengerId) async {
    try {
      final response = await _apiClient.get('/api/passengers/$passengerId');

      if (response['success'] == true && response['data'] != null) {
        return PassengerModel.fromJson(response['data']);
      }

      throw ServerException('Passenger not found');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Failed to fetch passenger: ${e.toString()}');
    }
  }

  Future<List<PassengerModel>> fetchAllPassengers() async {
    try {
      final response = await _apiClient.get('/api/passengers');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> passengersJson = response['data'] as List;
        return passengersJson
            .map((json) => PassengerModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw NetworkException('Failed to fetch passengers: ${e.toString()}');
    }
  }
}
 