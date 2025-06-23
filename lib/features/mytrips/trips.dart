import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';
import '../../shared/components/bottom_nav.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data - empty for now to show empty state
  final List<Map<String, dynamic>> _upcomingTrips = [];
  final List<Map<String, dynamic>> _pastTrips = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Text(
                'My Trips',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),

            // Tab Selector
            _buildTabSelector(),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingTrips(),
                  _buildPastTrips(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(
        currentIndex: 1, // Trips tab index
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: const Color(0xFF666666),
            indicatorColor: Colors.black,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Upcoming Trips'),
              Tab(text: 'Past Trips'),
            ],
          ),
          Container(
            height: 1,
            color: const Color(0xFFE5E5E5),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTrips() {
    if (_upcomingTrips.isEmpty) {
      return _buildEmptyState(
        'No trips',
        'Any upcoming trips will appear here',
        true,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _upcomingTrips.length,
      itemBuilder: (context, index) {
        return _buildTripCard(_upcomingTrips[index]);
      },
    );
  }

  Widget _buildPastTrips() {
    if (_pastTrips.isEmpty) {
      return _buildEmptyState(
        'No trips',
        'Your completed trips will appear here',
        false,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _pastTrips.length,
      itemBuilder: (context, index) {
        return _buildTripCard(_pastTrips[index]);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, bool showButton) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Calendar Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 40,
                color: Color(0xFF666666),
              ),
            ),

            const SizedBox(height: 24),

            // No trips text
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            // Hint text
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),

            if (showButton) ...[
              const SizedBox(height: 32),

              // Book a flight button
              SizedBox(
                width: 140,
                height: 40,
                child: ElevatedButton(
                  onPressed: _navigateToBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Book a flight',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip route
          Row(
            children: [
              Expanded(
                child: Text(
                  trip['route'] ?? 'Flight Route',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: trip['status'] == 'confirmed'
                      ? const Color(0xFFE8F5E8)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trip['status'] ?? 'Pending',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trip['status'] == 'confirmed'
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Date and time
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Color(0xFF666666),
              ),
              const SizedBox(width: 8),
              Text(
                trip['date'] ?? 'Date',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: Color(0xFF666666),
              ),
              const SizedBox(width: 8),
              Text(
                trip['time'] ?? 'Time',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Aircraft and passengers
          Row(
            children: [
              const Icon(
                Icons.flight_rounded,
                size: 16,
                color: Color(0xFF666666),
              ),
              const SizedBox(width: 8),
              Text(
                trip['aircraft'] ?? 'Aircraft',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.person_rounded,
                size: 16,
                color: Color(0xFF666666),
              ),
              const SizedBox(width: 8),
              Text(
                '${trip['passengers'] ?? 1} passenger${(trip['passengers'] ?? 1) > 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price and action button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trip['price'] ?? '\$0',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle trip details
                },
                child: Text(
                  'View Details',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToBooking() {
    // Navigate to home screen (deals tab)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const CharterHomePage(),
      ),
      (route) => false,
    );
  }
}
