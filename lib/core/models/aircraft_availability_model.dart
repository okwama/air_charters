class AvailableAircraft {
  final int aircraftId;
  final String aircraftName;
  final String aircraftType;
  final int capacity;
  final int companyId;
  final String companyName;
  final double basePrice;
  final double? repositioningCost;
  final double totalPrice;
  final int availableSeats;
  final String departureTime;
  final String arrivalTime;
  final int flightDuration; // in minutes
  final double distance; // in km
  final List<String> amenities;
  final List<String> images;

  AvailableAircraft({
    required this.aircraftId,
    required this.aircraftName,
    required this.aircraftType,
    required this.capacity,
    required this.companyId,
    required this.companyName,
    required this.basePrice,
    this.repositioningCost,
    required this.totalPrice,
    required this.availableSeats,
    required this.departureTime,
    required this.arrivalTime,
    required this.flightDuration,
    required this.distance,
    required this.amenities,
    required this.images,
  });

  factory AvailableAircraft.fromJson(Map<String, dynamic> json) {
    return AvailableAircraft(
      aircraftId: json['aircraftId'],
      aircraftName: json['aircraftName'],
      aircraftType: json['aircraftType'],
      capacity: json['capacity'],
      companyId: json['companyId'],
      companyName: json['companyName'],
      basePrice: (json['basePrice'] as num).toDouble(),
      repositioningCost: json['repositioningCost'] != null
          ? (json['repositioningCost'] as num).toDouble()
          : null,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      availableSeats: json['availableSeats'],
      departureTime: json['departureTime'],
      arrivalTime: json['arrivalTime'],
      flightDuration: json['flightDuration'],
      distance: (json['distance'] as num).toDouble(),
      amenities: List<String>.from(json['amenities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aircraftId': aircraftId,
      'aircraftName': aircraftName,
      'aircraftType': aircraftType,
      'capacity': capacity,
      'companyId': companyId,
      'companyName': companyName,
      'basePrice': basePrice,
      'repositioningCost': repositioningCost,
      'totalPrice': totalPrice,
      'availableSeats': availableSeats,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'flightDuration': flightDuration,
      'distance': distance,
      'amenities': amenities,
      'images': images,
    };
  }

  // Helper getters
  String get formattedPrice => '\$${totalPrice.toStringAsFixed(2)}';
  String get formattedBasePrice => '\$${basePrice.toStringAsFixed(2)}';
  String get formattedRepositioningCost => repositioningCost != null
      ? '\$${repositioningCost!.toStringAsFixed(2)}'
      : 'Included';

  String get formattedDuration {
    final hours = flightDuration ~/ 60;
    final minutes = flightDuration % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formattedDistance => '${distance.toStringAsFixed(0)} km';

  String get aircraftTypeDisplay {
    switch (aircraftType) {
      case 'helicopter':
        return 'Helicopter';
      case 'fixedWing':
        return 'Fixed Wing';
      case 'jet':
        return 'Private Jet';
      case 'glider':
        return 'Glider';
      case 'seaplane':
        return 'Seaplane';
      case 'ultralight':
        return 'Ultralight';
      case 'balloon':
        return 'Hot Air Balloon';
      case 'tiltrotor':
        return 'Tiltrotor';
      case 'gyroplane':
        return 'Gyroplane';
      case 'airship':
        return 'Airship';
      default:
        return aircraftType;
    }
  }

  bool get hasRepositioningCost =>
      repositioningCost != null && repositioningCost! > 0;

  @override
  String toString() {
    return '$aircraftName ($aircraftType) - $formattedPrice';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvailableAircraft && other.aircraftId == aircraftId;
  }

  @override
  int get hashCode => aircraftId.hashCode;
}
