import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/charter_deals_provider.dart';
import '../../core/models/charter_deal_model.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/loading_system.dart';
import '../widgets/offline_fallback_widget.dart';
import 'deal_card.dart';
import 'grouped_deal_card.dart';
import '../utils/deal_grouping_utils.dart';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart' show kDebugMode;

class DealsListWidget extends StatefulWidget {
  final String? searchQuery;
  final String? dealType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? aircraftTypeId;
  final bool groupBy;
  final VoidCallback? onDealTap;
  final bool enablePullToRefresh;
  final bool enableInfiniteScroll;

  const DealsListWidget({
    super.key,
    this.searchQuery,
    this.dealType,
    this.fromDate,
    this.toDate,
    this.aircraftTypeId,
    this.groupBy = false,
    this.onDealTap,
    this.enablePullToRefresh = true,
    this.enableInfiniteScroll = true,
  });

  @override
  State<DealsListWidget> createState() => _DealsListWidgetState();
}

class _DealsListWidgetState extends State<DealsListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      dev.log('DealsListWidget: initState called', name: 'deals_list');
    }
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        dev.log('DealsListWidget: Post frame callback - loading initial deals',
            name: 'deals_list');
      }
      _loadInitialDeals();
    });
  }

  @override
  void dispose() {
    if (kDebugMode) {
      dev.log('DealsListWidget: dispose called', name: 'deals_list');
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialDeals() {
    if (kDebugMode) {
      dev.log('DealsListWidget: Loading initial deals...', name: 'deals_list');
      dev.log('DealsListWidget: Search query: ${widget.searchQuery}',
          name: 'deals_list');
      dev.log('DealsListWidget: Deal type: ${widget.dealType}',
          name: 'deals_list');
      dev.log('DealsListWidget: From date: ${widget.fromDate}',
          name: 'deals_list');
      dev.log('DealsListWidget: To date: ${widget.toDate}', name: 'deals_list');
    }

    try {
      final provider = context.read<CharterDealsProvider>();
      if (kDebugMode) {
        dev.log('DealsListWidget: Provider found, calling loadDeals',
            name: 'deals_list');
      }
      provider.loadDeals(
        searchQuery: widget.searchQuery,
        dealType: widget.dealType,
        fromDate: widget.fromDate,
        toDate: widget.toDate,
        aircraftTypeId: widget.aircraftTypeId,
        groupBy: widget.groupBy,
      );
    } catch (e) {
      if (kDebugMode) {
        dev.log('DealsListWidget: Error loading deals: $e', name: 'deals_list');
      }
    }
  }

  void _onScroll() {
    if (!widget.enableInfiniteScroll) return;

    final provider = context.read<CharterDealsProvider>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (provider.hasMoreData && !provider.isLoadingMore) {
        if (kDebugMode) {
          dev.log('DealsListWidget: Loading more deals...', name: 'deals_list');
        }
        provider.loadMoreDeals(
          searchQuery: widget.searchQuery,
          dealType: widget.dealType,
          fromDate: widget.fromDate,
          toDate: widget.toDate,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      dev.log('DealsListWidget: build called', name: 'deals_list');
    }

    return Consumer<CharterDealsProvider>(
      builder: (context, provider, child) {
        if (kDebugMode) {
          dev.log(
              'DealsListWidget: Consumer rebuild - state: ${provider.state}',
              name: 'deals_list');
          dev.log(
              'DealsListWidget: Consumer rebuild - deals count: ${provider.deals.length}',
              name: 'deals_list');
          dev.log(
              'DealsListWidget: Consumer rebuild - has error: ${provider.hasError}',
              name: 'deals_list');
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (kDebugMode) {
              dev.log('DealsListWidget: Pull to refresh triggered',
                  name: 'deals_list');
            }
            await provider.refreshDeals(
              searchQuery: widget.searchQuery,
              dealType: widget.dealType,
              fromDate: widget.fromDate,
              toDate: widget.toDate,
            );
          },
          child: _buildContent(provider),
        );
      },
    );
  }

  Widget _buildContent(CharterDealsProvider provider) {
    if (kDebugMode) {
      dev.log('DealsListWidget: _buildContent called', name: 'deals_list');
      dev.log('DealsListWidget: Current state: ${provider.state}',
          name: 'deals_list');
      dev.log('DealsListWidget: Deals count: ${provider.deals.length}',
          name: 'deals_list');
      dev.log('DealsListWidget: Has error: ${provider.hasError}',
          name: 'deals_list');
      if (provider.hasError) {
        dev.log('DealsListWidget: Error message: ${provider.errorMessage}',
            name: 'deals_list');
      }
    }

    switch (provider.state) {
      case CharterDealsState.initial:
        if (kDebugMode) {
          dev.log('DealsListWidget: Showing initial state (empty)',
              name: 'deals_list');
        }
        return const SizedBox.shrink();

      case CharterDealsState.loading:
        if (kDebugMode) {
          dev.log('DealsListWidget: Showing loading state (shimmer)',
              name: 'deals_list');
        }
        return const DealListShimmer(itemCount: 4);

      case CharterDealsState.loaded:
        if (kDebugMode) {
          dev.log('DealsListWidget: Showing loaded state', name: 'deals_list');
        }
        if (provider.deals.isEmpty) {
          if (kDebugMode) {
            dev.log('DealsListWidget: No deals found, showing empty state',
                name: 'deals_list');
          }
          return _buildEmptyState();
        }
        if (kDebugMode) {
          dev.log(
              'DealsListWidget: Showing deals list with ${provider.deals.length} deals',
              name: 'deals_list');
        }
        return _buildDealsList(provider);

      case CharterDealsState.error:
        if (kDebugMode) {
          dev.log('DealsListWidget: Showing error state', name: 'deals_list');
        }
        return _buildErrorState(provider);

      case CharterDealsState.loadingMore:
        if (kDebugMode) {
          dev.log('DealsListWidget: Showing loading more state',
              name: 'deals_list');
        }
        return _buildDealsListWithLoadingMore(provider);

      case CharterDealsState.offline:
        if (kDebugMode) {
          dev.log('DealsListWidget: Showing offline state with cached data',
              name: 'deals_list');
        }
        return _buildOfflineState(provider);

      default:
        if (kDebugMode) {
          dev.log('DealsListWidget: Unknown state, showing empty',
              name: 'deals_list');
        }
        return const SizedBox.shrink();
    }
  }

  Widget _buildDealsList(CharterDealsProvider provider) {
    // Group deals by route and aircraft
    final groupedDeals = DealGroupingUtils.groupDeals(provider.deals);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: groupedDeals.length,
      itemBuilder: (context, index) {
        final dealGroup = groupedDeals[index];

        // If only one deal in group, show regular deal card
        if (dealGroup.length == 1) {
          final deal = dealGroup.first;
          return DealCard(
            imageUrl: deal.imageUrl,
            route: deal.routeDisplay,
            date: deal.dateDisplay,
            flightsAvailable: deal.flightsAvailableDisplay,
            price: deal.priceDisplay,
            onTap: () {
              widget.onDealTap?.call();
              _showBookingDetail(context, deal);
            },
          );
        }

        // If multiple deals, show grouped deal card
        return GroupedDealCard(
          deals: dealGroup,
          onDealTap: () {
            widget.onDealTap?.call();
          },
        );
      },
    );
  }

  Widget _buildDealsListWithLoadingMore(CharterDealsProvider provider) {
    // Group deals by route and aircraft
    final groupedDeals = DealGroupingUtils.groupDeals(provider.deals);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: groupedDeals.length + 1,
      itemBuilder: (context, index) {
        if (index == groupedDeals.length) {
          // Loading more indicator
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: LoadingSystem.inline(
                size: 20,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }

        final dealGroup = groupedDeals[index];

        // If only one deal in group, show regular deal card
        if (dealGroup.length == 1) {
          final deal = dealGroup.first;
          return DealCard(
            imageUrl: deal.imageUrl,
            route: deal.routeDisplay,
            date: deal.dateDisplay,
            flightsAvailable: deal.flightsAvailableDisplay,
            price: deal.priceDisplay,
            onTap: () {
              widget.onDealTap?.call();
              _showBookingDetail(context, deal);
            },
          );
        }

        // If multiple deals, show grouped deal card
        return GroupedDealCard(
          deals: dealGroup,
          onDealTap: () {
            widget.onDealTap?.call();
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
            Icons.flight_takeoff,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No deals available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new charter deals',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  final provider = context.read<CharterDealsProvider>();
                  provider.refreshDeals(
                    searchQuery: widget.searchQuery,
                    dealType: widget.dealType,
                    fromDate: widget.fromDate,
                    toDate: widget.toDate,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineState(CharterDealsProvider provider) {
    return Column(
      children: [
        // Offline indicator at the top
        OfflineIndicator(
          lastLoadTime: provider.lastLoadTime ?? 'unknown time',
          onRetry: () {
            provider.loadDeals(
              searchQuery: widget.searchQuery,
              dealType: widget.dealType,
              fromDate: widget.fromDate,
              toDate: widget.toDate,
              aircraftTypeId: widget.aircraftTypeId,
              groupBy: widget.groupBy,
              forceRefresh: true,
            );
          },
        ),
        
        // Show cached deals if available
        if (provider.deals.isNotEmpty) ...[
          Expanded(
            child: _buildDealsList(provider),
          ),
        ] else ...[
          // No cached data available
          Expanded(
            child: OfflineFallbackWidget(
              message: provider.errorMessage ?? 'No internet connection. Please check your network.',
              onRetry: () {
                provider.loadDeals(
                  searchQuery: widget.searchQuery,
                  dealType: widget.dealType,
                  fromDate: widget.fromDate,
                  toDate: widget.toDate,
                  aircraftTypeId: widget.aircraftTypeId,
                  groupBy: widget.groupBy,
                  forceRefresh: true,
                );
              },
              icon: Icons.cloud_off_outlined,
              iconColor: Colors.orange.shade400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorState(CharterDealsProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage ?? 'Failed to load deals',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  provider.clearError();
                  _loadInitialDeals();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Retry'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  provider.clearError();
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBookingDetail(BuildContext context, CharterDealModel deal) {
    // Navigate to booking detail page
    Navigator.pushNamed(
      context,
      '/booking-detail',
      arguments: deal,
    );
  }
}
