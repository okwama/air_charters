import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/env/app_config.dart';
import '../error/network_error_handler.dart';

class AircraftTypeService {
  static final AircraftTypeService _instance = AircraftTypeService._internal();
  factory AircraftTypeService() => _instance;
  AircraftTypeService._internal();

  /// Fetch all aircraft type placeholders
  Future<List<AircraftType>> getAircraftTypes() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/direct-charter/aircraft-types'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.authToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> aircraftTypesJson = data['data'];
          return aircraftTypesJson
              .map((json) => AircraftType.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch aircraft types');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching aircraft types: $e');
      // Convert to user-friendly network error
      final networkError = NetworkErrorResult.fromException(e);
      throw NetworkException(networkError.message, networkError);
    }
  }

  /// Fetch available aircraft by type
  Future<List<Aircraft>> getAircraftByType({
    int? typeId,
    String? userLocation,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (typeId != null) queryParams['typeId'] = typeId.toString();
      if (userLocation != null) queryParams['userLocation'] = userLocation;

      final uri = Uri.parse('${AppConfig.baseUrl}/api/direct-charter/aircraft')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.authToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> aircraftJson = data['data'];
          return aircraftJson.map((json) => Aircraft.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch aircraft');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching aircraft by type: $e');
      // Convert to user-friendly network error
      final networkError = NetworkErrorResult.fromException(e);
      throw NetworkException(networkError.message, networkError);
    }
  }
}

/// Aircraft type model
class AircraftType {
  final int id;
  final String type;
  final String? description;
  final String? placeholderImageUrl;

  AircraftType({
    required this.id,
    required this.type,
    this.description,
    this.placeholderImageUrl,
  });

  factory AircraftType.fromJson(Map<String, dynamic> json) {
    return AircraftType(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      placeholderImageUrl: json['placeholderImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'placeholderImageUrl': placeholderImageUrl,
    };
  }
}

/// Aircraft model
class Aircraft {
  final int id;
  final String name;
  final String model;
  final int capacity;
  final double pricePerHour;
  final String? baseAirport;
  final String? baseCity;
  final int? companyId;
  final String companyName;
  final String? imageUrl;
  final String aircraftType;
  final double flightDurationHours;

  Aircraft({
    required this.id,
    required this.name,
    required this.model,
    required this.capacity,
    required this.pricePerHour,
    this.baseAirport,
    this.baseCity,
    this.companyId,
    required this.companyName,
    this.imageUrl,
    required this.aircraftType,
    required this.flightDurationHours,
  });

  factory Aircraft.fromJson(Map<String, dynamic> json) {
    return Aircraft(
      id: json['id'],
      name: json['name'],
      model: json['model'],
      capacity: json['capacity'],
      pricePerHour:
          double.tryParse(json['pricePerHour']?.toString() ?? '0') ?? 0.0,
      baseAirport: json['baseAirport'],
      baseCity: json['baseCity'],
      companyId: json['companyId'],
      companyName: json['companyName'] ?? 'Unknown',
      imageUrl: json['imageUrl'],
      aircraftType: json['aircraftType'] ?? 'unknown',
      flightDurationHours:
          double.tryParse(json['flightDurationHours']?.toString() ?? '0') ??
              0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
      'capacity': capacity,
      'pricePerHour': pricePerHour,
      'baseAirport': baseAirport,
      'baseCity': baseCity,
      'companyId': companyId,
      'companyName': companyName,
      'imageUrl': imageUrl,
      'aircraftType': aircraftType,
      'flightDurationHours': flightDurationHours,
    };
  }

  /// Get formatted price per hour in USD
  String get formattedPricePerHour =>
      '\$${pricePerHour.toStringAsFixed(0)}/hour USD';

  /// Get formatted flight duration
  String get formattedFlightDuration {
    final hours = flightDurationHours.floor();
    final minutes = ((flightDurationHours - hours) * 60).round();
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }
}
