import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/charter_deals_provider.dart';
import '../../core/models/charter_deal_model.dart';
import '../widgets/shimmer_loading.dart';
import 'deal_card.dart';

class DealsListWidget extends StatefulWidget {
  final String? searchQuery;
  final String? dealType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback? onDealTap;
  final bool enablePullToRefresh;
  final bool enableInfiniteScroll;

  const DealsListWidget({
    super.key,
    this.searchQuery,
    this.dealType,
    this.fromDate,
    this.toDate,
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
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialDeals();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialDeals() {
    final provider = context.read<CharterDealsProvider>();
    provider.loadDeals(
      searchQuery: widget.searchQuery,
      dealType: widget.dealType,
      fromDate: widget.fromDate,
      toDate: widget.toDate,
    );
  }

  void _onScroll() {
    if (!widget.enableInfiniteScroll) return;

    final provider = context.read<CharterDealsProvider>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (provider.hasMoreData && !provider.isLoadingMore) {
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
    return Consumer<CharterDealsProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () async {
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
    switch (provider.state) {
      case CharterDealsState.initial:
        return const SizedBox.shrink();

      case CharterDealsState.loading:
        return const DealListShimmer(itemCount: 4);

      case CharterDealsState.loaded:
        if (provider.deals.isEmpty) {
          return _buildEmptyState();
        }
        return _buildDealsList(provider);

      case CharterDealsState.error:
        return _buildErrorState(provider);

      case CharterDealsState.loadingMore:
        return _buildDealsListWithLoadingMore(provider);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDealsList(CharterDealsProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: provider.deals.length,
      itemBuilder: (context, index) {
        final deal = provider.deals[index];
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
      },
    );
  }

  Widget _buildDealsListWithLoadingMore(CharterDealsProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: provider.deals.length + 1,
      itemBuilder: (context, index) {
        if (index == provider.deals.length) {
          // Loading more indicator
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Loading more deals...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final deal = provider.deals[index];
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
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
    // This would show the booking detail modal
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${deal.routeDisplay}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
