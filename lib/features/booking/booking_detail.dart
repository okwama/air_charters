import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared/widgets/calendar_selector.dart';
import 'confirm_booking.dart';

class BookingDetailPage extends StatefulWidget {
  final String departure;
  final String destination;

  const BookingDetailPage({
    super.key,
    required this.departure,
    required this.destination,
  });

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final PageController _pageController = PageController();
  DateTime? _selectedDate;

  // Sample data for demonstration
  final List<String> _destinationImages = [
    'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1583212292454-1fe6229603b7?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1540979388789-6cee28a1cdc9?w=800&h=400&fit=crop',
  ];

  final List<Map<String, dynamic>> _flightResults = [
    {
      'image':
          'https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=300&h=200&fit=crop',
      'date': 'Dec 15, 2024',
      'seats': 8,
      'departureTime': '08:30 AM',
      'amount': 15000,
      'aircraft': 'Citation CJ3+',
      'duration': '2h 30m',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1583212292454-1fe6229603b7?w=300&h=200&fit=crop',
      'date': 'Dec 15, 2024',
      'seats': 12,
      'departureTime': '11:15 AM',
      'amount': 22000,
      'aircraft': 'King Air 350',
      'duration': '2h 45m',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=300&h=200&fit=crop',
      'date': 'Dec 16, 2024',
      'seats': 6,
      'departureTime': '02:00 PM',
      'amount': 18500,
      'aircraft': 'Phenom 300',
      'duration': '2h 20m',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300&h=200&fit=crop',
      'date': 'Dec 17, 2024',
      'seats': 10,
      'departureTime': '09:45 AM',
      'amount': 25000,
      'aircraft': 'Legacy 650',
      'duration': '2h 35m',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar and close button
              _buildModalHeader(),

              // Departure - Destination Header
              _buildRouteHeader(),

              const SizedBox(height: 20),

              // Image Cards with Pagination
              _buildImageCarousel(),

              const SizedBox(height: 24),

              // Filter Badges
              _buildFilterBadges(),

              const SizedBox(height: 24),

              // Flight Results
              _buildFlightResults(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalHeader() {
    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header with title and close button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Flight Details',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF666666),
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF888888),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.departure,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.flight_takeoff_rounded,
              color: Color(0xFF666666),
              size: 20,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'To',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF888888),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.destination,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              // Page changed - can be used for analytics or other purposes
            },
            itemCount: _destinationImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5E5E5),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: _destinationImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          color: Color(0xFF888888),
                          size: 48,
                        ),
                      ),
                    ),

                    // Pagination indicator in bottom right
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E5E5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${index + 1}/${_destinationImages.length}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Options',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterBadge('Booking Options'),
                const SizedBox(width: 8),
                _buildDateFilterBadge(),
                const SizedBox(width: 8),
                _buildPersonFilterBadge(),
                const SizedBox(width: 8),
                _buildFilterBadge('Aircraft'),
                const SizedBox(width: 8),
                _buildFilterBadge('Direct Flight'),
                const SizedBox(width: 20), // Extra space at the end
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDateFilterBadge() {
    return GestureDetector(
      onTap: _showDateSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: Colors.black,
            ),
            const SizedBox(width: 6),
            Text(
              _selectedDate != null ? _formatDate(_selectedDate!) : 'Date',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonFilterBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person_rounded,
            size: 16,
            color: Colors.black,
          ),
          const SizedBox(width: 4),
          Text(
            '1',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Flights',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                '${_flightResults.length} Results',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _flightResults.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final flight = _flightResults[index];
              return _buildFlightCard(flight);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlightCard(Map<String, dynamic> flight) {
    return GestureDetector(
      onTap: () => _showConfirmBooking(flight),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Flight details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Aircraft
                  Row(
                    children: [
                      Text(
                        flight['date'],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF888888),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          flight['aircraft'],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF666666),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Departure time and duration
                  Row(
                    children: [
                      Text(
                        flight['departureTime'],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFB3E5FC),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          flight['duration'],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0277BD),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Seats and Price
                  Row(
                    children: [
                      Icon(
                        Icons.airline_seat_recline_normal_rounded,
                        size: 16,
                        color: const Color(0xFF666666),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${flight['seats']} seats',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${flight['amount'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Aircraft Image
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE5E5E5),
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: flight['image'],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFFF5F5F5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(
                    Icons.flight_rounded,
                    color: Color(0xFF888888),
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmBooking(Map<String, dynamic> flight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ConfirmBookingPage(
          departure: widget.departure,
          destination: widget.destination,
          date: flight['date'],
          time: flight['departureTime'],
          aircraft: flight['aircraft'],
          seats: flight['seats'],
          duration: flight['duration'],
          price: flight['amount'].toDouble(),
        ),
      ),
    );
  }

  void _showDateSelector() async {
    final selectedDate = await showCalendarSelector(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      title: 'Select Flight Date',
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.day}';
  }
}
