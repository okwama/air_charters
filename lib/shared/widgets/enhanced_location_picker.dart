import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme/app_theme.dart';
import '../../config/env/maps_config.dart';
import '../../core/services/locations_service.dart';
import '../../core/services/google_maps_service.dart';
import '../../core/services/location_cache_service.dart';
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
  final LocationCacheService _cacheService = LocationCacheService();
  final ScrollController _scrollController = ScrollController();
  List<LocationModel> _searchResults = [];
  List<GoogleLocation> _googleSearchResults = [];
  List<String> _recentSearches = [];
  bool _isSearching = false;
  bool _isLoadingInitialData = true;
  bool _isLoadingMore = false;
  Position? _currentPosition;
  String? _currentCountry;
  Timer? _searchDebounce;
  static const Duration _searchDelay =
      Duration(milliseconds: 250); // Reduced for instant feel

  // Pagination state
  int _dbOffset = 0;
  bool _hasMoreDb = true;
  String? _googleNextPageToken;
  static const int _pageSize = 50;

  // Map view state
  bool _isMapView = false;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng _mapCenter = const LatLng(0.0, 0.0);
  double _mapZoom = 10.0;

  @override
  void initState() {
    super.initState();
    _initializeMapCenter();
    _getCurrentLocation();
    _loadPopularLocations();
    _loadRecentSearches();
    _scrollController.addListener(_onScroll);
  }

  /// Initialize map center based on current location or default
  void _initializeMapCenter() {
    if (_currentPosition != null) {
      _mapCenter =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    } else {
      _mapCenter =
          const LatLng(MapsConfig.defaultLatitude, MapsConfig.defaultLongitude);
    }
    _mapZoom = MapsConfig.defaultZoom;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  /// Handle scroll events for infinite scroll
  void _onScroll() {
    if (_isMapView) return; // Only for list view

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * 0.8; // Load more when 80% scrolled

    if (currentScroll >= threshold &&
        !_isLoadingMore &&
        (_hasMoreDb || _googleNextPageToken != null)) {
      _loadMoreResults();
    }
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
      // UBER PATTERN: Show cached instantly, then update with fresh
      final cacheKey = 'popular_${_currentCountry ?? 'global'}';

      // STEP 1: Try cache first (INSTANT - 0ms)
      final cached = await _cacheService.getCachedSearch(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        print('⚡ INSTANT: Showing ${cached.length} cached popular locations');
        setState(() {
          _googleSearchResults = cached;
          _searchResults = [];
          _isLoadingInitialData = false; // Show screen NOW
        });
      }

      // STEP 2: Fetch fresh in background (don't block UI)
      SearchResult? googleResult;

      if (_currentCountry != null) {
        try {
          googleResult = await _googleMapsService.searchLocations(
            query: 'airport in $_currentCountry',
            type: 'airport',
            location: _currentPosition != null
                ? '${_currentPosition!.latitude},${_currentPosition!.longitude}'
                : null,
            radius: _currentPosition != null ? 500000 : null,
          );
          print(
              '🔄 Background: Loaded ${googleResult.locations.length} fresh airports for $_currentCountry');
        } catch (e) {
          print('Error loading country-specific airports: $e');
        }
      }

      if (googleResult == null || googleResult.locations.isEmpty) {
        try {
          googleResult = await _googleMapsService.searchLocations(
            query: 'major airport',
            type: 'airport',
          );
          print(
              '🔄 Background: Loaded ${googleResult.locations.length} global airports');
        } catch (e) {
          print('Error loading global airports: $e');
        }
      }

      // STEP 3: Update UI with fresh data
      if (googleResult != null && googleResult.locations.isNotEmpty) {
        setState(() {
          _googleSearchResults = googleResult!.locations;
          _searchResults = [];
          _isLoadingInitialData = false;
        });

        // Cache fresh results for next time
        await _cacheService.cacheSearch(cacheKey, googleResult.locations);
        print('💾 Cached ${googleResult.locations.length} popular locations');
      }
    } catch (e) {
      print('Error loading popular locations: $e');
      setState(() {
        _isLoadingInitialData = false;
      });
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      await _loadPopularLocations();
      return;
    }

    // Add to recent searches
    _addToRecentSearches(query);

    // Reset pagination
    _dbOffset = 0;
    _hasMoreDb = true;
    _googleNextPageToken = null;

    setState(() {
      _isSearching = true;
    });

    try {
      // Search both Google Places and local database in parallel
      final results = await Future.wait([
        _searchGooglePlaces(query),
        _locationsService.searchLocations(query, limit: _pageSize, offset: 0),
      ]);

      final SearchResult googleResults = results[0] as SearchResult;
      final LocationSearchResult localResults =
          results[1] as LocationSearchResult;

      setState(() {
        _googleSearchResults = googleResults.locations;
        _googleNextPageToken = googleResults.nextPageToken;
        _searchResults = localResults.locations;
        _hasMoreDb = localResults.hasMore;
        _dbOffset = _pageSize;
        _isSearching = false;
      });

      print(
          '🔍 Search completed: ${googleResults.locations.length} Google + ${localResults.locations.length} local results');
      if (_googleNextPageToken != null) {
        print('📄 Google has more pages available');
      }
      if (_hasMoreDb) {
        print('📄 Database has more results (total: ${localResults.total})');
      }

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

  /// Load more results for infinite scroll
  Future<void> _loadMoreResults() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final query = _searchController.text;

      // Load more from both Google and Database if available
      List<GoogleLocation> moreGoogleResults = [];
      List<LocationModel> moreDbResults = [];

      if (_googleNextPageToken != null) {
        final googleResult =
            await _searchGooglePlaces(query, pageToken: _googleNextPageToken);
        moreGoogleResults = googleResult.locations;
        _googleNextPageToken = googleResult.nextPageToken;
        print('📄 Loaded ${moreGoogleResults.length} more Google results');
      }

      if (_hasMoreDb) {
        final dbResult = await _locationsService.searchLocations(
          query,
          limit: _pageSize,
          offset: _dbOffset,
        );
        moreDbResults = dbResult.locations;
        _hasMoreDb = dbResult.hasMore;
        _dbOffset += dbResult.locations.length;
        print(
            '📄 Loaded ${moreDbResults.length} more DB results (offset now: $_dbOffset)');
      }

      setState(() {
        _googleSearchResults.addAll(moreGoogleResults);
        _searchResults.addAll(moreDbResults);
        _isLoadingMore = false;
      });

      // Update map markers if in map view
      if (_isMapView) {
        _updateMapMarkers();
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      print('Error loading more results: $e');
    }
  }

  /// Search Google Places with cache-first (Uber pattern)
  Future<SearchResult> _searchGooglePlaces(String query,
      {String? pageToken}) async {
    // If we have a pageToken, skip cache and fetch next page directly
    if (pageToken != null) {
      print('📄 Fetching next page of Google results');
      return await _fetchFreshResults(query, pageToken: pageToken);
    }

    // STEP 1: Check cache first (INSTANT) - only for first page
    final cached = await _cacheService.getCachedSearch(query);
    if (cached != null && cached.isNotEmpty) {
      print('⚡ INSTANT: Showing ${cached.length} cached results for "$query"');
      // Return cached but continue fetching fresh in background
      _fetchFreshResultsInBackground(query);
      return SearchResult(locations: cached, nextPageToken: null);
    }

    // STEP 2: Cache miss - fetch fresh
    print('❌ Cache miss for "$query" - fetching fresh');
    return await _fetchFreshResults(query);
  }

  /// Fetch fresh results and cache them
  Future<SearchResult> _fetchFreshResults(String query,
      {String? pageToken}) async {
    try {
      // Build search query for airports/airstrips
      final searchQuery = '$query airport';
      final location = _currentPosition != null
          ? '${_currentPosition!.latitude},${_currentPosition!.longitude}'
          : null;

      print(
          '🔍 Fetching fresh results for "$searchQuery"${pageToken != null ? " (page ${pageToken.substring(0, 10)}...)" : ""}');

      // Fetch from Google
      SearchResult results;

      if (_currentPosition != null) {
        // Search nearby
        results = await _googleMapsService.searchLocations(
          query: searchQuery,
          type: 'airport',
          location: location,
          radius: 500000, // 500km radius
          pageToken: pageToken,
        );
      } else if (_currentCountry != null) {
        // Search within country
        results = await _googleMapsService.searchLocations(
          query: '$searchQuery in $_currentCountry',
          type: 'airport',
          pageToken: pageToken,
        );
      } else {
        // Global search
        results = await _googleMapsService.searchLocations(
          query: searchQuery,
          type: 'airport',
          pageToken: pageToken,
        );
      }

      // Cache the first page results for 15 minutes
      if (results.locations.isNotEmpty && pageToken == null) {
        await _cacheService.cacheSearch(query, results.locations);
        print('💾 Cached ${results.locations.length} results for "$query"');
      }

      return results;
    } catch (e) {
      print('Error searching Google Places: $e');
      return SearchResult(locations: [], nextPageToken: null);
    }
  }

  /// Fetch fresh results in background without blocking UI
  void _fetchFreshResultsInBackground(String query) {
    _fetchFreshResults(query).then((freshResults) {
      if (mounted && freshResults.locations.isNotEmpty) {
        // Only update if user is still on same search
        if (_searchController.text
            .toLowerCase()
            .contains(query.toLowerCase())) {
          setState(() {
            _googleSearchResults = freshResults.locations;
            _googleNextPageToken = freshResults.nextPageToken;
          });
          print(
              '🔄 Updated with ${freshResults.locations.length} fresh results in background');
        }
      }
    }).catchError((e) {
      print('Background fetch error: $e');
    });
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
      final recentSearchesJson =
          prefs.getStringList('location_recent_searches') ?? [];
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
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
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
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: () {
            print('🔍 FLUTTER DEBUG: Selected Location - ${location.name}');
            print('🔍 Latitude: ${location.latitude}, Longitude: ${location.longitude}');
            widget.onLocationSelected(location);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.08)
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                    : AppTheme.borderColor.withValues(alpha: 0.15),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container with gradient background
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withValues(alpha: 0.12),
                              AppTheme.primaryColor.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getLocationIcon(location.type.toString()),
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: GoogleFonts.inter(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textPrimaryColor,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (location.country.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              size: 12,
                              color: AppTheme.textSecondaryColor
                                  .withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location.country,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.textSecondaryColor
                                      .withValues(alpha: 0.85),
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (location.code.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                                : AppTheme.borderColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            location.code,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondaryColor
                                      .withValues(alpha: 0.75),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.check,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
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
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.borderColor.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container with gradient
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.12),
                        AppTheme.primaryColor.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getLocationIcon(location.locationType),
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: GoogleFonts.inter(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: 12,
                            color: AppTheme.textSecondaryColor
                                .withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location.formattedAddress,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textSecondaryColor
                                    .withValues(alpha: 0.85),
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Rating and distance row
                      if (location.rating != null ||
                          _currentPosition != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Rating badge
                            if (location.rating != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.star,
                                      size: 11,
                                      color: Colors.amber.shade700,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      location.rating!.toStringAsFixed(1),
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            // Distance badge
                            if (_currentPosition != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.navigation,
                                      size: 11,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${_calculateDistance(_currentPosition!.latitude, _currentPosition!.longitude, location.latitude, location.longitude).toStringAsFixed(1)} km',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.arrowRight,
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.6),
                    size: 16,
                  ),
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
                    : _searchController.text.isEmpty &&
                            _recentSearches.isNotEmpty
                        ? _buildRecentSearchesView()
                        : (_searchResults.isEmpty &&
                                _googleSearchResults.isEmpty)
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
                                controller: _scrollController,
                                children: [
                                  // Google Places results
                                  if (_googleSearchResults.isNotEmpty) ...[
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          16, 12, 16, 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              LucideIcons.globe,
                                              size: 14,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            _searchController.text.isEmpty
                                                ? 'Suggested Airports'
                                                : 'Top Results',
                                            style: GoogleFonts.inter(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimaryColor,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppTheme.primaryColor
                                                      .withValues(alpha: 0.15),
                                                  AppTheme.primaryColor
                                                      .withValues(alpha: 0.1),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${_googleSearchResults.length}',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ..._googleSearchResults.map((location) =>
                                        _buildGoogleLocationItem(location)),
                                  ],

                                  // Database results
                                  if (_searchResults.isNotEmpty) ...[
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          16, 20, 16, 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondaryColor
                                            .withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.secondaryColor
                                              .withValues(alpha: 0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppTheme.secondaryColor
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              LucideIcons.database,
                                              size: 14,
                                              color: AppTheme.secondaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'All Airports',
                                            style: GoogleFonts.inter(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimaryColor,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppTheme.secondaryColor
                                                      .withValues(alpha: 0.15),
                                                  AppTheme.secondaryColor
                                                      .withValues(alpha: 0.1),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${_searchResults.length}${_hasMoreDb ? "+" : ""}',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.secondaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ..._searchResults.map((location) =>
                                        _buildLocationItem(location)),
                                  ],

                                  // Loading indicator
                                  if (_isLoadingMore)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),

                                  // End of results message
                                  if (!_isLoadingMore &&
                                      !_hasMoreDb &&
                                      _googleNextPageToken == null &&
                                      _searchResults.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: Text(
                                          'All results loaded',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 16),
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
                    LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
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
          ..._googleSearchResults
              .take(5)
              .map((location) => _buildGoogleLocationItem(location)),
        if (_searchResults.isNotEmpty)
          ..._searchResults
              .take(3)
              .map((location) => _buildLocationItem(location)),
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
