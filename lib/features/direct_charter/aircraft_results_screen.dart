import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/aircraft_type_service.dart';
import '../../config/theme/app_theme.dart';
import '../../shared/components/skeleton/skeleton_loading.dart';
import '../../shared/components/skeleton/skeleton_list_tile.dart';
import '../../shared/widgets/network_error_widget.dart';
import '../../core/error/network_error_handler.dart';
import 'flight_configuration_screen.dart';

class AircraftResultsScreen extends StatefulWidget {
  final AircraftType aircraftType;

  const AircraftResultsScreen({
    super.key,
    required this.aircraftType,
  });

  @override
  State<AircraftResultsScreen> createState() => _AircraftResultsScreenState();
}

class _AircraftResultsScreenState extends State<AircraftResultsScreen> {
  final AircraftTypeService _aircraftTypeService = AircraftTypeService();
  List<Aircraft> _aircraft = [];
  bool _isLoading = true;
  NetworkErrorResult? _error;

  @override
  void initState() {
    super.initState();
    _loadAircraft();
  }

  Future<void> _loadAircraft() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final aircraft = await _aircraftTypeService.getAircraftByType(
        typeId: widget.aircraftType.id,
        userLocation: 'Nairobi', // TODO: Get from user location service
      );

      setState(() {
        _aircraft = aircraft;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is NetworkException
            ? e.errorResult
            : NetworkErrorResult.fromException(e);
        _isLoading = false;
      });
    }
  }

  void _navigateToConfiguration(Aircraft aircraft) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlightConfigurationScreen(
          aircraft: aircraft,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          '${widget.aircraftType.type} Aircraft',
          style: AppTheme.heading3.copyWith(color: AppTheme.textPrimaryColor),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildSkeletonLoading();
    }

    if (_error != null) {
      return NetworkErrorWidget(
        errorResult: _error,
        onRetry: _loadAircraft,
        customMessage:
            'Unable to load available aircraft. Please check your connection and try again.',
      );
    }

    if (_aircraft.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.airplanemode_inactive,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${widget.aircraftType.type} aircraft available',
              style:
                  AppTheme.heading3.copyWith(color: AppTheme.textPrimaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try a different aircraft type',
              style: AppTheme.bodyMedium
                  .copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      );
    }

    return _buildAircraftList();
  }

  Widget _buildSkeletonLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          SkeletonLoading(
            width: 250,
            height: 24,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          SkeletonLoading(
            width: 120,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          // List skeleton
          Expanded(
            child: ListView.builder(
              itemCount: 4, // Show 4 skeleton items
              itemBuilder: (context, index) {
                return const SkeletonListTile();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAircraftList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available ${widget.aircraftType.type} Aircraft',
            style: AppTheme.heading3.copyWith(color: AppTheme.textPrimaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            '${_aircraft.length} aircraft found',
            style:
                AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _aircraft.length,
              itemBuilder: (context, index) {
                final aircraft = _aircraft[index];
                return _buildAircraftCard(aircraft);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAircraftCard(Aircraft aircraft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aircraft image
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              color: AppTheme.borderColor,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: aircraft.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: aircraft.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.borderColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.borderColor,
                        child: Icon(
                          Icons.airplanemode_active,
                          size: 48,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    )
                  : Container(
                      color: AppTheme.borderColor,
                      child: Icon(
                        Icons.airplanemode_active,
                        size: 48,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
            ),
          ),
          // Aircraft details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            aircraft.name,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            aircraft.model,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        aircraft.aircraftType,
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Aircraft specs
                Row(
                  children: [
                    _buildSpecItem(
                      Icons.people,
                      '${aircraft.capacity} pax',
                    ),
                    const SizedBox(width: 16),
                    _buildSpecItem(
                      Icons.access_time,
                      aircraft.formattedFlightDuration,
                    ),
                    const SizedBox(width: 16),
                    _buildSpecItem(
                      Icons.location_on,
                      aircraft.baseCity ?? 'N/A',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Price and company
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            aircraft.formattedPricePerHour,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.successColor,
                            ),
                          ),
                          Text(
                            aircraft.companyName,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _navigateToConfiguration(aircraft),
                      style: AppTheme.primaryButtonStyle.copyWith(
                        minimumSize:
                            WidgetStateProperty.all(const Size(80, 36)),
                        textStyle:
                            WidgetStateProperty.all(AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
                      ),
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTheme.caption.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
