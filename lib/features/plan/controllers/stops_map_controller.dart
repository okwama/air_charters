import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/models/location_model.dart';
import '../../../core/services/route_calculator_service.dart';
import '../../../config/theme/app_theme.dart';

class StopsMapController extends ChangeNotifier {
  List<LocationModel> _stops = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  GoogleMapController? mapController;
  LocationModel? _origin;
  LocationModel? _destination;

  List<LocationModel> get stops => _stops;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  LocationModel? get origin => _origin;
  LocationModel? get destination => _destination;

  double get totalDistance {
    if (_stops.length < 2) return 0;
    final points =
        _stops.map((stop) => LatLng(stop.latitude!, stop.longitude!)).toList();
    return RouteCalculatorService.calculateTotalDistance(points);
  }

  double getDistanceBetweenStops(int index) {
    if (index == 0 || index >= _stops.length) return 0;
    return RouteCalculatorService.calculateDistance(
      LatLng(_stops[index - 1].latitude!, _stops[index - 1].longitude!),
      LatLng(_stops[index].latitude!, _stops[index].longitude!),
    );
  }

  /// Initialize with existing stops
  void initialize(List<LocationModel>? existingStops) {
    _stops = existingStops ?? [];
    updateMarkers();
    updatePolylines();
  }

  /// Set origin and destination
  void setOriginDestination(LocationModel? origin, LocationModel? destination) {
    _origin = origin;
    _destination = destination;
    updateMarkers();
    updatePolylines();
    notifyListeners();
  }

  /// Add a stop
  void addStop(LocationModel location) {
    _stops.add(location);
    updateMarkers();
    updatePolylines();
    notifyListeners();

    // Animate camera to new stop
    if (mapController != null &&
        location.latitude != null &&
        location.longitude != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(location.latitude!, location.longitude!),
        ),
      );
    }
  }

  /// Remove a stop
  void removeStop(int index) {
    if (index >= 0 && index < _stops.length) {
      _stops.removeAt(index);
      updateMarkers();
      updatePolylines();
      notifyListeners();
    }
  }

  /// Clear all stops
  void clearStops() {
    _stops.clear();
    _markers.clear();
    _polylines.clear();
    notifyListeners();
  }

  /// Update map markers
  void updateMarkers() {
    _markers.clear();

    // Add origin marker
    if (_origin != null &&
        _origin!.latitude != null &&
        _origin!.longitude != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: LatLng(_origin!.latitude!, _origin!.longitude!),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Origin: ${_origin!.name}',
            snippet: _origin!.country,
          ),
        ),
      );
    }

    // Add destination marker
    if (_destination != null &&
        _destination!.latitude != null &&
        _destination!.longitude != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(_destination!.latitude!, _destination!.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Destination: ${_destination!.name}',
            snippet: _destination!.country,
          ),
        ),
      );
    }

    // Add intermediate stops
    for (int i = 0; i < _stops.length; i++) {
      final stop = _stops[i];
      if (stop.latitude == null || stop.longitude == null) continue;

      _markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: LatLng(stop.latitude!, stop.longitude!),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow: InfoWindow(
            title: 'Stop ${i + 1}: ${stop.name}',
            snippet: stop.country,
          ),
        ),
      );
    }
  }

  /// Update route polylines
  void updatePolylines() {
    _polylines.clear();

    final points = <LatLng>[];

    // Add origin
    if (_origin != null &&
        _origin!.latitude != null &&
        _origin!.longitude != null) {
      points.add(LatLng(_origin!.latitude!, _origin!.longitude!));
    }

    // Add intermediate stops
    for (final stop in _stops) {
      if (stop.latitude != null && stop.longitude != null) {
        points.add(LatLng(stop.latitude!, stop.longitude!));
      }
    }

    // Add destination
    if (_destination != null &&
        _destination!.latitude != null &&
        _destination!.longitude != null) {
      points.add(LatLng(_destination!.latitude!, _destination!.longitude!));
    }

    // Draw polyline if we have at least 2 points
    if (points.length >= 2) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: AppTheme.primaryColor,
          width: 3,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }
  }

  /// Fit map bounds to show all stops
  void fitBounds() {
    if (mapController == null) return;

    // Need at least origin or destination or 1 stop to fit bounds
    final hasPoints =
        _origin != null || _destination != null || _stops.isNotEmpty;
    if (!hasPoints) return;

    final bounds = _calculateBounds();
    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  /// Calculate bounds for all stops (including origin and destination)
  LatLngBounds _calculateBounds() {
    double? minLat, maxLat, minLng, maxLng;

    // Include origin
    if (_origin != null &&
        _origin!.latitude != null &&
        _origin!.longitude != null) {
      minLat = _origin!.latitude!;
      maxLat = _origin!.latitude!;
      minLng = _origin!.longitude!;
      maxLng = _origin!.longitude!;
    }

    // Include destination
    if (_destination != null &&
        _destination!.latitude != null &&
        _destination!.longitude != null) {
      minLat = minLat == null
          ? _destination!.latitude!
          : min(minLat, _destination!.latitude!);
      maxLat = maxLat == null
          ? _destination!.latitude!
          : max(maxLat, _destination!.latitude!);
      minLng = minLng == null
          ? _destination!.longitude!
          : min(minLng, _destination!.longitude!);
      maxLng = maxLng == null
          ? _destination!.longitude!
          : max(maxLng, _destination!.longitude!);
    }

    // Include intermediate stops
    for (final stop in _stops) {
      if (stop.latitude == null || stop.longitude == null) continue;

      minLat = minLat == null ? stop.latitude! : min(minLat, stop.latitude!);
      maxLat = maxLat == null ? stop.latitude! : max(maxLat, stop.latitude!);
      minLng = minLng == null ? stop.longitude! : min(minLng, stop.longitude!);
      maxLng = maxLng == null ? stop.longitude! : max(maxLng, stop.longitude!);
    }

    return LatLngBounds(
      southwest: LatLng(minLat ?? 0, minLng ?? 0),
      northeast: LatLng(maxLat ?? 0, maxLng ?? 0),
    );
  }

  double min(double a, double b) => a < b ? a : b;
  double max(double a, double b) => a > b ? a : b;
}
