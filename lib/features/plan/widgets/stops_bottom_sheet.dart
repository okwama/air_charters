import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/models/location_model.dart';
import '../../../core/services/route_calculator_service.dart';
import '../../../config/theme/app_theme.dart';
import './stop_list_item.dart';

class StopsBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<LocationModel> stops;
  final LocationModel? origin;
  final LocationModel? destination;
  final Function(int) onRemoveStop;
  final VoidCallback onConfirm;
  final String? aircraftType;

  const StopsBottomSheet({
    super.key,
    required this.scrollController,
    required this.stops,
    this.origin,
    this.destination,
    required this.onRemoveStop,
    required this.onConfirm,
    this.aircraftType,
  });

  @override
  Widget build(BuildContext context) {
    final totalDistance = _calculateTotalDistance();
    final estimatedTime = _calculateEstimatedTime(totalDistance);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Draggable header area (entire header is draggable)
          Container(
            color: Colors.transparent, // Makes entire area tappable
            child: Column(
              children: [
                // Drag handle
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Header title row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Icon(LucideIcons.mapPin,
                          color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Route Stops',
                        style: AppTheme.heading3.copyWith(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stops.length}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(color: AppTheme.borderColor, height: 1),
              ],
            ),
          ),

          // Stops list (full route: origin → stops → destination)
          Expanded(
            child: _buildFullRouteList(
                scrollController, totalDistance, estimatedTime),
          ),

          // Confirm button (sticky bottom)
          if (stops.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                border: Border(
                  top: BorderSide(color: AppTheme.borderColor, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(LucideIcons.check, size: 20),
                    label: Text(
                      'Confirm Route',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFullRouteList(ScrollController scrollController,
      double totalDistance, double estimatedTime) {
    // Build full route: origin → intermediate stops → destination
    final fullRoute = <LocationModel>[];
    final lockedIndices =
        <int>{}; // Track which indices are locked (origin/destination)

    if (origin != null) {
      fullRoute.add(origin!);
      lockedIndices.add(0);
    }

    final intermediateStartIndex = fullRoute.length;
    fullRoute.addAll(stops);

    if (destination != null) {
      fullRoute.add(destination!);
      lockedIndices.add(fullRoute.length - 1);
    }

    if (fullRoute.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: fullRoute.length + 1, // +1 for summary
      itemBuilder: (context, routeIndex) {
        if (routeIndex == fullRoute.length) {
          return _buildSummaryCard(totalDistance, estimatedTime);
        }

        final location = fullRoute[routeIndex];
        final isLocked = lockedIndices.contains(routeIndex);
        final isOrigin = (origin != null && routeIndex == 0);
        final isDestination =
            (destination != null && routeIndex == fullRoute.length - 1);

        // Calculate distance
        double? distanceFromPrev;
        double? timeFromPrev;
        if (routeIndex > 0) {
          distanceFromPrev = RouteCalculatorService.calculateDistance(
            LatLng(fullRoute[routeIndex - 1].latitude!,
                fullRoute[routeIndex - 1].longitude!),
            LatLng(location.latitude!, location.longitude!),
          );
          timeFromPrev = RouteCalculatorService.calculateFlightTime(
            distanceFromPrev,
            aircraftType ?? 'default',
          );
        }

        return StopListItem(
          stop: location,
          index: routeIndex,
          totalStops: fullRoute.length,
          distanceFromPrevious: distanceFromPrev,
          timeFromPrevious: timeFromPrev,
          isLocked: isLocked,
          label: isOrigin ? 'ORIGIN' : (isDestination ? 'DESTINATION' : null),
          onRemove: () {
            if (!isLocked) {
              // Calculate the actual index in the stops list (not fullRoute)
              final stopIndex = routeIndex - intermediateStartIndex;
              onRemoveStop(stopIndex);
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.mapPin,
            size: 48,
            color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Stops Selected',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap on the map or search to add stops',
            style: AppTheme.caption.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double distance, double time) {
    if (stops.length < 2) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.mapPin, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Route Summary',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  LucideIcons.moveRight,
                  'Total Distance',
                  RouteCalculatorService.formatDistance(distance),
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: AppTheme.borderColor,
              ),
              Expanded(
                child: _buildSummaryItem(
                  LucideIcons.clock,
                  'Est. Flight Time',
                  '~${RouteCalculatorService.formatDuration(time)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondaryColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondaryColor,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateTotalDistance() {
    if (stops.length < 2) return 0;
    final points =
        stops.map((stop) => LatLng(stop.latitude!, stop.longitude!)).toList();
    return RouteCalculatorService.calculateTotalDistance(points);
  }

  double _calculateEstimatedTime(double distance) {
    return RouteCalculatorService.calculateFlightTime(
      distance,
      aircraftType ?? 'default',
    );
  }
}
