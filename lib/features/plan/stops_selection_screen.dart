import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../core/models/location_model.dart';
import '../../core/models/google_earth_location_model.dart';
import '../../core/services/google_earth_engine_service.dart';
import '../../config/env/maps_config.dart';
import './controllers/stops_map_controller.dart';
import './widgets/stops_bottom_sheet.dart';
import './widgets/floating_search_bar.dart';
import './widgets/map_controls.dart';

class StopsSelectionScreen extends StatefulWidget {
  final LocationModel? origin;
  final LocationModel? destination;
  final List<LocationModel>? existingStops;
  final Function(List<LocationModel>) onStopsSelected;

  const StopsSelectionScreen({
    super.key,
    this.origin,
    this.destination,
    this.existingStops,
    required this.onStopsSelected,
  });

  @override
  State<StopsSelectionScreen> createState() => _StopsSelectionScreenState();
}

class _StopsSelectionScreenState extends State<StopsSelectionScreen> {
  final GoogleEarthEngineService _googleService = GoogleEarthEngineService();
  final TextEditingController _searchController = TextEditingController();

  late StopsMapController _stopsController;
  List<GoogleEarthLocationModel> _searchResults = [];
  bool _isSearching = false;

  // Search debouncing
  Timer? _searchDebounce;
  static const Duration _searchDelay = Duration(milliseconds: 500);

  // Map position
  LatLng _center = const LatLng(
    MapsConfig.defaultLatitude,
    MapsConfig.defaultLongitude,
  );

  @override
  void initState() {
    super.initState();
    _stopsController = StopsMapController();
    _stopsController.initialize(widget.existingStops);
    _stopsController.setOriginDestination(widget.origin, widget.destination);
    _initializeMap();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _stopsController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _center = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // Keep default center if GPS fails
      print('GPS error: $e');
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _searchDebounce = Timer(_searchDelay, () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await _googleService.searchLocations(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _stopsController.mapController = controller;

    // Fit bounds if there are existing stops
    if (_stopsController.stops.length >= 2) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _stopsController.fitBounds();
      });
    }
  }

  void _onMapTap(LatLng position) async {
    try {
      print('Map tapped at: ${position.latitude}, ${position.longitude}');

      // Reverse geocode the tapped location
      final results = await _googleService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (results.isNotEmpty) {
        final location = results.first;
        _addStop(location);
      }
    } catch (e) {
      print('Map tap error: $e');
      // Only show toast for network errors
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('network') || errorStr.contains('connection')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connection lost'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _addStop(GoogleEarthLocationModel location) {
    try {
      print('Adding stop: ${location.name}');

      final locationModel = LocationModel(
        id: location.placeId.hashCode,
        name: location.name,
        code: location.placeId,
        country: location.formattedAddress.split(',').last.trim(),
        type: LocationType.airport,
        latitude: location.location.lat,
        longitude: location.location.lng,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _stopsController.addStop(locationModel);

      // Clear search
      _searchController.clear();
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    } catch (e) {
      print('Error adding stop: $e');
    }
  }

  void _goToMyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _stopsController.mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _confirmStops() {
    widget.onStopsSelected(_stopsController.stops);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _stopsController,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // FULL SCREEN MAP (base layer)
            Consumer<StopsMapController>(
              builder: (context, controller, child) {
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: MapsConfig.defaultZoom,
                  ),
                  onMapCreated: _onMapCreated,
                  markers: controller.markers,
                  polylines: controller.polylines,
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  style: '''
                    [
                      {
                        "featureType": "poi",
                        "elementType": "labels",
                        "stylers": [{"visibility": "off"}]
                      }
                    ]
                  ''',
                );
              },
            ),

            // FLOATING BACK BUTTON (top left)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // FLOATING SEARCH BAR (top)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 72,
              right: 16,
              child: FloatingSearchBar(
                controller: _searchController,
                isSearching: _isSearching,
                searchResults: _searchResults,
                onSearchChanged: _onSearchChanged,
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults = [];
                    _isSearching = false;
                  });
                },
                onResultTap: _addStop,
              ),
            ),

            // MY LOCATION BUTTON (right side)
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).size.height * 0.35 + 16,
              child: MapControls(
                onMyLocationTap: _goToMyLocation,
              ),
            ),

            // DRAGGABLE BOTTOM SHEET with stops list
            Consumer<StopsMapController>(
              builder: (context, controller, child) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.3,
                  minChildSize: 0.15,
                  maxChildSize: 0.7,
                  snap: true,
                  snapSizes: const [0.15, 0.3, 0.7],
                  builder: (context, scrollController) {
                    return StopsBottomSheet(
                      scrollController: scrollController,
                      stops: controller.stops,
                      origin: controller.origin,
                      destination: controller.destination,
                      onRemoveStop: (index) => controller.removeStop(index),
                      onConfirm: _confirmStops,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
