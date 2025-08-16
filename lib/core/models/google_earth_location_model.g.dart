// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_earth_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleEarthLocationModel _$GoogleEarthLocationModelFromJson(
        Map<String, dynamic> json) =>
    GoogleEarthLocationModel(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      formattedAddress: json['formattedAddress'] as String,
      location: LocationCoordinates.fromJson(
          json['location'] as Map<String, dynamic>),
      types:
          (json['types'] as List<dynamic>?)?.map((e) => e as String).toList(),
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: (json['userRatingsTotal'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GoogleEarthLocationModelToJson(
        GoogleEarthLocationModel instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'name': instance.name,
      'formattedAddress': instance.formattedAddress,
      'location': instance.location,
      'types': instance.types,
      'rating': instance.rating,
      'userRatingsTotal': instance.userRatingsTotal,
    };

LocationCoordinates _$LocationCoordinatesFromJson(Map<String, dynamic> json) =>
    LocationCoordinates(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationCoordinatesToJson(
        LocationCoordinates instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };
