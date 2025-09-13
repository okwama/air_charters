import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared/widgets/loading_system.dart';
import 'review_trip.dart';
import '../../core/models/charter_deal_model.dart';

class ConfirmBookingPage extends StatefulWidget {
  final String departure;
  final String destination;
  final String date;
  final String time;
  final String aircraft;
  final int seats;
  final String duration;
  final double price;
  final CharterDealModel? deal; // ✅ Add deal parameter

  const ConfirmBookingPage({
    super.key,
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.aircraft,
    required this.seats,
    required this.duration,
    required this.price,
    this.deal, // ✅ Add deal parameter
  });

  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  final PageController _pageController = PageController();

  // ✅ Use real aircraft images from deal data
  List<String> get _aircraftImages {
    if (widget.deal == null) {
      // Fallback to sample images if no deal data
      return [
        'https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=800&h=400&fit=crop',
        'https://images.unsplash.com/photo-1583212292454-1fe6229603b7?w=800&h=400&fit=crop',
        'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800&h=400&fit=crop',
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&h=400&fit=crop',
      ];
    }

    // Use aircraft images from deal, with fallback to route images
    if (widget.deal!.aircraftImages.isNotEmpty) {
      return widget.deal!.aircraftImages;
    } else if (widget.deal!.routeImages.isNotEmpty) {
      return widget.deal!.routeImages;
    } else if (widget.deal!.routeImageUrl != null) {
      return [widget.deal!.routeImageUrl!];
    } else {
      // Fallback to deal image URL
      return [widget.deal!.imageUrl];
    }
  }

  // ✅ Use real amenities from deal data
  List<Map<String, dynamic>> get _amenities {
    if (widget.deal?.amenities.isNotEmpty == true) {
      // Convert deal amenities to the expected format with IconData
      return widget.deal!.amenities.map((amenity) {
        IconData icon;
        switch (amenity['icon'] as String) {
          case 'wifi':
            icon = Icons.wifi;
            break;
          case 'tv':
            icon = Icons.tv;
            break;
          case 'restaurant':
            icon = Icons.restaurant;
            break;
          case 'airline_seat_flat':
            icon = Icons.airline_seat_flat;
            break;
          case 'airline_seat_recline_normal':
            icon = Icons.airline_seat_recline_normal;
            break;
          case 'ac_unit':
            icon = Icons.ac_unit;
            break;
          case 'luggage':
            icon = Icons.luggage;
            break;
          case 'headset_mic':
            icon = Icons.headset_mic;
            break;
          default:
            icon = Icons.check_circle;
        }
        return {
          'icon': icon,
          'name': amenity['name'] as String,
        };
      }).toList();
    }

    // Fallback to default amenities
    return [
      {'icon': Icons.wifi, 'name': 'Wi-Fi'},
      {'icon': Icons.tv, 'name': 'Entertainment'},
      {'icon': Icons.restaurant, 'name': 'Catering'},
      {'icon': Icons.airline_seat_flat, 'name': 'Reclining Seats'},
      {'icon': Icons.ac_unit, 'name': 'Climate Control'},
      {'icon': Icons.luggage, 'name': 'Baggage Space'},
    ];
  }

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
              // Modal header
              _buildModalHeader(),

              // Departure - Destination
              _buildRouteHeader(),

              const SizedBox(height: 16),

              // Date and Time
              _buildDateTimeSection(),

              const SizedBox(height: 20),

              // Aircraft Images Carousel
              _buildImageCarousel(),

              const SizedBox(height: 24),

              // Aircraft Details
              _buildAircraftDetails(),

              const SizedBox(height: 24),

              // Amenities
              _buildAmenities(),

              const SizedBox(height: 24),

              // Seat Summary Card
              _buildSeatSummary(),

              const SizedBox(height: 24),

              // Confirm Button
              _buildConfirmButton(),

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
                'Confirm Booking',
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    fontSize: 18,
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
              size: 18,
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
                    fontSize: 18,
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

  Widget _buildDateTimeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE8E8E8),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Date',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.date,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE8E8E8),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Time',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.time,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
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
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _aircraftImages.length,
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
                      imageUrl: _aircraftImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) =>
                          LoadingSystem.imagePlaceholder(
                        width: double.infinity,
                        height: double.infinity,
                        backgroundColor: const Color(0xFFF5F5F5),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Icon(
                          Icons.flight_rounded,
                          color: Color(0xFF888888),
                          size: 48,
                        ),
                      ),
                    ),

                    // Pagination indicator
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
                        ),
                        child: Text(
                          '${index + 1}/${_aircraftImages.length}',
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

  Widget _buildAircraftDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aircraft Type',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.aircraft,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.airline_seat_recline_normal_rounded,
                    size: 16,
                    color: Color(0xFF666666),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.seats} seats',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: Color(0xFF666666),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.duration,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amenities',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // True responsive grid layout
          LayoutBuilder(
            builder: (context, constraints) {
              // Determine optimal column count based on screen width and content
              int columns = _getOptimalColumnCount(
                  constraints.maxWidth, _amenities.length);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 8,
                  childAspectRatio:
                      _getChildAspectRatio(constraints.maxWidth, columns),
                ),
                itemCount: _amenities.length,
                itemBuilder: (context, index) =>
                    _buildAmenityItem(_amenities[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  // Determine optimal column count based on screen width and content
  int _getOptimalColumnCount(double screenWidth, int itemCount) {
    if (screenWidth > 600 && itemCount > 6) {
      return 3; // 3 columns for tablets/desktop with many items
    } else if (itemCount > 1) {
      return 2; // Always 2 columns when we have more than 1 item
    }
    return 1; // Single column only for 1 item
  }

  // Calculate child aspect ratio based on screen width and columns
  double _getChildAspectRatio(double screenWidth, int columns) {
    if (columns == 1) {
      return 4.0; // Wider for single column
    } else if (columns == 2) {
      return 3.5; // Standard for two columns
    } else {
      return 3.0; // Slightly taller for three columns
    }
  }

  Widget _buildAmenityItem(Map<String, dynamic> amenity) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive font size based on available width
        double fontSize = constraints.maxWidth > 200 ? 13 : 12;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 200 ? 12 : 8,
            vertical: constraints.maxWidth > 200 ? 10 : 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFE8E8E8),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                amenity['icon'],
                size: constraints.maxWidth > 200 ? 18 : 16,
                color: const Color(0xFF666666),
              ),
              SizedBox(width: constraints.maxWidth > 200 ? 8 : 6),
              Expanded(
                child: Text(
                  amenity['name'],
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeatSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aircraft',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                  ),
                ),
                Text(
                  widget.aircraft,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seats Available',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                  ),
                ),
                Text(
                  '${widget.seats} seats',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Flight Duration',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                  ),
                ),
                Text(
                  widget.duration,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFE8E8E8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Price',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '\$${widget.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to review trip
            _showReviewTrip();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'Confirm This Deal',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showReviewTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewTripPage(
          departure: widget.departure,
          destination: widget.destination,
          date: widget.date,
          time: widget.time,
          aircraft: widget.aircraft,
          seats: widget.seats,
          duration: widget.duration,
          price: widget.price,
          deal: widget.deal, // ✅ Pass deal to ReviewTripPage
        ),
      ),
    );
  }
}
