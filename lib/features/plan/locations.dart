import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme/app_theme.dart';
import '../../core/services/locations_service.dart';
import '../../core/models/location_model.dart';

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
  final LocationsService _locationsService = LocationsService();
  List<LocationModel> _allLocations = [];
  List<LocationModel> _filteredLocations = [];
  bool _isLoading = true;
  String? _errorMessage;

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
              (location.iataCode?.toLowerCase().contains(query) ?? false) ||
              location.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadLocations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final locations = await _locationsService.getAllLocations();

      setState(() {
        _allLocations = locations;
        _filteredLocations = locations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load locations. Please try again.';
      });
      print('Error loading locations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft,
              color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: AppTheme.heading3.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select ${widget.title.toLowerCase()}',
              style: AppTheme.heading2.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              style: AppTheme.bodyMedium,
              decoration: AppTheme.inputDecoration.copyWith(
                hintText: 'Search by airport or city',
                prefixIcon: const Icon(
                  LucideIcons.search,
                  color: AppTheme.textSecondaryColor,
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
                      color: AppTheme.primaryColor,
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.alertCircle,
                              size: 64,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error',
                              style: AppTheme.heading3.copyWith(
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadLocations,
                              style: AppTheme.primaryButtonStyle,
                              child: Text(
                                'Retry',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _filteredLocations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.mapPin,
                                  size: 64,
                                  color: AppTheme.textSecondaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No locations found',
                                  style: AppTheme.heading3.copyWith(
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondaryColor,
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
                              color: AppTheme.borderColor.withOpacity(0.3),
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Airport icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.mapPin,
                color: AppTheme.primaryColor,
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
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${location.city}, ${location.country}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryColor,
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
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  location.iataCode!,
                  style: AppTheme.caption.copyWith(
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
