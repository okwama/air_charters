import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:developer' as dev;

class CharterDealModel {
  final int id;
  final int companyId;
  final int? fixedRouteId;
  final int aircraftId;
  final DateTime date;
  final String time;
  final double? pricePerSeat;
  final int discountPerSeat;
  final double? pricePerHour; // ✅ Fixed: was priceFullCharter
  final int discountPerHour; // ✅ Fixed: was discountFullCharter
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

  // ✅ New fields from existing database tables
  final List<String> aircraftImages; // From aircraft_images table
  final List<String> routeImages; // From fixed_routes.imageUrl (can be split)

  // ✅ Dynamic fields from API
  final String duration; // Calculated by backend from route
  final List<Map<String, dynamic>> amenities; // Real amenities from database

  const CharterDealModel({
    required this.id,
    required this.companyId,
    this.fixedRouteId,
    required this.aircraftId,
    required this.date,
    required this.time,
    this.pricePerSeat,
    this.discountPerSeat = 0,
    this.pricePerHour, // ✅ Fixed: was priceFullCharter
    this.discountPerHour = 0, // ✅ Fixed: was discountFullCharter
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
    this.aircraftImages = const [], // ✅ New: from aircraft_images table
    this.routeImages = const [], // ✅ New: from fixed_routes
    this.duration = '', // Will be populated from API
    this.amenities = const [], // Will be populated from API
  });

  factory CharterDealModel.fromJson(Map<String, dynamic> json) {
    try {
      return CharterDealModel(
        id: json['id'] as int,
        companyId: json['companyId'] as int,
        fixedRouteId: json['fixedRouteId'] as int?,
        aircraftId: json['aircraftId'] as int,
        date: DateTime.parse(json['date'] as String),
        time: json['time'] as String,
        pricePerSeat: (json['pricePerSeat'] != null)
            ? double.tryParse(json['pricePerSeat'].toString())
            : null,
        discountPerSeat: json['discountPerSeat'] as int? ?? 0,
        pricePerHour: (json['pricePerHour'] != null)
            ? double.tryParse(json['pricePerHour'].toString())
            : null,
        discountPerHour: json['discountPerHour'] as int? ?? 0,
        availableSeats: json['availableSeats'] as int,
        dealType: json['dealType'] as String? ??
            'privateCharter', // Handle null dealType
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        companyName: json['companyName'] as String?,
        companyLogo: json['companyLogo'] as String?,
        origin: json['originName'] as String? ??
            json['origin'] as String?, // Handle both field names
        destination: json['destinationName'] as String? ??
            json['destination'] as String?, // Handle both field names
        routeImageUrl: json['routeImageUrl'] as String? ?? '',
        aircraftName: json['aircraftName'] as String?,
        aircraftType: json['aircraftType'] as String?,
        aircraftCapacity: json['aircraftCapacity'] as int?,

        // ✅ New fields from existing database
        aircraftImages: (json['aircraftImages'] as List<dynamic>?)
                ?.map((e) => e.toString()) // Convert to string safely
                .toList() ??
            [],
        routeImages: (json['routeImages'] as List<dynamic>?)
                ?.map((e) => e.toString()) // Convert to string safely
                .toList() ??
            [],

        // ✅ Fields from API
        duration: json['duration'] as String? ?? '',
        amenities: (json['amenities'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [],
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
      'pricePerHour': pricePerHour, // ✅ Fixed: was priceFullCharter
      'discountPerHour': discountPerHour, // ✅ Fixed: was discountFullCharter
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
      'aircraftImages': aircraftImages,
      'routeImages': routeImages,
      'duration': duration,
      'amenities': amenities,
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
    } else if (pricePerHour != null) {
      // ✅ Fixed: was priceFullCharter
      final discountedPrice = pricePerHour! *
          (1 - discountPerHour / 100); // ✅ Fixed: was discountFullCharter
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
    // Use route image first, then aircraft images, then fallback
    if (routeImageUrl != null && routeImageUrl!.isNotEmpty) {
      return routeImageUrl!;
    }
    if (aircraftImages.isNotEmpty) {
      return aircraftImages.first;
    }
    if (routeImages.isNotEmpty) {
      return routeImages.first;
    }
    // Fallback to a generic placeholder
    return 'https://via.placeholder.com/400x300/4A90E2/FFFFFF?text=Aircraft';
  }

  bool get hasDiscount {
    return discountPerSeat > 0 ||
        discountPerHour > 0; // ✅ Fixed: was discountFullCharter
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
    double? pricePerHour, // ✅ Fixed: was priceFullCharter
    int? discountPerHour, // ✅ Fixed: was discountFullCharter
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
    List<String>? aircraftImages,
    List<String>? routeImages,
    String? duration,
    List<Map<String, dynamic>>? amenities,
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
      pricePerHour:
          pricePerHour ?? this.pricePerHour, // ✅ Fixed: was priceFullCharter
      discountPerHour: discountPerHour ??
          this.discountPerHour, // ✅ Fixed: was discountFullCharter
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
      aircraftImages: aircraftImages ?? this.aircraftImages,
      routeImages: routeImages ?? this.routeImages,
      duration: duration ?? this.duration,
      amenities: amenities ?? this.amenities,
    );
  }
}
