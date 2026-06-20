import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:air_charters/shared/widgets/calendar_selector.dart';
import 'package:air_charters/core/services/experiences_service.dart';
import 'package:air_charters/core/network/api_client.dart';
import 'package:air_charters/core/models/experience_booking_model.dart';
import 'package:air_charters/config/theme/app_theme.dart';
import 'experience_passenger_form.dart';

class TourDetailPage extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String duration;
  final String price;
  final String? rating;
  final String description;
  final int? experienceId;

  const TourDetailPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.duration,
    required this.price,
    this.rating,
    required this.description,
    this.experienceId,
  });

  @override
  State<TourDetailPage> createState() => _TourDetailPageState();
}

class _TourDetailPageState extends State<TourDetailPage> {
  DateTime? _selectedDate;
  int _passengersCount = 1;

  // Experience details with all images
  Map<String, dynamic>? _experienceDetails;
  int? _companyId; // Store companyId from experience details
  List<String> _allImages = [];
  bool _isLoadingDetails = false;
  String? _errorMessage;

  // Page controller for image carousel
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  // Sample amenities for the tour
  final List<Map<String, dynamic>> _amenities = [
    {'icon': Icons.camera_alt, 'name': 'Professional Photography'},
    {'icon': Icons.safety_divider, 'name': 'Safety Equipment'},
    {'icon': Icons.person, 'name': 'Expert Guide'},
    {'icon': Icons.restaurant, 'name': 'Refreshments'},
    {'icon': Icons.translate, 'name': 'Multi-language Support'},
    {'icon': Icons.medical_services, 'name': 'First Aid Kit'},
  ];

  // Price breakdown
  double get basePrice {
    try {
      return double.parse(widget.price.replaceAll(RegExp(r'[^\d.]'), ''));
    } catch (e) {
      return 0.0;
    }
  }

  double get pricePerMinute => basePrice / 30; // Assuming 30 minutes default
  double get totalPrice => basePrice * _passengersCount;

