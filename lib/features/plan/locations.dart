import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationsScreen extends StatefulWidget {
  final String title;
  final Function(LocationModel) onLocationSelected;

  const LocationsScreen({
    super.key,
    required this.title,
    required this.onLocationSelected,
  });

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationModel> _allLocations = [];
  List<LocationModel> _filteredLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = _allLocations;
      } else {
        _filteredLocations = _allLocations.where((location) {
          return location.name.toLowerCase().contains(query) ||
              location.city.toLowerCase().contains(query) ||
              location.country.toLowerCase().contains(query) ||
              (location.iataCode?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _loadLocations() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Sample data - replace with API call
      _allLocations = [
        LocationModel(
          id: 1,
          name: "Los Angeles International Airport",
          city: "Los Angeles",
          country: "United States",
          iataCode: "LAX",
        ),
        LocationModel(
          id: 2,
          name: "John F. Kennedy International Airport",
          city: "New York",
          country: "United States",
          iataCode: "JFK",
        ),
        LocationModel(
          id: 3,
          name: "Heathrow Airport",
          city: "London",
          country: "United Kingdom",
          iataCode: "LHR",
        ),
        LocationModel(
          id: 4,
          name: "Dubai International Airport",
          city: "Dubai",
          country: "United Arab Emirates",
          iataCode: "DXB",
        ),
        LocationModel(
          id: 5,
          name: "Charles de Gaulle Airport",
          city: "Paris",
          country: "France",
          iataCode: "CDG",
        ),
        LocationModel(
          id: 6,
          name: "Tokyo Haneda Airport",
          city: "Tokyo",
          country: "Japan",
          iataCode: "HND",
        ),
        LocationModel(
          id: 7,
          name: "Singapore Changi Airport",
          city: "Singapore",
          country: "Singapore",
          iataCode: "SIN",
        ),
        LocationModel(
          id: 8,
          name: "Sydney Kingsford Smith Airport",
          city: "Sydney",
          country: "Australia",
          iataCode: "SYD",
        ),
      ];

      _filteredLocations = _allLocations;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
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
          widget.title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Origin text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select ${widget.title.toLowerCase()}',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by airport or city',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Locations list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )
                : _filteredLocations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No locations found',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredLocations.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.grey[200],
                        ),
                        itemBuilder: (context, index) {
                          final location = _filteredLocations[index];
                          return LocationTile(
                            location: location,
                            onTap: () {
                              widget.onLocationSelected(location);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class LocationTile extends StatelessWidget {
  final LocationModel location;
  final VoidCallback onTap;

  const LocationTile({
    super.key,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            // Airport icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.flight_takeoff,
                color: Colors.grey[600],
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Location details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${location.city}, ${location.country}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // IATA code (if available)
            if (location.iataCode != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  location.iataCode!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LocationModel {
  final int id;
  final String name;
  final String city;
  final String country;
  final String? iataCode;
  final String? icaoCode;
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final bool isActive;

  LocationModel({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    this.iataCode,
    this.icaoCode,
    this.latitude,
    this.longitude,
    this.timezone,
    this.isActive = true,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      country: json['country'],
      iataCode: json['iata_code'],
      icaoCode: json['icao_code'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      timezone: json['timezone'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'iata_code': iataCode,
      'icao_code': icaoCode,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return '$name ($city, $country)';
  }
}
