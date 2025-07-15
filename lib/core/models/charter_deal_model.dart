import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:developer' as dev;

class CharterDealModel {
  final int id;
  final int companyId;
  final int fixedRouteId;
  final int aircraftId;
  final DateTime date;
  final String time;
  final double? pricePerSeat;
  final int discountPerSeat;
  final double? priceFullCharter;
  final int discountFullCharter;
  final int availableSeats;
  final String dealType;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data from joins
  final String? companyName;
  final String? companyLogo;
  final String? origin;
  final String? destination;
  final String? routeImageUrl;
  final String? aircraftName;
  final String? aircraftType;
  final int? aircraftCapacity;

  const CharterDealModel({
    required this.id,
    required this.companyId,
    required this.fixedRouteId,
    required this.aircraftId,
    required this.date,
    required this.time,
    this.pricePerSeat,
    this.discountPerSeat = 0,
    this.priceFullCharter,
    this.discountFullCharter = 0,
    required this.availableSeats,
    required this.dealType,
    required this.createdAt,
    required this.updatedAt,
    this.companyName,
    this.companyLogo,
    this.origin,
    this.destination,
    this.routeImageUrl,
    this.aircraftName,
    this.aircraftType,
    this.aircraftCapacity,
  });

  factory CharterDealModel.fromJson(Map<String, dynamic> json) {
    try {
      return CharterDealModel(
        id: json['id'] as int,
        companyId: json['companyId'] as int,
        fixedRouteId: json['fixedRouteId'] as int,
        aircraftId: json['aircraftId'] as int,
        date: DateTime.parse(json['date'] as String),
        time: json['time'] as String,
        pricePerSeat: json['pricePerSeat']?.toDouble(),
        discountPerSeat: json['discountPerSeat'] as int? ?? 0,
        priceFullCharter: json['priceFullCharter']?.toDouble(),
        discountFullCharter: json['discountFullCharter'] as int? ?? 0,
        availableSeats: json['availableSeats'] as int,
        dealType: json['dealType'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        companyName: json['companyName'] as String?,
        companyLogo: json['companyLogo'] as String?,
        origin: json['origin'] as String?,
        destination: json['destination'] as String?,
        routeImageUrl: json['routeImageUrl'] as String?,
        aircraftName: json['aircraftName'] as String?,
        aircraftType: json['aircraftType'] as String?,
        aircraftCapacity: json['aircraftCapacity'] as int?,
      );
    } catch (e) {
      // Log the error and the problematic JSON
      if (kDebugMode) {
        dev.log('CharterDealModel: Error parsing JSON: $e',
            name: 'charter_deal_model');
        dev.log('CharterDealModel: Problematic JSON: $json',
            name: 'charter_deal_model');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'fixedRouteId': fixedRouteId,
      'aircraftId': aircraftId,
      'date': date.toIso8601String(),
      'time': time,
      'pricePerSeat': pricePerSeat,
      'discountPerSeat': discountPerSeat,
      'priceFullCharter': priceFullCharter,
      'discountFullCharter': discountFullCharter,
      'availableSeats': availableSeats,
      'dealType': dealType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'companyName': companyName,
      'companyLogo': companyLogo,
      'origin': origin,
      'destination': destination,
      'routeImageUrl': routeImageUrl,
      'aircraftName': aircraftName,
      'aircraftType': aircraftType,
      'aircraftCapacity': aircraftCapacity,
    };
  }

  String get routeDisplay {
    if (origin != null && destination != null) {
      return '$origin - $destination';
    }
    return 'Route';
  }

  String get priceDisplay {
    if (pricePerSeat != null) {
      final discountedPrice = pricePerSeat! * (1 - discountPerSeat / 100);
      return '\$${discountedPrice.toStringAsFixed(0)}';
    } else if (priceFullCharter != null) {
      final discountedPrice =
          priceFullCharter! * (1 - discountFullCharter / 100);
      return '\$${discountedPrice.toStringAsFixed(0)}';
    }
    return 'Contact for pricing';
  }

  String get dateDisplay {
    final now = DateTime.now();
    final daysUntil = date.difference(now).inDays;

    if (daysUntil == 0) {
      return 'Today';
    } else if (daysUntil == 1) {
      return 'Tomorrow';
    } else if (daysUntil < 7) {
      return 'In $daysUntil days';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  String get flightsAvailableDisplay {
    if (dealType == 'privateCharter') {
      return 'Private Charter';
    } else {
      return '$availableSeats seats available';
    }
  }

  String get imageUrl {
    return routeImageUrl ??
        'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTA1MDU3Nzd8&ixlib=rb-4.1.0&q=80&w=1080';
  }

  bool get hasDiscount {
    return discountPerSeat > 0 || discountFullCharter > 0;
  }

  CharterDealModel copyWith({
    int? id,
    int? companyId,
    int? fixedRouteId,
    int? aircraftId,
    DateTime? date,
    String? time,
    double? pricePerSeat,
    int? discountPerSeat,
    double? priceFullCharter,
    int? discountFullCharter,
    int? availableSeats,
    String? dealType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? companyName,
    String? companyLogo,
    String? origin,
    String? destination,
    String? routeImageUrl,
    String? aircraftName,
    String? aircraftType,
    int? aircraftCapacity,
  }) {
    return CharterDealModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      fixedRouteId: fixedRouteId ?? this.fixedRouteId,
      aircraftId: aircraftId ?? this.aircraftId,
      date: date ?? this.date,
      time: time ?? this.time,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      discountPerSeat: discountPerSeat ?? this.discountPerSeat,
      priceFullCharter: priceFullCharter ?? this.priceFullCharter,
      discountFullCharter: discountFullCharter ?? this.discountFullCharter,
      availableSeats: availableSeats ?? this.availableSeats,
      dealType: dealType ?? this.dealType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      routeImageUrl: routeImageUrl ?? this.routeImageUrl,
      aircraftName: aircraftName ?? this.aircraftName,
      aircraftType: aircraftType ?? this.aircraftType,
      aircraftCapacity: aircraftCapacity ?? this.aircraftCapacity,
    );
  }
}
