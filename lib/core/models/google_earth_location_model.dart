import 'package:json_annotation/json_annotation.dart';
import 'location_model.dart';

part 'google_earth_location_model.g.dart';

@JsonSerializable()
class GoogleEarthLocationModel {
  final String placeId;
  final String name;
  final String formattedAddress;
  final LocationCoordinates location;
  final List<String>? types;
  final double? rating;
  final int? userRatingsTotal;

  GoogleEarthLocationModel({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.location,
    this.types,
    this.rating,
    this.userRatingsTotal,
  });

  factory GoogleEarthLocationModel.fromJson(Map<String, dynamic> json) =>
      _$GoogleEarthLocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleEarthLocationModelToJson(this);

  // Convert to LocationModel for compatibility
  LocationModel toLocationModel() {
    return LocationModel(
      id: 0, // Will be set by backend
      name: name,
      code: placeId,
      country: _extractCountry(formattedAddress),
      type: _determineType(types ?? []),
      latitude: location.lat,
      longitude: location.lng,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String _extractCountry(String address) {
    final parts = address.split(',');
    return parts.isNotEmpty ? parts.last.trim() : 'Unknown';
  }

  LocationType _determineType(List<String> types) {
    if (types.contains('airport') || types.contains('establishment')) {
      return LocationType.airport;
    } else if (types.contains('locality') ||
        types.contains('administrative_area_level_1')) {
      return LocationType.city;
    } else {
      return LocationType.region;
    }
  }
}

@JsonSerializable()
class LocationCoordinates {
  final double lat;
  final double lng;

  LocationCoordinates({
    required this.lat,
    required this.lng,
  });

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) =>
      _$LocationCoordinatesFromJson(json);

  Map<String, dynamic> toJson() => _$LocationCoordinatesToJson(this);
}
