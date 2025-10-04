import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme/app_theme.dart';
import '../../config/env/maps_config.dart';
import '../../core/services/locations_service.dart';
import '../../core/services/google_maps_service.dart';
import '../../core/models/location_model.dart';

/// Uber-like location picker for direct charter flights
class EnhancedLocationPicker extends StatefulWidget {
  final String title;
  final LocationModel? selectedLocation;
  final ValueChanged<LocationModel> onLocationSelected;
  final String? placeholder;
  final bool showCurrentLocation;

  const EnhancedLocationPicker({
    super.key,
    required this.title,
    this.selectedLocation,
    required this.onLocationSelected,
    this.placeholder,
    this.showCurrentLocation = true,
  });

  @override
  State<EnhancedLocationPicker> createState() => _EnhancedLocationPickerState();
}

class _EnhancedLocationPickerState extends State<EnhancedLocationPicker> {
  final TextEditingController _searchController = TextEditingController();
  final LocationsService _locationsService = LocationsService();
  final GoogleMapsService _googleMapsService = GoogleMapsService();
  List<LocationModel> _searchResults = [];
  List<GoogleLocation> _googleSearchResults = [];
  List<String> _recentSearches = [];
  bool _isSearching = false;
  bool _isLoadingInitialData = true;
  Position? _currentPosition;
  String? _currentCountry;
  Timer? _searchDebounce;
  static const Duration _searchDelay = Duration(milliseconds: 500);
  
  // Map view state
  bool _isMapView = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _mapCenter = const LatLng(0.0, 0.0);
  double _mapZoom = 10.0;

  @override
  void initState() {
    super.initState();
    _initializeMapCenter();
    _getCurrentLocation();
    _loadPopularLocations();
    _loadRecentSearches();
  }