  @override
  void initState() {
    super.initState();
    // Initialize with the passed image
    _allImages = [widget.imageUrl];
    // Fetch full experience details if we have an experience ID
    if (widget.experienceId != null) {
      _fetchExperienceDetails();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchExperienceDetails() async {
    if (widget.experienceId == null) return;

    setState(() {
      _isLoadingDetails = true;
      _errorMessage = null;
    });

    try {
      final experiencesService = ExperiencesService(ApiClient());
      final details =
          await experiencesService.getExperienceDetails(widget.experienceId!);

      setState(() {
        _experienceDetails = details;
        // Extract companyId for booking
        _companyId = details['companyId'] as int?;
        // Extract all images from the response and sort by sortOrder
        final images = details['images'] as List<dynamic>? ?? [];
        final sortedImages = List<Map<String, dynamic>>.from(images);
        sortedImages.sort((a, b) {
          final sortOrderA = a['sortOrder'] as int? ?? 0;
          final sortOrderB = b['sortOrder'] as int? ?? 0;
          return sortOrderA.compareTo(sortOrderB);
        });
        _allImages = sortedImages.map((img) => img['url'] as String).toList();
        // If no images found, keep the original image
        if (_allImages.isEmpty) {
          _allImages = [widget.imageUrl];
        }
        _isLoadingDetails = false;
      });

      // Debug: Print the images we found
      if (kDebugMode) {
        print('🖼️ Found ${_allImages.length} images:');
        for (int i = 0; i < _allImages.length; i++) {
          print('  Image $i: ${_allImages[i]}');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load experience details';
        _isLoadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar (Simple)
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppTheme.textPrimaryColor,
                  size: 20,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: AppTheme.textPrimaryColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Image Carousel Section
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: Stack(
                children: [
                  _buildImageCarousel(),
                  // Rating badge
                  if (widget.rating != null)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.backgroundColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.rating!,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Location
                  Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.location,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'About This Experience',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.description,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Price Breakdown
                  _buildPriceBreakdown(),
                  const SizedBox(height: 24),

                  // Pickup Location
                  _buildPickupLocation(),
                  const SizedBox(height: 24),

                  // Date Selection
                  _buildDateSelection(),
                  const SizedBox(height: 24),

                  // Passengers
                  _buildPassengersSection(),
                  const SizedBox(height: 24),

                  // Amenities
                  _buildAmenities(),
                  const SizedBox(height: 24),

                  // Book Now Button
                  _buildBookNowButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
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
            'Price Breakdown',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Base Price',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                ),
              ),
              Text(
                widget.price,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price per minute',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                ),
              ),
              Text(
                '\$${pricePerMinute.toStringAsFixed(2)}/min',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duration',
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
                  color: AppTheme.textPrimaryColor,
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
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupLocation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
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
            'Pickup Location',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF666666),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Downtown Heliport',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '123 Aviation Blvd, ${widget.location}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
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
            'Select Date',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final selectedDate = await showCalendarSelector(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                title: 'Select Date',
              );

              if (selectedDate != null) {
                setState(() {
                  _selectedDate = selectedDate;
                });
              }
            },
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
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: Color(0xFF666666),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Choose your preferred date',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _selectedDate != null
                            ? Colors.black
                            : const Color(0xFF666666),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF666666),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
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
            'Number of Passengers',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_passengersCount > 1) {
                    setState(() {
                      _passengersCount--;
                    });
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _passengersCount > 1
                        ? Colors.black
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: _passengersCount > 1
                        ? Colors.white
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_passengersCount',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_passengersCount < 6) {
                    setState(() {
                      _passengersCount++;
                    });
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _passengersCount < 6
                        ? Colors.black
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: _passengersCount < 6
                        ? Colors.white
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
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
            'What\'s Included',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
            ),
            itemCount: _amenities.length,
            itemBuilder: (context, index) {
              final amenity = _amenities[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE8E8E8),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      amenity['icon'],
                      size: 20,
                      color: const Color(0xFF666666),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        amenity['name'],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookNowButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: widget.experienceId != null ? _navigateToBooking : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          disabledBackgroundColor: const Color(0xFFE5E5E5),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF888888),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Book Now - \$${(totalPrice).toStringAsFixed(2)}',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _navigateToBooking() {
    if (widget.experienceId == null) return;

    // Validate required fields
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a date for your experience',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Extract price from string (remove $ and convert to double)
    final priceString = widget.price.replaceAll(RegExp(r'[^\d.]'), '');
    final price = double.tryParse(priceString) ?? 0.0;

    // Extract duration in minutes
    final durationText = widget.duration.toLowerCase();
    int durationMinutes = 0;
    if (durationText.contains('hour')) {
      final hours =
          double.tryParse(durationText.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      durationMinutes = (hours * 60).round();
    } else if (durationText.contains('minute')) {
      durationMinutes =
          int.tryParse(durationText.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    } else if (durationText.contains('day')) {
      final days =
          double.tryParse(durationText.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      durationMinutes = (days * 24 * 60).round();
    }

    // Navigate directly to passenger form with booking details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExperiencePassengerForm(
          booking: ExperienceBookingModel(
            experienceId: widget.experienceId!,
            companyId: _companyId, // Pass companyId from experience details
            experienceTitle: widget.title,
            location: widget.location,
            imageUrl: widget.imageUrl,
            price: price,
            priceUnit: 'per_person',
            durationMinutes: durationMinutes,
            selectedDate: _selectedDate!,
            selectedTime: '09:00 AM', // Default time - can be enhanced later
            passengersCount: _passengersCount,
            passengers: [], // Will be filled in the form
            status: 'pending',
            createdAt: DateTime.now(),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (kDebugMode) {
      print('🖼️ Building carousel with ${_allImages.length} images');
      print('🖼️ Current index: $_currentImageIndex');
    }

    if (_isLoadingDetails) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_allImages.length == 1) {
      // Single image display
      return CachedNetworkImage(
        imageUrl: _allImages.first,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 48,
          ),
        ),
      );
    }

    // Multiple images - use PageView for carousel
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _allImages.length,
          onPageChanged: (index) {
            if (kDebugMode) {
              print('🖼️ Page changed to: $index');
            }
            setState(() {
              _currentImageIndex = index;
            });
          },
          physics:
              const BouncingScrollPhysics(), // Use bouncing physics for better gesture handling
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: _allImages[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.textPrimaryColor,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 48,
                ),
              ),
            );
          },
        ),
        // Page indicators
        if (_allImages.length > 1) ...[
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _allImages.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          // Image counter
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${_allImages.length}',
                style: GoogleFonts.inter(
                  color: AppTheme.backgroundColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
