enum LocationType {
  airport,
  city,
  custom,
}

class BookingStopModel {
  final int id;
  final int bookingId;
  final String stopName;
  final double longitude;
  final double latitude;
  final DateTime? datetime;
  final int stopOrder;
  final LocationType locationType;
  final String? locationCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingStopModel({
    required this.id,
    required this.bookingId,
    required this.stopName,
    required this.longitude,
    required this.latitude,
    this.datetime,
    required this.stopOrder,
    required this.locationType,
    this.locationCode,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingStopModel.fromJson(Map<String, dynamic> json) {
    final createdAtStr = json['createdAt'] ?? json['created_at'];
    final updatedAtStr = json['updatedAt'] ?? json['updated_at'];

    return BookingStopModel(
      id: json['id'] ?? 0,
      bookingId: json['bookingId'] ?? json['booking_id'] ?? 0,
      stopName: json['stopName'] ?? json['stop_name'] ?? '',
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      datetime:
          json['datetime'] != null ? DateTime.parse(json['datetime']) : null,
      stopOrder: json['stopOrder'] ?? json['stop_order'] ?? 0,
      locationType: _parseLocationType(
          json['locationType'] ?? json['location_type'] ?? 'custom'),
      locationCode: json['locationCode'] ?? json['location_code'],
      createdAt: createdAtStr != null ? DateTime.parse(createdAtStr) : null,
      updatedAt: updatedAtStr != null ? DateTime.parse(updatedAtStr) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'stopName': stopName,
      'longitude': longitude,
      'latitude': latitude,
      'datetime': datetime?.toIso8601String(),
      'stopOrder': stopOrder,
      'locationType': locationType.name,
      'locationCode': locationCode,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static LocationType _parseLocationType(String type) {
    switch (type.toLowerCase()) {
      case 'airport':
        return LocationType.airport;
      case 'city':
        return LocationType.city;
      case 'custom':
      default:
        return LocationType.custom;
    }
  }

  BookingStopModel copyWith({
    int? id,
    int? bookingId,
    String? stopName,
    double? longitude,
    double? latitude,
    DateTime? datetime,
    int? stopOrder,
    LocationType? locationType,
    String? locationCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingStopModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      stopName: stopName ?? this.stopName,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      datetime: datetime ?? this.datetime,
      stopOrder: stopOrder ?? this.stopOrder,
      locationType: locationType ?? this.locationType,
      locationCode: locationCode ?? this.locationCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BookingStopModel(id: $id, stopName: $stopName, locationType: $locationType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingStopModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
