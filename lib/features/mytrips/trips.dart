import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../booking/payment/in_app_checkout_screen.dart';
import '../../core/models/user_trip_model.dart';
import '../../core/models/booking_model.dart' as booking_model;
import '../../core/providers/trips_provider.dart';
import '../../core/providers/navigation_provider.dart';
import '../../shared/widgets/app_spinner.dart';
import '../../core/providers/auth_provider.dart';
import 'ticket_page.dart';
import 'pages/trip_details_page.dart';
import '../../config/env/app_config.dart';

class TripsPage extends StatefulWidget {
  final int initialTabIndex;

  const TripsPage({super.key, this.initialTabIndex = 0});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: (widget.initialTabIndex >= 0 && widget.initialTabIndex < 4)
          ? widget.initialTabIndex
          : 0,
    );

    // Fetch trips when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure TripsProvider has a reference to AuthProvider for token/auth state
      final auth = context.read<AuthProvider>();
      final trips = context.read<TripsProvider>();
      trips.setAuthProvider(auth);
      trips.fetchUserTrips();
    });
  }

  @override
  void didUpdateWidget(TripsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-refresh when navigating to trips tab (Uber-style)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trips = context.read<TripsProvider>();

      // Only refresh if data is stale (> 30s old)
      if (trips.isDataStale) {
        debugPrint('TripsPage: Data stale, auto-refreshing...');
        trips.fetchUserTrips();
      } else {
        debugPrint('TripsPage: Data fresh, using cache');
      }
    });
  }

  Future<void> _refreshTrips() async {
    print('=== TRIPS PAGE: REFRESHING DATA ===');
    try {
      final auth = context.read<AuthProvider>();
      final trips = context.read<TripsProvider>();
      trips.setAuthProvider(auth);
      await trips.fetchUserTrips();
      print('=== TRIPS PAGE: REFRESH COMPLETED ===');

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  trips.trips.isEmpty
                      ? 'No trips found'
                      : 'Refreshed ${trips.trips.length} trips',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: trips.trips.isEmpty ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      print('=== TRIPS PAGE: REFRESH FAILED: $e ===');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Failed to refresh trips',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _refreshTrips,
            ),
          ),
        );
      }
    }
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
      body: Stack(
        children: [
          // World SVG Background with overlay
          Positioned.fill(
            child: Stack(
              children: [
                Opacity(
                  opacity: 0.05,
                  child: SvgPicture.asset(
                    'assets/icons/world.svg',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section with Back Button and Refresh
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'My Trips',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Consumer<TripsProvider>(
                        builder: (context, tripsProvider, child) {
                          return IconButton(
                            onPressed:
                                tripsProvider.isLoading ? null : _refreshTrips,
                            icon: Icon(
                              Icons.refresh_rounded,
                              color: tripsProvider.isLoading
                                  ? Colors.grey
                                  : Colors.black,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Tab Selector
                _buildTabSelector(),

                // Tab Content
                Expanded(
                  child: Consumer<TripsProvider>(
                    builder: (context, tripsProvider, child) {
                      if (tripsProvider.isLoading &&
                          tripsProvider.pendingTrips.isEmpty &&
                          tripsProvider.upcomingTrips.isEmpty &&
                          tripsProvider.completedTrips.isEmpty &&
                          tripsProvider.cancelledTrips.isEmpty) {
                        return const Center(child: AppSpinner());
                      }

                      if (tripsProvider.error != null) {
                        return _buildErrorState(tripsProvider.error!);
                      }

                      return RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _refreshTrips,
                        color: Colors.black,
                        backgroundColor: Colors.white,
                        strokeWidth: 2.5,
                        displacement: 40,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildRefreshableTabContent(
                              _buildPendingTrips(tripsProvider.pendingTrips),
                              tripsProvider.pendingTrips.isEmpty,
                            ),
                            _buildRefreshableTabContent(
                              _buildUpcomingTrips(tripsProvider.upcomingTrips),
                              tripsProvider.upcomingTrips.isEmpty,
                            ),
                            _buildRefreshableTabContent(
                              _buildCompletedTrips(
                                  tripsProvider.completedTrips),
                              tripsProvider.completedTrips.isEmpty,
                            ),
                            _buildRefreshableTabContent(
                              _buildCancelledTrips(
                                  tripsProvider.cancelledTrips),
                              tripsProvider.cancelledTrips.isEmpty,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildRefreshableTabContent(Widget content, bool isEmpty) {
    return content;
  }

  Widget _buildPendingTrips(List<UserTripModel> pendingTrips) {
    if (pendingTrips.isEmpty) {
      return _buildEmptyState(
        'No pending bookings',
        'Any pending bookings will appear here',
        true,
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: pendingTrips.length,
      itemBuilder: (context, index) {
        return _buildTripCard(pendingTrips[index],
            isUpcoming: false, isPending: true);
      },
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

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: upcomingTrips.length,
      itemBuilder: (context, index) {
        return _buildTripCard(upcomingTrips[index], isUpcoming: true);
      },
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

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: completedTrips.length,
      itemBuilder: (context, index) {
        return _buildTripCard(completedTrips[index], isUpcoming: false);
      },
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

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: cancelledTrips.length,
      itemBuilder: (context, index) {
        return _buildTripCard(cancelledTrips[index], isUpcoming: false);
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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
              textAlign: TextAlign.center,
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

  // Router method: decides which card to render based on booking type
  Widget _buildTripCard(UserTripModel trip,
      {required bool isUpcoming, bool isPending = false}) {
    final booking = trip.booking;

    // Route to appropriate card based on booking type
    if (booking != null) {
      switch (booking.bookingType) {
        case booking_model.BookingType.experience:
          return _buildExperienceCard(trip,
              isUpcoming: isUpcoming, isPending: isPending);
        case booking_model.BookingType.yacht:
          return _buildYachtCard(trip,
              isUpcoming: isUpcoming, isPending: isPending);
        case booking_model.BookingType.direct:
        case booking_model.BookingType.deal:
          return _buildCharterCard(trip,
              isUpcoming: isUpcoming, isPending: isPending);
      }
    }

    // Fallback for bookings without booking data
    return _buildCharterCard(trip,
        isUpcoming: isUpcoming, isPending: isPending);
  }

  // Charter/Deal booking card
  Widget _buildCharterCard(UserTripModel trip,
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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

            // Stops Row (if available)
            if (_hasStops(booking)) ...[
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: Color(0xFF666666),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _formatStops(booking),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

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
                // Price (show "Awaiting Quote" for pending inquiries with $0 price)
                Text(
                  (booking.bookingStatus ==
                              booking_model.BookingStatus.pending &&
                          booking.totalPrice == 0)
                      ? 'Awaiting Quote'
                      : '\$${booking.totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: (booking.bookingStatus ==
                                booking_model.BookingStatus.pending &&
                            booking.totalPrice == 0)
                        ? 13
                        : 16,
                    fontWeight: FontWeight.w700,
                    color: (booking.bookingStatus ==
                                booking_model.BookingStatus.pending &&
                            booking.totalPrice == 0)
                        ? const Color(0xFFFF9800) // Orange for pending
                        : Colors.black,
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
              // Pending tab: show Proceed to Pay when priced (totalPrice > 0) and payment pending
              if (isPending && booking != null)
                if (booking.totalPrice > 0 &&
                    booking.paymentStatus ==
                        booking_model.PaymentStatus.pending)
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
                        'Proceed to Pay',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              if (isUpcoming && booking != null) ...[
                // Pay Now button for pending payments
                if (trip.status == UserTripStatus.pending &&
                    booking.paymentStatus ==
                        booking_model.PaymentStatus.pending)
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
              // View Ticket button for confirmed + paid bookings (in Upcoming/Completed)
              if (!isPending && booking != null)
                if (booking.paymentStatus == booking_model.PaymentStatus.paid)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TicketPage(booking: booking),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'View Ticket',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              // View Details button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripDetailsPage(trip: trip),
                    ),
                  );
                },
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

  // Experience booking card
  Widget _buildExperienceCard(UserTripModel trip,
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
          // Header: Experience Title, Reference, and Status Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Reference
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Experience Title
                    Text(
                      booking?.experienceTitle ?? 'Experience',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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

          // Experience Details
          if (booking != null) ...[
            Row(
              children: [
                // Location
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking.experienceLocation ?? 'N/A',
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

          // Action Buttons (same as charter)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isPending && booking != null)
                if (booking.totalPrice > 0 &&
                    booking.paymentStatus ==
                        booking_model.PaymentStatus.pending)
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
                        'Proceed to Pay',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              if (isUpcoming && booking != null) ...[
                if (trip.status == UserTripStatus.pending &&
                    booking.paymentStatus ==
                        booking_model.PaymentStatus.pending)
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
              if (!isPending && booking != null)
                if (booking.paymentStatus == booking_model.PaymentStatus.paid)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TicketPage(booking: booking),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'View Ticket',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripDetailsPage(trip: trip),
                    ),
                  );
                },
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

  // Yacht booking card
  Widget _buildYachtCard(UserTripModel trip,
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
          // Header: Yacht Title, Reference, and Status Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Reference
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Yacht Title
                    Text(
                      booking?.departure ?? 'Yacht Charter',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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

          // Yacht Details
          if (booking != null) ...[
            Row(
              children: [
                // Yacht icon
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions_boat_rounded,
                        size: 14,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking.aircraftName ?? 'Yacht',
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

          // Action Buttons (same as others)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isPending && booking != null)
                if (booking.totalPrice > 0 &&
                    booking.paymentStatus ==
                        booking_model.PaymentStatus.pending)
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
                        'Proceed to Pay',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              if (isUpcoming && booking != null) ...[
                if (trip.status == UserTripStatus.pending &&
                    booking.paymentStatus ==
                        booking_model.PaymentStatus.pending)
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
              if (!isPending && booking != null)
                if (booking.paymentStatus == booking_model.PaymentStatus.paid)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TicketPage(booking: booking),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'View Ticket',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripDetailsPage(trip: trip),
                    ),
                  );
                },
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
      case UserTripStatus.pending:
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        text = 'Pending';
        icon = Icons.pending;
        break;
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

  Widget _buildPaymentStatusChip(booking_model.BookingModel booking) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (booking.paymentStatus) {
      case booking_model.PaymentStatus.paid:
        backgroundColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        text = 'Paid';
        icon = Icons.check_circle;
        break;
      case booking_model.PaymentStatus.pending:
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case booking_model.PaymentStatus.failed:
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        text = 'Failed';
        icon = Icons.error;
        break;
      case booking_model.PaymentStatus.refunded:
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

  void _payForBooking(booking_model.BookingModel booking) {
    // Get user information for Paystack payment
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to make a payment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get companyId from booking (primary source)
    final companyId = booking.companyId;

    // Debug logging
    print('=== PAYMENT DEBUG INFO ===');
    print('Booking ID: ${booking.id}');
    print('Company ID: $companyId');
    print('Company Name: ${booking.companyName}');
    print('Deal ID: ${booking.dealId}');
    print('User ID: ${booking.userId}');
    print('Total Price: ${booking.totalPrice}');
    print('========================');

    // Use fallback companyId if booking.companyId is null
    final finalCompanyId = companyId ?? 1; // Fallback to company ID 1

    if (companyId == null) {
      print(
          'WARNING: Company ID is null, using fallback company ID: $finalCompanyId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Using default company for payment (Company ID: $finalCompanyId)'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Navigate to Paystack payment screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppCheckoutScreen(
          bookingId: booking.id ?? '',
          amount: booking.totalPrice,
          currency: AppConfig.paystackCurrency.toUpperCase(),
          email: user.email ?? '',
          companyId:
              finalCompanyId, // Dynamic companyId from booking with fallback
          preferredPaymentMethod:
              'card', // Default to card, can be made configurable
        ),
      ),
    ).then((result) async {
      // Handle action results from payment screen
      if (result is Map && result['action'] == 'view_ticket') {
        await context.read<TripsProvider>().fetchUserTrips();
        if (!mounted) return;
        // Push ticket page (don't replace - allows back navigation)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TicketPage(booking: booking),
          ),
        );
      } else if (result is Map && result['action'] == 'done') {
        await context.read<TripsProvider>().fetchUserTrips();
        // Payment screen already closed, stay on trips
      } else if (result == true) {
        // Fallback for old success=true response
        await context.read<TripsProvider>().fetchUserTrips();
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
                    if (_hasStops(booking)) ('Stops', _formatStops(booking)),
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
                    if (booking.bookingStatus ==
                            booking_model.BookingStatus.pending &&
                        booking.totalPrice == 0) ...[
                      ('Status', 'Awaiting Quote'),
                      ('Note', 'The company will send you a quote shortly'),
                    ] else ...[
                      (
                        'Base Price',
                        '\$${(booking.basePrice ?? 0).toStringAsFixed(2)}'
                      ),
                      (
                        'Total Price',
                        '\$${booking.totalPrice.toStringAsFixed(2)}'
                      ),
                    ],
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
    // Navigate to home tab within the main navigation
    // This preserves the bottom navigation bar
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.setCurrentIndex(0); // Switch to home tab (Explore)
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

  /// Check if booking has stops data
  bool _hasStops(booking_model.BookingModel booking) {
    return booking.stops.isNotEmpty;
  }

  /// Format stops for display
  String _formatStops(booking_model.BookingModel booking) {
    if (booking.stops.isEmpty) {
      return 'No stops';
    }

    if (booking.stops.length == 1) {
      return '1 stop: ${booking.stops.first.stopName}';
    }

    // For multiple stops, show count and first few names
    final stopNames =
        booking.stops.take(2).map((stop) => stop.stopName).join(', ');
    if (booking.stops.length == 2) {
      return '2 stops: $stopNames';
    }

    return '${booking.stops.length} stops: $stopNames...';
  }

  String _getBookingStatusDisplay(booking_model.BookingStatus status) {
    switch (status) {
      case booking_model.BookingStatus.confirmed:
        return '✅ Confirmed';
      case booking_model.BookingStatus.pending:
        return '⏳ Pending';
      case booking_model.BookingStatus.cancelled:
        return '❌ Cancelled';
      case booking_model.BookingStatus.completed:
        return '✅ Completed';
    }
  }

  String _getPaymentStatusDisplay(booking_model.PaymentStatus status) {
    switch (status) {
      case booking_model.PaymentStatus.paid:
        return '✅ Paid';
      case booking_model.PaymentStatus.pending:
        return '⏳ Pending Payment';
      case booking_model.PaymentStatus.failed:
        return '❌ Payment Failed';
      case booking_model.PaymentStatus.refunded:
        return '🔄 Refunded';
    }
  }
}