  /// Initialize map center based on current location or default
  void _initializeMapCenter() {
    if (_currentPosition != null) {
      _mapCenter = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    } else {
      _mapCenter = const LatLng(MapsConfig.defaultLatitude, MapsConfig.defaultLongitude);
    }
    _mapZoom = MapsConfig.defaultZoom;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  /// Get user's current location for location-aware search
  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _mapCenter = LatLng(position.latitude, position.longitude);
      });

      // Get country from coordinates using reverse geocoding
      await _getCountryFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  /// Get country name from coordinates
  Future<void> _getCountryFromCoordinates(double lat, double lng) async {
    try {
      final location = await _googleMapsService.reverseGeocode(lat, lng);
      // Extract country from formatted address
      final addressParts = location.formattedAddress.split(',');
      if (addressParts.isNotEmpty) {
        final country = addressParts.last.trim();
        setState(() {
          _currentCountry = country;
        });
        print('Current country detected: $country');
      }
    } catch (e) {
      print('Error getting country from coordinates: $e');
    }
  }

  Future<void> _loadPopularLocations() async {
    try {
      // Load local popular locations
      final localLocations = await _locationsService.getPopularLocations();

      // Load location-aware Google results
      List<GoogleLocation> googleLocations = [];

      if (_currentPosition != null) {
        // Search for nearby airports first
        try {
          googleLocations = await _googleMapsService.searchLocations(
            query: 'airport',
            type: 'airport',
            location:
                '${_currentPosition!.latitude},${_currentPosition!.longitude}',
            radius: 500000, // 500km radius
          );
        } catch (e) {
          print('Error loading nearby airports: $e');
        }
      }

      // If no nearby results or no location, do global search
      if (googleLocations.isEmpty) {
        try {
          googleLocations = await _googleMapsService.searchLocations(
            query: 'airport',
            type: 'airport',
          );
        } catch (e) {
          print('Error loading global airports: $e');
        }
      }

      setState(() {
        _searchResults = localLocations;
        _googleSearchResults = googleLocations;
        _isLoadingInitialData = false;
      });
    } catch (e) {
      print('Error loading popular locations: $e');
      // Fallback to local only if Google fails
      try {
        final locations = await _locationsService.getPopularLocations();
        setState(() {
          _searchResults = locations;
          _isLoadingInitialData = false;
        });
      } catch (fallbackError) {
        print('Error loading local popular locations: $fallbackError');
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      await _loadPopularLocations();
      return;
    }

    // Add to recent searches
    _addToRecentSearches(query);

    setState(() {
      _isSearching = true;
    });

    try {
      // Location-aware search with priority
      final List<GoogleLocation> googleResults =
          await _performLocationAwareSearch(query);
      final List<LocationModel> localResults =
          await _locationsService.searchLocations(query);

      setState(() {
        _googleSearchResults = googleResults;
        _searchResults = localResults;
        _isSearching = false;
      });
      
      // Update map markers if in map view
      if (_isMapView) {
        _updateMapMarkers();
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      print('Error searching locations: $e');
    }
  }

  /// Perform location-aware search with regional priority
  Future<List<GoogleLocation>> _performLocationAwareSearch(String query) async {
    List<GoogleLocation> allResults = [];

    if (_currentPosition != null) {
      // Search with user's current location as center
      try {
        final nearbyResults = await _googleMapsService.searchLocations(
          query: query,
          type: 'airport|establishment',
          location:
              '${_currentPosition!.latitude},${_currentPosition!.longitude}',
          radius: 500000, // 500km radius for regional search
        );
        allResults.addAll(nearbyResults);
        print('Found ${nearbyResults.length} nearby results');
      } catch (e) {
        print('Error searching nearby locations: $e');
      }
    }

    // If we have a country, search specifically in that country
    if (_currentCountry != null) {
      try {
        final countryResults = await _googleMapsService.searchLocations(
          query: '$query in $_currentCountry',
          type: 'airport|establishment',
        );
        allResults.addAll(countryResults);
        print('Found ${countryResults.length} country-specific results');
      } catch (e) {
        print('Error searching country-specific locations: $e');
      }
    }

    // Global search as fallback
    try {
      final globalResults = await _googleMapsService.searchLocations(
        query: query,
        type: 'airport|establishment',
      );
      allResults.addAll(globalResults);
      print('Found ${globalResults.length} global results');
    } catch (e) {
      print('Error searching global locations: $e');
    }

    // Remove duplicates and sort by priority
    return _sortResultsByPriority(allResults);
  }

  /// Sort results by location priority (local -> regional -> global)
  List<GoogleLocation> _sortResultsByPriority(List<GoogleLocation> results) {
    // Remove duplicates based on placeId
    final Map<String, GoogleLocation> uniqueResults = {};
    for (final result in results) {
      if (!uniqueResults.containsKey(result.placeId)) {
        uniqueResults[result.placeId] = result;
      }
    }

    final List<GoogleLocation> sortedResults = uniqueResults.values.toList();

    // Sort by priority: current country first, then by distance
    sortedResults.sort((a, b) {
      // Priority 1: Current country
      if (_currentCountry != null) {
        final aInCountry = a.formattedAddress
            .toLowerCase()
            .contains(_currentCountry!.toLowerCase());
        final bInCountry = b.formattedAddress
            .toLowerCase()
            .contains(_currentCountry!.toLowerCase());

        if (aInCountry && !bInCountry) return -1;
        if (!aInCountry && bInCountry) return 1;
      }

      // Priority 2: Distance from current location (if available)
      if (_currentPosition != null) {
        final aDistance = _calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          a.latitude,
          a.longitude,
        );
        final bDistance = _calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          b.latitude,
          b.longitude,
        );

        return aDistance.compareTo(bDistance);
      }

      // Priority 3: Rating (higher is better)
      final aRating = a.rating ?? 0;
      final bRating = b.rating ?? 0;
      return bRating.compareTo(aRating);
    });

    return sortedResults.take(20).toList(); // Limit to top 20 results
  }

  /// Calculate distance between two coordinates in kilometers
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) /
        1000; // Convert to km
  }

  /// Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSearchesJson = prefs.getStringList('location_recent_searches') ?? [];
      setState(() {
        _recentSearches = recentSearchesJson;
      });
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  /// Save recent searches to SharedPreferences
  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('location_recent_searches', _recentSearches);
    } catch (e) {
      print('Error saving recent searches: $e');
    }
  }

  /// Add a search query to recent searches
  void _addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _recentSearches.remove(query); // Remove if already exists
      _recentSearches.insert(0, query); // Add to beginning
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList(); // Keep only 10
      }
    });
    _saveRecentSearches();
  }

  /// Handle search input with debouncing
  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDelay, () {
      _searchLocations(query);
    });
  }

  /// Toggle between list and map view
  void _toggleView() {
    setState(() {
      _isMapView = !_isMapView;
    });
    
    if (_isMapView) {
      _updateMapMarkers();
    }
  }

  /// Update map markers based on search results
  void _updateMapMarkers() {
    _markers.clear();
    
    // Add current location marker if available
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Current Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    
    // Add search result markers
    for (int i = 0; i < _googleSearchResults.length; i++) {
      final location = _googleSearchResults[i];
      _markers.add(
        Marker(
          markerId: MarkerId('search_result_$i'),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.name,
            snippet: location.formattedAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () => _selectLocationFromMap(location),
        ),
      );
    }
    
    // Add local search result markers
    for (int i = 0; i < _searchResults.length; i++) {
      final location = _searchResults[i];
      if (location.latitude != null && location.longitude != null) {
        _markers.add(
          Marker(
            markerId: MarkerId('local_result_$i'),
            position: LatLng(location.latitude!, location.longitude!),
            infoWindow: InfoWindow(
              title: location.name,
              snippet: location.country,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            onTap: () => _selectLocationFromMap(location),
          ),
        );
      }
    }
  }

  /// Select location from map tap
  void _selectLocationFromMap(dynamic location) {
    LocationModel locationModel;
    
    if (location is GoogleLocation) {
      locationModel = LocationModel(
        id: location.placeId.hashCode,
        name: location.name,
        code: location.placeId,
        country: location.formattedAddress,
        type: _parseLocationType(location.locationType),
        latitude: location.latitude,
        longitude: location.longitude,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else if (location is LocationModel) {
      locationModel = location;
    } else {
      return;
    }
    
    widget.onLocationSelected(locationModel);
    Navigator.pop(context);
  }

  /// Handle map tap to add new location
  Future<void> _onMapTap(LatLng position) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Getting location details...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Reverse geocode the tapped location
      final location = await _googleMapsService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (location != null) {
        final locationModel = LocationModel(
          id: location.placeId.hashCode,
          name: location.name,
          code: location.placeId,
          country: location.formattedAddress,
          type: LocationType.other,
          latitude: location.latitude,
          longitude: location.longitude,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        widget.onLocationSelected(locationModel);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not determine location details. Please try again.'),
          ),
        );
      }
    } catch (e) {
      print('Error getting location from map tap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error getting location details. Please try again.'),
        ),
      );
    }
  }

  /// Use current location as selected location
  Future<void> _useCurrentLocation() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current location. Please try again.'),
        ),
      );
      return;
    }

    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Getting your current location...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Reverse geocode current position
      final location = await _googleMapsService.reverseGeocode(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (location != null) {
        final locationModel = LocationModel(
          id: location.placeId.hashCode,
          name: location.name,
          code: location.placeId,
          country: location.formattedAddress,
          type: LocationType.other,
          latitude: location.latitude,
          longitude: location.longitude,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        widget.onLocationSelected(locationModel);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not determine location details. Please try again.'),
          ),
        );
      }
    } catch (e) {
      print('Error using current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error getting current location. Please try again.'),
        ),
      );
    }
  }

  Widget _buildLocationItem(LocationModel location) {
    final isSelected = widget.selectedLocation?.id == location.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onLocationSelected(location);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.borderColor.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getLocationIcon(location.type.toString()),
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textPrimaryColor,
                        ),
                      ),
                      if (location.country.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          location.country,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                      if (location.code.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          location.code,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    LucideIcons.checkCircle,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLocationItem(GoogleLocation location) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Convert GoogleLocation to LocationModel
            final locationModel = LocationModel(
              id: location.placeId.hashCode,
              name: location.name,
              code: location.placeId,
              country: location.formattedAddress,
              type: _parseLocationType(location.locationType),
              latitude: location.latitude,
              longitude: location.longitude,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            widget.onLocationSelected(locationModel);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getLocationIcon(location.locationType),
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location.formattedAddress,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      if (location.rating != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${location.rating!.toStringAsFixed(1)} (${location.userRatingsTotal ?? 0} reviews)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Show distance if current position is available
                      if (_currentPosition != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              size: 12,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_calculateDistance(_currentPosition!.latitude, _currentPosition!.longitude, location.latitude, location.longitude).toStringAsFixed(1)} km away',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.externalLink,
                  color: AppTheme.textSecondaryColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LocationType _parseLocationType(String type) {
    switch (type.toLowerCase()) {
      case 'airport':
        return LocationType.airport;
      case 'city':
        return LocationType.city;
      case 'region':
        return LocationType.region;
      default:
        return LocationType.other;
    }
  }

  IconData _getLocationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'airport':
        return LucideIcons.plane;
      case 'city':
        return LucideIcons.mapPin;
      case 'region':
        return LucideIcons.map;
      default:
        return LucideIcons.mapPin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isMapView ? LucideIcons.list : LucideIcons.map,
              color: AppTheme.primaryColor,
            ),
            onPressed: _toggleView,
            tooltip: _isMapView ? 'Switch to List View' : 'Switch to Map View',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.textPrimaryColor,
              ),
              decoration: InputDecoration(
                hintText:
                    widget.placeholder ?? 'Search for airports, cities...',
                hintStyle: GoogleFonts.inter(
                  color: AppTheme.textSecondaryColor,
                ),
                prefixIcon: Icon(
                  LucideIcons.search,
                  color: AppTheme.primaryColor,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          LucideIcons.x,
                          color: AppTheme.textSecondaryColor,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _searchLocations('');
                        },
                      )
                    : _recentSearches.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              LucideIcons.clock,
                              color: AppTheme.textSecondaryColor,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _searchLocations('');
                            },
                            tooltip: 'Show recent searches',
                          )
                        : null,
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.borderColor.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.borderColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Current location option
          if (widget.showCurrentLocation)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _useCurrentLocation,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.navigation,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Use current location',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                        Icon(
                          LucideIcons.arrowRight,
                          color: AppTheme.textSecondaryColor,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Search results or Map view
          Expanded(
            child: _isMapView
                ? _buildMapView()
                : (_isSearching || _isLoadingInitialData)
                    ? _buildSkeletonLoader()
                    : _searchController.text.isEmpty && _recentSearches.isNotEmpty
                        ? _buildRecentSearchesView()
                        : (_searchResults.isEmpty && _googleSearchResults.isEmpty)
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.search,
                                      size: 64,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No locations found',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try searching for airports or cities',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView(
                                children: [
                                  // Google Places results (prioritized)
                                  if (_googleSearchResults.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        'Airports & Locations',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ),
                                    ..._googleSearchResults.map((location) =>
                                        _buildGoogleLocationItem(location)),
                                  ],

                                  // Local database results (secondary)
                                  if (_searchResults.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        'Saved Locations',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ),
                                    ..._searchResults.map(
                                        (location) => _buildLocationItem(location)),
                                  ],
                                ],
                              ),
          ),
        ],
      ),
    );
  }

  /// Build map view
  Widget _buildMapView() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: _mapCenter,
            zoom: _mapZoom,
          ),
          markers: _markers,
          onTap: _onMapTap,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapType: MapType.normal,
        ),
        
        // Map instructions overlay
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.mapPin,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap on the map to select a location, or tap markers to select existing locations',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Current location button
        if (_currentPosition != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppTheme.primaryColor,
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  ),
                );
              },
              child: Icon(
                LucideIcons.navigation,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  /// Build recent searches view
  Widget _buildRecentSearchesView() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                LucideIcons.clock,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Recent Searches',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _recentSearches.clear();
                  });
                  _saveRecentSearches();
                },
                child: Text(
                  'Clear',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        ..._recentSearches.map((search) => _buildRecentSearchItem(search)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Popular Destinations',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Show popular locations when no search
        if (_googleSearchResults.isNotEmpty)
          ..._googleSearchResults.take(5).map((location) =>
              _buildGoogleLocationItem(location)),
        if (_searchResults.isNotEmpty)
          ..._searchResults.take(3).map((location) =>
              _buildLocationItem(location)),
      ],
    );
  }

  /// Build recent search item
  Widget _buildRecentSearchItem(String search) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _searchController.text = search;
            _searchLocations(search);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  LucideIcons.clock,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    search,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    size: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _recentSearches.remove(search);
                    });
                    _saveRecentSearches();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build skeleton loader for search results
  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6, // Show 6 skeleton items
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: Shimmer.fromColors(
            baseColor: AppTheme.borderColor.withValues(alpha: 0.3),
            highlightColor: AppTheme.borderColor.withValues(alpha: 0.1),
            period: const Duration(milliseconds: 1500),
            child: Row(
              children: [
                // Icon skeleton
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                // Text skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main text skeleton
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Subtitle skeleton
                      Container(
                        height: 14,
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Code skeleton (for some items)
                      if (index % 3 == 0)
                        Container(
                          height: 12,
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ),
                // Arrow skeleton
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
