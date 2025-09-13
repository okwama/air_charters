import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:air_charters/features/plan/locations.dart';
import 'package:air_charters/shared/widgets/calendar_selector.dart';
import 'package:air_charters/shared/widgets/custom_button.dart';
import '../../core/models/location_model.dart';
import '../../core/services/direct_charter_service.dart';
import 'direct_charter_results_screen.dart';

class DirectCharterWrapper extends StatefulWidget {
  const DirectCharterWrapper({super.key});

  @override
  State<DirectCharterWrapper> createState() => _DirectCharterWrapperState();
}

class _DirectCharterWrapperState extends State<DirectCharterWrapper> {
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('DirectCharterWrapper: initState called');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('DirectCharterWrapper: dispose called');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header without back button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Direct Charter',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            const Expanded(
              child: DirectCharterSearchScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class DirectCharterSearchScreen extends StatefulWidget {
  const DirectCharterSearchScreen({super.key});

  @override
  State<DirectCharterSearchScreen> createState() =>
      _DirectCharterSearchScreenState();
}

class _DirectCharterSearchScreenState extends State<DirectCharterSearchScreen> {
  LocationModel? _originLocation;
  LocationModel? _destinationLocation;
  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _isRoundTrip = false;
  bool _isLoadingDeals = false;
  int _passengerCount = 1;
  final _directCharterService = DirectCharterService();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('DirectCharterSearchScreen: initState called');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('DirectCharterSearchScreen: dispose called');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Plan Your Direct Charter',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for available aircraft for your specific route',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Origin and Destination Selection
          _buildLocationSelection(),

          const SizedBox(height: 24),

          // Date Selection (only show if both locations are selected)
          if (_originLocation != null && _destinationLocation != null) ...[
            _buildDateSelection(),
            const SizedBox(height: 24),
            _buildPassengerSelection(),
            const SizedBox(height: 32),
            _buildNextButton(),
          ],
        ],
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
            fontSize: 20,
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
                      '${location.city}, ${location.country}',
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
      text: _isLoadingDeals ? 'Searching...' : 'Search Direct Charter',
      onPressed: canProceed ? _searchDirectCharter : null,
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

  Future<void> _searchDirectCharter() async {
    setState(() {
      _isLoadingDeals = true;
    });

    try {
      // Prepare search data
      final searchData = {
        'origin': _originLocation!.name,
        'destination': _destinationLocation!.name,
        'departureDateTime': _departureDate!.toIso8601String(),
        'returnDateTime': _returnDate?.toIso8601String(),
        'passengerCount': _passengerCount,
        'tripType': _isRoundTrip ? 'roundtrip' : 'oneway',
      };

      // Search for direct charter aircraft
      final aircraft = await _directCharterService.searchAvailableAircraft(
        origin: searchData['origin'] as String,
        destination: searchData['destination'] as String,
        departureDateTime:
            DateTime.parse(searchData['departureDateTime'] as String),
        returnDateTime: searchData['returnDateTime'] != null
            ? DateTime.parse(searchData['returnDateTime'] as String)
            : null,
        passengerCount: searchData['passengerCount'] as int,
        tripType: searchData['tripType'] as String,
      );

      setState(() {
        _isLoadingDeals = false;
      });

      if (aircraft.isNotEmpty) {
        // Navigate to direct charter results
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DirectCharterResultsScreen(
                aircraft: aircraft,
                searchData: searchData,
              ),
            ),
          );
        }
      } else {
        // Show no aircraft available modal
        _showNoAircraftModal();
      }
    } catch (e) {
      setState(() {
        _isLoadingDeals = false;
      });

      // Show error modal
      _showErrorModal(e.toString());
    }
  }

  Widget _buildPassengerSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passengers',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.grey[600], size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Number of passengers',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _passengerCount > 1
                        ? () => setState(() => _passengerCount--)
                        : null,
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color:
                          _passengerCount > 1 ? Colors.black : Colors.grey[300],
                    ),
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '$_passengerCount',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _passengerCount < 20
                        ? () => setState(() => _passengerCount++)
                        : null,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: _passengerCount < 20
                          ? Colors.black
                          : Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNoAircraftModal() {
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
              'No aircraft available',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'No direct charter aircraft are available for your selected route and dates.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'Try adjusting your dates or contact us for custom arrangements.',
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

  void _showErrorModal(String error) {
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

            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red[600],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Search Error',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'There was an error searching for aircraft. Please try again.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: 'Try Again',
              onPressed: () {
                Navigator.pop(context);
                _searchDirectCharter();
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
