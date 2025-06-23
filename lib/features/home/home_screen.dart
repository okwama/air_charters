import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:air_charters/shared/components/bottom_nav.dart';
import 'package:air_charters/shared/widgets/searchbar.dart' as custom;
import 'package:air_charters/shared/components/deal_card.dart';
import 'package:air_charters/features/booking/booking_detail.dart';
import 'package:air_charters/features/plan/flight_search_screen.dart';
import 'package:air_charters/features/experiences/experience_tours.dart';

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
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        DealCard(
          imageUrl:
              'https://ik.imagekit.io/bja2qwwdjjy/Aircharter/Light%20Jet%20Luxury%20Aircraft_ujia5zwbw.webp?updatedAt=1749146878253',
          route: 'Groton - Farmingdale',
          date: 'Jul. 31 – Aug. 15',
          flightsAvailable: 'Multiple Flights',
          price: 'CA\$3,694',
          onTap: () => _showBookingDetail(context, 'Groton', 'Farmingdale'),
        ),
        DealCard(
          imageUrl:
              'https://ik.imagekit.io/bja2qwwdjjy/Aircharter/Light%20Jet%20Luxury%20Aircraft_ujia5zwbw.webp?updatedAt=1749146878253',
          route: 'Farmingdale - Groton',
          date: 'Jul. 27 – Jul. 31',
          flightsAvailable: 'Multiple Flights',
          price: 'CA\$3,694',
          onTap: () => _showBookingDetail(context, 'Farmingdale', 'Groton'),
        ),
        DealCard(
          imageUrl:
              'https://ik.imagekit.io/bja2qwwdjjy/Aircharter/Light%20Jet%20Luxury%20Aircraft_ujia5zwbw.webp?updatedAt=1749146878253',
          route: 'New York to Paris',
          date: 'Departing March 15, 2024',
          flightsAvailable: '12 flights available',
          price: '\$489.00',
          onTap: () => _showBookingDetail(context, 'New York', 'Paris'),
        ),
        DealCard(
          imageUrl:
              'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTA1MDU3Nzd8&ixlib=rb-4.1.0&q=80&w=1080',
          route: 'London to Tokyo',
          date: 'Departing April 10, 2024',
          flightsAvailable: '8 flights available',
          price: '\$1,299.00',
          onTap: () => _showBookingDetail(context, 'London', 'Tokyo'),
        ),
      ],
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
