import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';
import '../booking/payment/payment_screen.dart';
import '../../shared/components/bottom_nav.dart';
import '../../core/models/user_trip_model.dart';
import '../../core/models/booking_model.dart';
import '../../core/providers/trips_provider.dart';
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
    _tabController = TabController(length: 4, vsync: this);

    // Fetch trips when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripsProvider>().fetchUserTrips();
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
              child: Consumer<TripsProvider>(
                builder: (context, tripsProvider, child) {
                  if (tripsProvider.isLoading) {
                    return const Center(child: AppSpinner());
                  }

                  if (tripsProvider.error != null) {
                    return _buildErrorState(tripsProvider.error!);
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPendingTrips(tripsProvider.pendingTrips),
                      _buildUpcomingTrips(tripsProvider.upcomingTrips),
                      _buildCompletedTrips(tripsProvider.completedTrips),
                      _buildCancelledTrips(tripsProvider.cancelledTrips),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(
        currentIndex: 2, // Trips tab index (fixed)
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
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
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

  Widget _buildPendingTrips(List<UserTripModel> pendingTrips) {
    if (pendingTrips.isEmpty) {
      return _buildEmptyState(
        'No pending bookings',
        'Any pending bookings will appear here',
        true,
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TripsProvider>().fetchUserTrips(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: pendingTrips.length,
        itemBuilder: (context, index) {
          return _buildTripCard(pendingTrips[index],
              isUpcoming: false, isPending: true);
        },
      ),
    );
  }

  Widget _buildUpcomingTrips(List<UserTripModel> upcomingTrips) {
    if (upcomingTrips.isEmpty) {
      return _buildEmptyState(
        'No upcoming trips',
        'Any upcoming trips will appear here',
        true,
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TripsProvider>().fetchUserTrips(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: upcomingTrips.length,
        itemBuilder: (context, index) {
          return _buildTripCard(upcomingTrips[index], isUpcoming: true);
        },
      ),
    );
  }

  Widget _buildCompletedTrips(List<UserTripModel> completedTrips) {
    if (completedTrips.isEmpty) {
      return _buildEmptyState(
        'No completed trips',
        'Your completed trips will appear here',
        false,
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TripsProvider>().fetchUserTrips(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: completedTrips.length,
        itemBuilder: (context, index) {
          return _buildTripCard(completedTrips[index], isUpcoming: false);
        },
      ),
    );
  }

  Widget _buildCancelledTrips(List<UserTripModel> cancelledTrips) {
    if (cancelledTrips.isEmpty) {
      return _buildEmptyState(
        'No cancelled trips',
        'Your cancelled trips will appear here',
        false,
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TripsProvider>().fetchUserTrips(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: cancelledTrips.length,
        itemBuilder: (context, index) {
          return _buildTripCard(cancelledTrips[index], isUpcoming: false);
        },
      ),
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
                  context.read<TripsProvider>().fetchUserTrips();
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

  Widget _buildTripCard(UserTripModel trip,
      {required bool isUpcoming, bool isPending = false}) {
    final booking = trip.booking;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Route, Reference, and Status Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route and Reference
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route
                    Text(
                      booking != null
                          ? '${booking.departure ?? 'N/A'} → ${booking.destination ?? 'N/A'}'
                          : 'Booking ${trip.bookingId.length >= 8 ? trip.bookingId.substring(0, 8) : trip.bookingId}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Reference Number
                    if (booking?.referenceNumber != null)
                      Text(
                        'Ref: ${booking!.referenceNumber}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Status Badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusChip(trip.status),
                  if (booking != null) ...[
                    const SizedBox(height: 4),
                    _buildPaymentStatusChip(booking),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Flight Details Row
          if (booking != null) ...[
            Row(
              children: [
                // Aircraft Type
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flight_rounded,
                        size: 14,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking.aircraftName ?? 'N/A',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Date
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(booking.departureDate ?? DateTime.now()),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Time
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking.departureTime ?? 'N/A',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Passengers and Price Row
            Row(
              children: [
                // Passengers
                Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      size: 14,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${booking.passengers.length} passenger${booking.passengers.length > 1 ? 's' : ''}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Price
                Text(
                  '\$${booking.totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isUpcoming && booking != null) ...[
                // Pay Now button for pending payments
                if (booking.paymentStatus == PaymentStatus.pending)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () => _payForBooking(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Pay Now',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // Cancel button
                TextButton(
                  onPressed: () => _cancelTrip(trip),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // View Details button
              TextButton(
                onPressed: () => _showTripDetails(trip),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'Details',
                  style: GoogleFonts.inter(
                    fontSize: 12,
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

  Widget _buildStatusChip(UserTripStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case UserTripStatus.upcoming:
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        text = 'Upcoming';
        icon = Icons.schedule;
        break;
      case UserTripStatus.completed:
        backgroundColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        text = 'Completed';
        icon = Icons.check_circle;
        break;
      case UserTripStatus.cancelled:
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        text = 'Cancelled';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: textColor,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChip(BookingModel booking) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (booking.paymentStatus) {
      case PaymentStatus.paid:
        backgroundColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        text = 'Paid';
        icon = Icons.check_circle;
        break;
      case PaymentStatus.pending:
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case PaymentStatus.failed:
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        text = 'Failed';
        icon = Icons.error;
        break;
      case PaymentStatus.refunded:
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        text = 'Refunded';
        icon = Icons.refresh;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: textColor,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _payForBooking(BookingModel booking) {
    // Navigate to payment screen for this booking
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          bookingId: booking.id ?? '',
          amount: booking.totalPrice,
          currency: 'USD',
          // Note: You'll need to get the client secret from the booking
          // This might require an API call to create a payment intent
        ),
      ),
    ).then((result) {
      // Refresh trips after payment
      if (result == true) {
        context.read<TripsProvider>().fetchUserTrips();
      }
    });
  }

  void _cancelTrip(UserTripModel trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Trip',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this trip? This action cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<TripsProvider>().cancelTrip(trip.id);
            },
            child: Text(
              'Yes, Cancel',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTripDetails(UserTripModel trip) {
    final booking = trip.booking;

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

                // Trip information
                _buildDetailSection('Trip Information', [
                  (
                    'Booking ID',
                    trip.bookingId.length >= 8
                        ? trip.bookingId.substring(0, 8)
                        : trip.bookingId
                  ),
                  ('Status', trip.status.name.toUpperCase()),
                  ('Created', _formatDate(trip.createdAt)),
                  if (trip.completedAt != null)
                    ('Completed', _formatDate(trip.completedAt!)),
                  if (trip.cancelledAt != null)
                    ('Cancelled', _formatDate(trip.cancelledAt!)),
                ]),

                if (booking != null) ...[
                  const SizedBox(height: 20),
                  // Booking and Payment Status
                  _buildDetailSection('Booking & Payment Status', [
                    (
                      'Booking Status',
                      _getBookingStatusDisplay(booking.bookingStatus)
                    ),
                    (
                      'Payment Status',
                      _getPaymentStatusDisplay(booking.paymentStatus)
                    ),
                    if (booking.paymentTransactionId != null)
                      ('Transaction ID', booking.paymentTransactionId!),
                  ]),
                ],

                if (booking != null) ...[
                  const SizedBox(height: 20),
                  // Flight details
                  _buildDetailSection('Flight Information', [
                    (
                      'Route',
                      '${booking.departure ?? 'N/A'} → ${booking.destination ?? 'N/A'}'
                    ),
                    (
                      'Date',
                      _formatDate(booking.departureDate ?? DateTime.now())
                    ),
                    ('Time', booking.departureTime ?? 'N/A'),
                    ('Aircraft', booking.aircraftName ?? 'N/A'),
                    ('Duration', '${booking.duration ?? 0} minutes'),
                    ('Passengers', '${booking.passengers.length}'),
                    if (booking.referenceNumber != null)
                      ('Reference', booking.referenceNumber!),
                  ]),

                  const SizedBox(height: 20),

                  // Passenger details
                  if (booking.passengers.isNotEmpty) ...[
                    _buildDetailSection(
                      'Passengers',
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
                    (
                      'Base Price',
                      '\$${(booking.basePrice ?? 0).toStringAsFixed(2)}'
                    ),
                    (
                      'Total Price',
                      '\$${booking.totalPrice.toStringAsFixed(2)}'
                    ),
                  ]),

                  // Special requirements
                  if (booking.specialRequirements?.isNotEmpty == true) ...[
                    const SizedBox(height: 20),
                    _buildDetailSection('Special Requirements', [
                      ('Notes', booking.specialRequirements!),
                    ]),
                  ],
                ],

                // Review section for completed trips
                if (trip.status == UserTripStatus.completed) ...[
                  const SizedBox(height: 20),
                  _buildReviewSection(trip),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewSection(UserTripModel trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (trip.rating != null) ...[
                Row(
                  children: [
                    ...List.generate(
                        5,
                        (index) => Icon(
                              index < trip.rating!
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 20,
                              color: const Color(0xFFFFD700),
                            )),
                    const SizedBox(width: 8),
                    Text(
                      '${trip.rating}/5',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (trip.review != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    trip.review!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
                if (trip.reviewDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Reviewed on ${_formatDate(trip.reviewDate!)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  'No review yet',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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
            children: details
                .map((detail) => Padding(
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
                    ))
                .toList(),
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getBookingStatusDisplay(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return '✅ Confirmed';
      case BookingStatus.pending:
        return '⏳ Pending';
      case BookingStatus.cancelled:
        return '❌ Cancelled';
      case BookingStatus.completed:
        return '✅ Completed';
    }
  }

  String _getPaymentStatusDisplay(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return '✅ Paid';
      case PaymentStatus.pending:
        return '⏳ Pending Payment';
      case PaymentStatus.failed:
        return '❌ Payment Failed';
      case PaymentStatus.refunded:
        return '🔄 Refunded';
    }
  }
}
