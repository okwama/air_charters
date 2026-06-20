import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/aircraft_type_service.dart';
import '../../config/theme/app_theme.dart';
import '../../shared/components/skeleton/skeleton_loading.dart';
import '../../shared/components/skeleton/skeleton_card.dart';
import '../../shared/widgets/network_error_widget.dart';
import '../../core/error/network_error_handler.dart';
import 'aircraft_results_screen.dart';

// Custom painter for dashed line effect
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AircraftTypeSelectionScreen extends StatefulWidget {
  final bool showBackButton;

  const AircraftTypeSelectionScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<AircraftTypeSelectionScreen> createState() =>
      _AircraftTypeSelectionScreenState();
}

class _AircraftTypeSelectionScreenState
    extends State<AircraftTypeSelectionScreen> {
  final AircraftTypeService _aircraftTypeService = AircraftTypeService();
  List<AircraftType> _aircraftTypes = [];
  bool _isLoading = true;
  NetworkErrorResult? _error;

  @override
  void initState() {
    super.initState();
    _loadAircraftTypes();
  }

  Future<void> _loadAircraftTypes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final aircraftTypes = await _aircraftTypeService.getAircraftTypes();
      setState(() {
        _aircraftTypes = aircraftTypes;
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

  void _navigateToAircraftResults(AircraftType aircraftType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AircraftResultsScreen(
          aircraftType: aircraftType,
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
          'Select Aircraft Type',
          style: AppTheme.heading3.copyWith(color: AppTheme.textPrimaryColor),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppTheme.textPrimaryColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
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
        onRetry: _loadAircraftTypes,
        customMessage:
            'Unable to load aircraft types. Please check your connection and try again.',
      );
    }

    if (_aircraftTypes.isEmpty) {
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
              'No aircraft types available',
              style:
                  AppTheme.heading3.copyWith(color: AppTheme.textPrimaryColor),
            ),
          ],
        ),
      );
    }

    return _buildAircraftTypesGrid();
  }

  Widget _buildSkeletonLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          SkeletonLoading(
            width: 200,
            height: 24,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          SkeletonLoading(
            width: 280,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          // Grid skeleton
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;
                if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                }
                if (constraints.maxWidth > 900) {
                  crossAxisCount = 4;
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65, // Adjusted for ticket design
                  ),
                  itemCount: 6, // Show 6 skeleton cards
                  itemBuilder: (context, index) {
                    return const SkeletonCard(
                      height: 200,
                      borderRadius: 16,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAircraftTypesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Aircraft Type',
            style: AppTheme.heading3.copyWith(color: AppTheme.textPrimaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the type of aircraft that best suits your needs',
            style:
                AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid based on screen width
                int crossAxisCount = 2;
                if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                }
                if (constraints.maxWidth > 900) {
                  crossAxisCount = 4;
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65, // Adjusted for ticket design
                  ),
                  itemCount: _aircraftTypes.length,
                  itemBuilder: (context, index) {
                    final aircraftType = _aircraftTypes[index];
                    return _buildAircraftTypeCard(aircraftType);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAircraftTypeCard(AircraftType aircraftType) {
    return GestureDetector(
      onTap: () => _navigateToAircraftResults(aircraftType),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Ticket Header with Aircraft Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Aircraft Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: aircraftType.placeholderImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: aircraftType.placeholderImageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppTheme.borderColor,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppTheme.borderColor,
                                child: Icon(
                                  Icons.airplanemode_active,
                                  size: 32,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            )
                          : Container(
                              color: AppTheme.borderColor,
                              child: Icon(
                                Icons.airplanemode_active,
                                size: 32,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                    ),

                    // Ticket Header Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: AppTheme.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                    // Aircraft Type Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          aircraftType.type,
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Ticket Perforated Line
            Container(
              height: 1,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.borderColor,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: CustomPaint(
                painter: DashedLinePainter(),
              ),
            ),

            // Ticket Details Section
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Aircraft Type Name
                    Text(
                      aircraftType.type,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryColor,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description
                    if (aircraftType.description != null)
                      Text(
                        aircraftType.description!,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Select Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Aircraft',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
