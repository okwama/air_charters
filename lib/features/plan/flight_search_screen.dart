import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:air_charters/features/plan/locations.dart';
import 'package:air_charters/shared/widgets/calendar_selector.dart';
import 'package:air_charters/shared/widgets/custom_button.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  LocationModel? _originLocation;
  LocationModel? _destinationLocation;
  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _isRoundTrip = false;
  bool _isLoadingDeals = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Plan Your Flight',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Origin and Destination Selection
            _buildLocationSelection(),

            const SizedBox(height: 24),

            // Date Selection (only show if both locations are selected)
            if (_originLocation != null && _destinationLocation != null) ...[
              _buildDateSelection(),
              const SizedBox(height: 32),
              _buildNextButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where are you flying?',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 20),

        // Origin Selection
        _buildLocationTile(
          title: 'From',
          location: _originLocation,
          onTap: () => _selectOrigin(),
        ),

        const SizedBox(height: 16),

        // Destination Selection
        _buildLocationTile(
          title: 'To',
          location: _destinationLocation,
          onTap: () => _selectDestination(),
        ),
      ],
    );
  }

  Widget _buildLocationTile({
    required String title,
    required LocationModel? location,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                title == 'From' ? Icons.flight_takeoff : Icons.flight_land,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location?.name ?? 'Select ${title.toLowerCase()}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: location != null ? Colors.black : Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (location != null)
                    Text(
                      '${location!.city}, ${location!.country}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your dates',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 8),

        // Selected route display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.flight_takeoff, color: Colors.blue[600], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_originLocation!.city} → ${_destinationLocation!.city}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Trip type selector
        Row(
          children: [
            Expanded(
              child: _buildTripTypeButton(
                'One Way',
                !_isRoundTrip,
                () => setState(() => _isRoundTrip = false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTripTypeButton(
                'Round Trip',
                _isRoundTrip,
                () => setState(() => _isRoundTrip = true),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Date selection buttons
        Row(
          children: [
            Expanded(
              child: _buildDateButton(
                'Departure',
                _departureDate,
                () => _selectDepartureDate(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateButton(
                'Return',
                _returnDate,
                _isRoundTrip ? () => _selectReturnDate() : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripTypeButton(
      String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(String title, DateTime? date, VoidCallback? onTap) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isEnabled ? Colors.grey[300]! : Colors.grey[200]!,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isEnabled ? Colors.white : Colors.grey[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isEnabled ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${_getMonthName(date.month)} ${date.day}, ${date.year}'
                  : 'Select date',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isEnabled
                    ? (date != null ? Colors.black : Colors.grey[500])
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final canProceed =
        _departureDate != null && (!_isRoundTrip || _returnDate != null);

    return CustomButton(
      text: _isLoadingDeals ? 'Searching...' : 'Search Flights',
      onPressed: canProceed ? _searchFlights : null,
      isLoading: _isLoadingDeals,
    );
  }

  void _selectOrigin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationsScreen(
          title: 'Origin',
          onLocationSelected: (location) {
            setState(() {
              _originLocation = location;
            });
          },
        ),
      ),
    );
  }

  void _selectDestination() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationsScreen(
          title: 'Destination',
          onLocationSelected: (location) {
            setState(() {
              _destinationLocation = location;
            });
          },
        ),
      ),
    );
  }

  void _selectDepartureDate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => CalendarSelector(
          title: 'Select Departure Date',
          onDateSelected: (date) {
            setState(() {
              _departureDate = date;
              // Clear return date if it's before departure date
              if (_returnDate != null && _returnDate!.isBefore(date)) {
                _returnDate = null;
              }
            });
          },
        ),
      ),
    );
  }

  void _selectReturnDate() {
    if (_departureDate == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => CalendarSelector(
          title: 'Select Return Date',
          firstDate: _departureDate!.add(const Duration(days: 1)),
          onDateSelected: (date) {
            setState(() {
              _returnDate = date;
            });
          },
        ),
      ),
    );
  }

  Future<void> _searchFlights() async {
    setState(() {
      _isLoadingDeals = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoadingDeals = false;
    });

    // Check if deals are available (simulate random availability)
    final hasDeals = DateTime.now().millisecond % 2 == 0;

    if (hasDeals) {
      // Navigate to deals/results screen
      _showDealsAvailable();
    } else {
      // Show no deals modal
      _showNoDealsModal();
    }
  }

  void _showDealsAvailable() {
    // TODO: Navigate to deals/results screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Great! We found ${(2 + DateTime.now().millisecond % 8)} deals for your route.',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showNoDealsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Plane icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.flight_takeoff,
                size: 40,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Planning a flight between',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${_originLocation!.city} and ${_destinationLocation!.city}?',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'Contact us, we are happy to help!',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: 'Contact Us',
              onPressed: () {
                Navigator.pop(context);
                _contactUs();
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _contactUs() {
    // TODO: Implement contact functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Contact feature will be implemented soon!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }
}
