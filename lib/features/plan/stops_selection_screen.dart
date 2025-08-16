import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/models/location_model.dart';
import '../../core/models/google_earth_location_model.dart';
import '../../core/services/google_earth_engine_service.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/loading_widget.dart';

class StopsSelectionScreen extends StatefulWidget {
  final List<LocationModel>? existingStops;
  final Function(List<LocationModel>) onStopsSelected;

  const StopsSelectionScreen({
    super.key,
    this.existingStops,
    required this.onStopsSelected,
  });

  @override
  State<StopsSelectionScreen> createState() => _StopsSelectionScreenState();
}

class _StopsSelectionScreenState extends State<StopsSelectionScreen> {
  final GoogleEarthEngineService _googleService = GoogleEarthEngineService();
  final TextEditingController _searchController = TextEditingController();

  List<LocationModel> _stops = [];
  List<GoogleEarthLocationModel> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Map position
  LatLng _center = const LatLng(0, 0);
  double _zoom = 10.0;

  @override
  void initState() {
    super.initState();
    _stops = widget.existingStops ?? [];
    _initializeMap();
    _updateMarkers();
  }

  Future<void> _initializeMap() async {
    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _center = LatLng(position.latitude, position.longitude);
      });

      _updateMarkers();
    } catch (e) {
      // Default to a central location if GPS fails
      setState(() {
        _center = const LatLng(0, 0);
      });
    }
  }

  void _updateMarkers() {
    _markers.clear();

    // Add current location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _center,
        infoWindow: const InfoWindow(title: 'Current Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Add stops markers
    for (int i = 0; i < _stops.length; i++) {
      final stop = _stops[i];
      if (stop.latitude != null && stop.longitude != null) {
        _markers.add(
          Marker(
            markerId: MarkerId('stop_$i'),
            position: LatLng(stop.latitude!, stop.longitude!),
            infoWindow: InfoWindow(
              title: stop.name,
              snippet: stop.city,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }

    // Update polylines to connect stops
    _updatePolylines();
  }

  void _updatePolylines() {
    _polylines.clear();

    if (_stops.length > 1) {
      List<LatLng> points = [];

      // Add current location as first point
      points.add(_center);

      // Add all stops
      for (final stop in _stops) {
        if (stop.latitude != null && stop.longitude != null) {
          points.add(LatLng(stop.latitude!, stop.longitude!));
        }
      }

      if (points.length > 1) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 3,
          ),
        );
      }
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _googleService.searchLocations(query);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: ${e.toString()}')),
      );
    }
  }

  void _addStop(GoogleEarthLocationModel location) {
    // Convert to LocationModel for compatibility
    final locationModel = location.toLocationModel();

    setState(() {
      _stops.add(locationModel);
      _searchResults = [];
      _searchController.clear();
    });

    _updateMarkers();

    // Animate map to new stop
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
          LatLng(location.location.lat, location.location.lng)),
    );
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });

    _updateMarkers();
  }

  void _onMapTap(LatLng position) async {
    try {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get location details')),
      );
    }
  }

  void _confirmStops() {
    widget.onStopsSelected(_stops);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Stops',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _stops.isNotEmpty ? _confirmStops : null,
            child: Text(
              'Confirm',
              style: GoogleFonts.inter(
                color: _stops.isNotEmpty ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search for stops',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search airports, cities, or landmarks...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      _searchLocations(value);
                    } else {
                      setState(() {
                        _searchResults = [];
                        _isSearching = false;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Search Results
          if (_searchResults.isNotEmpty)
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.blue),
                    title: Text(
                      result.name,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      result.formattedAddress,
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                    ),
                    onTap: () => _addStop(result),
                  );
                },
              ),
            ),

          // Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: _zoom,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  polylines: _polylines,
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
            ),
          ),

          // Selected Stops
          if (_stops.isNotEmpty)
            Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Stops (${_stops.length})',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _stops.length,
                      itemBuilder: (context, index) {
                        final stop = _stops[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      stop.name,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () => _removeStop(index),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stop.city,
                                style: GoogleFonts.inter(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
