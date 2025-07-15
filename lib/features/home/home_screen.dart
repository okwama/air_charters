import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:air_charters/shared/components/bottom_nav.dart';
import 'package:air_charters/shared/widgets/searchbar.dart' as custom;
import 'package:air_charters/shared/components/deal_card.dart';
import 'package:air_charters/shared/components/deals_list_widget.dart';
import 'package:air_charters/features/booking/booking_detail.dart';
import 'package:air_charters/features/plan/flight_search_screen.dart';
import 'package:air_charters/features/experiences/experience_tours.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/core/providers/charter_deals_provider.dart';

class CharterHomePage extends StatelessWidget {
  const CharterHomePage({super.key});

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
                // Handle filter tap
              },
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/test-grouped-deals');
              },
              icon: const Icon(Icons.bug_report, color: Colors.black),
            ),
          ],
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
                    icon: Icon(LucideIcons.mountain, size: 22),
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
        bottomNavigationBar: const BottomNav(
          currentIndex: 0,
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

        return const DealsListWidget(
          enablePullToRefresh: true,
          enableInfiniteScroll: true,
        );
      },
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
