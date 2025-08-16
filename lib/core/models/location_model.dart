enum LocationType {
  airport,
  city,
  region,
}

class LocationModel {
  final int id;
  final String name;
  final String code;
  final String country;
  final LocationType type;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  LocationModel({
    required this.id,
    required this.name,
    required this.code,
    required this.country,
    required this.type,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      country: json['country'],
      type: LocationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => LocationType.city,
      ),
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'country': country,
      'type': type.toString().split('.').last,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper getters for backward compatibility
  String get city => name;
  String? get iataCode => type == LocationType.airport ? code : null;
  bool get isActive => true;

  @override
  String toString() {
    return '$name ($code, $country)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
