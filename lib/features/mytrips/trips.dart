import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';
import '../../shared/components/bottom_nav.dart';
import '../../core/models/booking_model.dart';
import '../../core/providers/booking_provider.dart';
import '../../shared/widgets/app_spinner.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Fetch bookings when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchUserBookings();
    });
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
              child: Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  if (bookingProvider.isLoading) {
                    return const Center(child: AppSpinner());
                  }

                  if (bookingProvider.error != null) {
                    return _buildErrorState(bookingProvider.error!);
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUpcomingTrips(bookingProvider.upcomingBookings),
                      _buildPastTrips(bookingProvider.pastBookings),
                    ],
                  );
                },
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

  Widget _buildUpcomingTrips(List<BookingModel> upcomingTrips) {
    if (upcomingTrips.isEmpty) {
      return _buildEmptyState(
        'No upcoming trips',
        'Any upcoming trips will appear here',
        true,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: upcomingTrips.length,
      itemBuilder: (context, index) {
        return _buildTripCard(upcomingTrips[index], isUpcoming: true);
      },
    );
  }

  Widget _buildPastTrips(List<BookingModel> pastTrips) {
    if (pastTrips.isEmpty) {
      return _buildEmptyState(
        'No past trips',
        'Your completed trips will appear here',
        false,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pastTrips.length,
      itemBuilder: (context, index) {
        return _buildTripCard(pastTrips[index], isUpcoming: false);
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 140,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  context.read<BookingProvider>().fetchUserBookings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildTripCard(BookingModel booking, {required bool isUpcoming}) {
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
          // Trip route and status
          Row(
            children: [
              Expanded(
                child: Text(
                  '${booking.departure} → ${booking.destination}',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              _buildStatusChip(booking.bookingStatus, booking.paymentStatus),
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
                _formatDate(booking.departureDate),
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
                booking.departureTime,
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
                booking.aircraft,
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
                '${booking.totalPassengers} passenger${booking.totalPassengers > 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),

          if (booking.bookingReference != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.confirmation_number_rounded,
                  size: 16,
                  color: Color(0xFF666666),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ref: ${booking.bookingReference}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Price and action button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${booking.totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  _showTripDetails(booking);
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

  Widget _buildStatusChip(BookingStatus bookingStatus, PaymentStatus paymentStatus) {
    Color backgroundColor;
    Color textColor;
    String text;

    // Determine status display based on booking and payment status
    if (paymentStatus == PaymentStatus.paid && bookingStatus == BookingStatus.confirmed) {
      backgroundColor = const Color(0xFFE8F5E8);
      textColor = const Color(0xFF2E7D32);
      text = 'Confirmed';
    } else if (paymentStatus == PaymentStatus.paid && bookingStatus == BookingStatus.completed) {
      backgroundColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF1976D2);
      text = 'Completed';
    } else if (bookingStatus == BookingStatus.cancelled) {
      backgroundColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F);
      text = 'Cancelled';
    } else if (paymentStatus == PaymentStatus.pending) {
      backgroundColor = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFE65100);
      text = 'Payment Pending';
    } else {
      backgroundColor = const Color(0xFFF3F4F6);
      textColor = const Color(0xFF6B7280);
      text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _showTripDetails(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Trip Details',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Flight details
                _buildDetailSection('Flight Information', [
                  ('Route', '${booking.departure} → ${booking.destination}'),
                  ('Date', _formatDate(booking.departureDate)),
                  ('Time', booking.departureTime),
                  ('Aircraft', booking.aircraft),
                  ('Duration', booking.duration),
                  ('Passengers', '${booking.totalPassengers}'),
                  if (booking.bookingReference != null)
                    ('Reference', booking.bookingReference!),
                ]),

                const SizedBox(height: 20),

                // Passenger details
                if (booking.passengers.isNotEmpty) ...[
                  _buildDetailSection('Passengers', 
                    booking.passengers.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final passenger = entry.value;
                      return ('Passenger $index', passenger.displayName);
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Pricing details
                _buildDetailSection('Pricing', [
                  ('Base Price', '\$${booking.basePrice.toStringAsFixed(2)}'),
                  ('Total Price', '\$${booking.totalPrice.toStringAsFixed(2)}'),
                ]),

                // Special requirements
                if (booking.specialRequirements?.isNotEmpty == true) ...[
                  const SizedBox(height: 20),
                  _buildDetailSection('Special Requirements', [
                    ('Notes', booking.specialRequirements!),
                  ]),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<(String, String)> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Column(
            children: details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      detail.$1,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      detail.$2,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
