import 'package:flutter/material.dart';
import '../../core/services/yacht_service.dart';
import '../../config/theme/app_theme.dart';
import '../../shared/components/skeleton/skeleton_card.dart';
import '../../shared/widgets/network_error_widget.dart';
import '../../shared/widgets/image_carousel.dart';
import '../../core/error/network_error_handler.dart';
import 'yacht_booking_screen.dart';

class YachtResultsScreen extends StatefulWidget {
  final YachtType yachtType;

  const YachtResultsScreen({
    super.key,
    required this.yachtType,
  });

  @override
  State<YachtResultsScreen> createState() => _YachtResultsScreenState();
}

class _YachtResultsScreenState extends State<YachtResultsScreen> {
  final YachtService _yachtService = YachtService();
  List<Yacht> _yachts = [];
  bool _isLoading = true;
  NetworkErrorResult? _error;
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadYachts();
  }

  Future<void> _loadYachts({bool loadMore = false}) async {
    try {
      if (loadMore) {
        setState(() {
          _isLoadingMore = true;
        });
      } else {
        setState(() {
          _isLoading = true;
          _error = null;
          _currentPage = 1;
          _hasMoreData = true;
        });
      }

      final result = await _yachtService.getYachts(
        page: _currentPage,
        limit: _limit,
        type: widget.yachtType.type,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _yachts.addAll(result['yachts'] as List<Yacht>);
            _isLoadingMore = false;
          } else {
            _yachts = result['yachts'] as List<Yacht>;
            _isLoading = false;
          }

          _hasMoreData = _currentPage < (result['totalPages'] as int);
          _currentPage++;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is NetworkException
              ? e.errorResult
              : NetworkErrorResult.fromException(e);
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _navigateToYachtBooking(Yacht yacht) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YachtBookingScreen(
          yacht: yacht,
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
          '${widget.yachtType.type.toUpperCase()} Yachts',
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
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_yachts.isEmpty) {
      return _buildEmptyState();
    }

    return _buildYachtsList();
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available ${widget.yachtType.type.toUpperCase()} Yachts',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: SkeletonCard(
                  height: 200,
                  borderRadius: 16,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: QuickNetworkErrorWidget(
        error: _error?.message ?? 'Failed to load yachts',
        onRetry: () => _loadYachts(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_boat,
            size: 64,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Yachts Available',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No ${widget.yachtType.type} yachts are currently available.\nPlease check back later.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _loadYachts(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildYachtsList() {
    return RefreshIndicator(
      onRefresh: () => _loadYachts(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available ${widget.yachtType.type.toUpperCase()} Yachts',
              style: AppTheme.heading3.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _yachts.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _yachts.length) {
                  // Load more indicator
                  if (_isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (_hasMoreData) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () => _loadYachts(loadMore: true),
                          child: const Text('Load More'),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }

                final yacht = _yachts[index];
                return _buildYachtCard(yacht);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYachtCard(Yacht yacht) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _navigateToYachtBooking(yacht),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.inputFillColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Yacht Image Carousel
              ImageCarousel(
                images: yacht.images.map((img) => img.url).toList(),
                height: 200,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                placeholderIcon: Icon(
                  Icons.directions_boat,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
                showIndicators: true,
              ),
              // Yacht Info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            yacht.name,
                            style: AppTheme.heading3.copyWith(
                              color: AppTheme.textPrimaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: yacht.isAvailable
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            yacht.isAvailable ? 'Available' : 'Unavailable',
                            style: AppTheme.bodySmall.copyWith(
                              color: yacht.isAvailable
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      yacht.description,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${yacht.capacity} passengers',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${yacht.location}, ${yacht.city}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From \$${yacht.pricePerHour}/hour',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${yacht.pricePerDay}/day',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: yacht.isAvailable
                              ? () => _navigateToYachtBooking(yacht)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Book Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
