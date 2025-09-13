import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/shared/widgets/searchbar.dart' as custom;
import 'package:air_charters/shared/components/deals_list_widget.dart';
import 'package:air_charters/features/booking/booking_detail.dart';
import 'package:air_charters/features/plan/flight_search_screen.dart';
import 'package:air_charters/features/experiences/experience_tours.dart';
import 'package:air_charters/core/providers/charter_deals_provider.dart';
import 'package:air_charters/shared/widgets/deals_filter_dialog.dart';
import 'package:air_charters/shared/widgets/filter_chips_widget.dart';
import 'package:air_charters/shared/models/deals_filter_options.dart';

class CharterHomePage extends StatefulWidget {
  const CharterHomePage({super.key});

  @override
  State<CharterHomePage> createState() => _CharterHomePageState();
}

class _CharterHomePageState extends State<CharterHomePage> {
  DealsFilterOptions _filters = const DealsFilterOptions();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('CharterHomePage: initState called');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('CharterHomePage: dispose called');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 90,
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FlightSearchScreen(),
                ),
              );
            },
            child: custom.SearchBar(
              hintText: 'Plan your charter flight',
              enabled: false,
              onFilterTap: () {
                _showFilterDialog(context);
              },
            ),
          ),
          actions: [],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.black,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.local_offer, size: 22),
                    text: 'Deals',
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    icon: Icon(Icons.explore, size: 22),
                    text: 'Experiences',
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildDealsTab(context),
            const ExperienceToursScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildDealsTab(BuildContext context) {
    return Consumer<CharterDealsProvider>(
      builder: (context, provider, child) {
        print('HOME: Provider state: ${provider.state}');
        print('HOME: Deals count: ${provider.deals.length}');
        if (provider.deals.isNotEmpty) {
          print('HOME: First deal: ${provider.deals.first.routeDisplay}');
        }

        return Column(
          children: [
            // Filter chips
            FilterChipsWidget(
              filters: _filters,
              onFilterRemoved: _onFilterRemoved,
              onClearAll: _onClearAllFilters,
            ),

            // Deals list
            Expanded(
              child: DealsListWidget(
                enablePullToRefresh: true,
                enableInfiniteScroll: true,
                aircraftTypeId: _filters.aircraftTypeId,
                groupBy: _filters.groupBy,
                searchQuery: _filters.searchQuery,
              ),
            ),
          ],
        );
      },
    );
  }

  void _onFilterRemoved(DealsFilterOptions newFilters) {
    setState(() {
      _filters = newFilters;
    });
    _applyFilters();
  }

  void _onClearAllFilters() {
    setState(() {
      _filters = const DealsFilterOptions();
    });
    _applyFilters();
  }

  void _applyFilters() {
    // Use debounced loading to prevent rapid successive calls
    context.read<CharterDealsProvider>().debouncedLoadDeals(
          aircraftTypeId: _filters.aircraftTypeId,
          groupBy: _filters.groupBy,
          searchQuery: _filters.searchQuery,
          forceRefresh: true,
        );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DealsFilterDialog(
        initialFilters: _filters,
        onApplyFilters: (newFilters) {
          setState(() {
            _filters = newFilters;
          });
          _applyFilters();
        },
        onClearAll: _onClearAllFilters,
      ),
    );
  }

  void _showBookingDetail(
      BuildContext context, String departure, String destination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => BookingDetailPage(
          departure: departure,
          destination: destination,
        ),
      ),
    );
  }
}
