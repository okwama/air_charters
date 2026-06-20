import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service for calculating route distances and flight times
class RouteCalculatorService {
  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadiusKm = 6371.0;

    final lat1Rad = point1.latitude * pi / 180;
    final lat2Rad = point2.latitude * pi / 180;
    final deltaLat = (point2.latitude - point1.latitude) * pi / 180;
    final deltaLng = (point2.longitude - point1.longitude) * pi / 180;

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLng / 2) * sin(deltaLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Calculate total route distance through multiple stops
  static double calculateTotalDistance(List<LatLng> points) {
    if (points.length < 2) return 0;

    double totalDistance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += calculateDistance(points[i], points[i + 1]);
    }

    return totalDistance;
  }

  /// Calculate estimated flight time based on distance and aircraft type
  static double calculateFlightTime(
    double distanceKm,
    String aircraftType,
  ) {
    // Average cruise speeds by aircraft type (km/h)
    final Map<String, double> cruiseSpeeds = {
      'jet': 800,
      'fixedWing': 350,
      'helicopter': 220,
      'seaplane': 250,
      'ultralight': 120,
      'default': 400,
    };

    final speed =
        cruiseSpeeds[aircraftType.toLowerCase()] ?? cruiseSpeeds['default']!;
    return distanceKm / speed; // Returns hours
  }

  /// Format distance for display
  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)}m';
    } else if (km < 10) {
      return '${km.toStringAsFixed(1)}km';
    } else {
      return '${km.toStringAsFixed(0)}km';
    }
  }

  /// Format duration for display
  static String formatDuration(double hours) {
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '${minutes}min';
    } else {
      final h = hours.floor();
      final m = ((hours - h) * 60).round();
      if (m > 0) {
        return '${h}h ${m}m';
      }
      return '${h}h';
    }
  }

  /// Get color for stop based on position in route
  static Color getStopColor(int index, int total) {
    if (index == 0) {
      return const Color(0xFF4CAF50); // Green - Start
    } else if (index == total - 1) {
      return const Color(0xFFF44336); // Red - End
    } else {
      return const Color(0xFFFFC107); // Yellow - Middle
    }
  }

  /// Get emoji indicator for stop number
  static String getStopEmoji(int index) {
    const emojis = [
      '1️⃣',
      '2️⃣',
      '3️⃣',
      '4️⃣',
      '5️⃣',
      '6️⃣',
      '7️⃣',
      '8️⃣',
      '9️⃣',
      '🔟'
    ];
    return index < emojis.length ? emojis[index] : '${index + 1}️⃣';
  }
}
