import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/models/location_model.dart';
import '../../core/models/google_earth_location_model.dart';
import '../../core/services/google_earth_engine_service.dart';
import '../../core/error/network_error_handler.dart';
import '../../config/env/maps_config.dart';
import '../../config/theme/app_theme.dart';

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
  List<String> _recentSearches = [];
  final bool _isLoading = false;
  bool _isSearching = false;
  String? _searchError;

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Search debouncing
  Timer? _searchDebounce;
  static const Duration _searchDelay = Duration(milliseconds: 500);

  // Map position
  LatLng _center = const LatLng(MapsConfig.defaultLatitude, MapsConfig.defaultLongitude);
  final double _zoom = MapsConfig.defaultZoom;

  @override
  void initState() {
    super.initState();
    _stops = widget.existingStops ?? [];
    _initializeMap();
    _updateMarkers();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
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

  void _onSearchChanged(String query) {
    // Cancel previous search
    _searchDebounce?.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _searchError = null;
      });
      return;
    }

    // Debounce search
    _searchDebounce = Timer(_searchDelay, () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    
    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await _googleService.searchLocations(query);
      
      if (!mounted) return;
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
        _searchError = null;
      });
      
      // Add to recent searches
      _addToRecentSearches(query);
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isSearching = false;
        _searchError = 'Search failed: ${NetworkErrorResult.fromException(e).message}';
        _searchResults = [];
      });
    }
  }

  void _addToRecentSearches(String query) {
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.take(5).toList();
      }
      _saveRecentSearches();
    }
  }

  void _loadRecentSearches() {
    // In a real app, you'd load from SharedPreferences
    _recentSearches = [
      'Nairobi Airport',
      'Mombasa Airport',
      'Kilimanjaro Airport',
    ];
  }

  void _saveRecentSearches() {
    // In a real app, you'd save to SharedPreferences
  }

  void _addStop(GoogleEarthLocationModel location) {
    try {
      print('🗺️ StopsSelectionScreen: Converting location to LocationModel');
      // Convert to LocationModel for compatibility
      final locationModel = location.toLocationModel();
      print('🗺️ StopsSelectionScreen: Converted location: ${locationModel.name}');

      setState(() {
        _stops.add(locationModel);
        _searchResults = [];
        _searchController.clear();
      });

      print('🗺️ StopsSelectionScreen: Added stop, total stops: ${_stops.length}');
      _updateMarkers();

      // Animate map to new stop
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
            LatLng(location.location.lat, location.location.lng)),
      );
    } catch (e) {
      print('🗺️ StopsSelectionScreen: Error adding stop: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding stop: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });

    _updateMarkers();
  }

  void _onMapTap(LatLng position) async {
    try {
      print('🗺️ StopsSelectionScreen: Map tapped at lat: ${position.latitude}, lng: ${position.longitude}');
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Getting location details...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Reverse geocode the tapped location
      final results = await _googleService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      print('🗺️ StopsSelectionScreen: Got ${results.length} reverse geocode results');

      if (results.isNotEmpty) {
        final location = results.first;
        print('🗺️ StopsSelectionScreen: Adding stop: ${location.name}');
        _addStop(location);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added: ${location.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        print('🗺️ StopsSelectionScreen: No results from reverse geocode');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No location details found for this area')),
        );
      }
    } catch (e) {
      print('🗺️ StopsSelectionScreen: Map tap error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location details: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Stops',
          style: AppTheme.heading3.copyWith(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _stops.isNotEmpty ? _confirmStops : null,
            child: Text(
              'Confirm',
              style: AppTheme.bodyMedium.copyWith(
                color: _stops.isNotEmpty ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search for stops',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search airports, cities, or landmarks...',
                    hintStyle: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
                    suffixIcon: _isSearching
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                              ),
                            ),
                          )
                        : _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: AppTheme.textSecondaryColor),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchResults = [];
                                    _isSearching = false;
                                    _searchError = null;
                                  });
                                },
                              )
                            : _recentSearches.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.history, color: AppTheme.textSecondaryColor),
                                    onPressed: () => _showRecentSearches(),
                                    tooltip: 'Recent searches',
                                  )
                                : null,
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                
                // Search Error
                if (_searchError != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppTheme.errorColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _searchError!,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Search Results Only (when actively searching)
          if (_searchResults.isNotEmpty)
            Container(
              height: 150,
              constraints: const BoxConstraints(maxHeight: 150),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Search Results (${_searchResults.length})',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                          title: Text(
                            result.name,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            result.formattedAddress,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _addStop(result),
                        );
                      },
                    ),
                  ),
                ],
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

            ],
          ),
          // Floating Selected Stops Overlay
          if (_stops.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Selected Stops (${_stops.length})',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (_stops.length > 3)
                          TextButton(
                            onPressed: () => _showAllStops(),
                            child: Text(
                              'View All',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Show first 3 stops
                    ...(_stops.take(3).map((stop) => _buildStopChip(stop, _stops.indexOf(stop)))),
                    if (_stops.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '+${_stops.length - 3} more stops',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.textSecondaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStopChip(LocationModel stop, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTheme.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (stop.city != null)
                  Text(
                    stop.city!,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: AppTheme.errorColor),
            onPressed: () => _removeStop(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  void _showAllStops() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'All Selected Stops (${_stops.length})',
                    style: AppTheme.heading3.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: AppTheme.textSecondaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _stops.length,
                itemBuilder: (context, index) {
                  final stop = _stops[index];
                  return _buildStopChip(stop, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecentSearches() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.history, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Searches',
                    style: AppTheme.heading3.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: AppTheme.textSecondaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  final search = _recentSearches[index];
                  return ListTile(
                    leading: Icon(Icons.history, color: AppTheme.textSecondaryColor),
                    title: Text(
                      search,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _searchController.text = search;
                      _performSearch(search);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
