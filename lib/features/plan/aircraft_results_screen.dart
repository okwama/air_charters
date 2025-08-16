import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/aircraft_availability_model.dart';
import '../../core/models/location_model.dart';
import '../../core/services/aircraft_availability_service.dart';
import '../../shared/widgets/aircraft_card.dart';
import '../booking/aircraft_selection_page.dart';
import 'inquiry/create_inquiry_screen.dart';

class AircraftResultsScreen extends StatefulWidget {
  final LocationModel origin;
  final LocationModel destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int passengerCount;
  final bool isRoundTrip;

  const AircraftResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.passengerCount,
    this.isRoundTrip = false,
  });

  @override
  State<AircraftResultsScreen> createState() => _AircraftResultsScreenState();
}

class _AircraftResultsScreenState extends State<AircraftResultsScreen> {
  final AircraftAvailabilityService _availabilityService =
      AircraftAvailabilityService();

  List<AvailableAircraft> _allAircraft = [];
  List<AvailableAircraft> _filteredAircraft = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter and sort options
  String _selectedSortBy = 'price'; // price, duration, distance
  String _selectedAircraftType = 'all';
  double _maxPrice = double.infinity;

  @override
  void initState() {
    super.initState();
    _loadAvailableAircraft();
  }

  Future<void> _loadAvailableAircraft() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final aircraft = await _availabilityService.searchAvailableAircraft(
        departureLocationId: widget.origin.id,
        arrivalLocationId: widget.destination.id,
        departureDate: widget.departureDate,
        returnDate: widget.returnDate,
        passengerCount: widget.passengerCount,
        isRoundTrip: widget.isRoundTrip,
      );

      setState(() {
        _allAircraft = aircraft;
        _filteredAircraft = aircraft;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load available aircraft. Please try again.';
      });
      print('Error loading aircraft: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAircraft = _allAircraft.where((aircraft) {
        // Filter by aircraft type
        if (_selectedAircraftType != 'all' &&
            aircraft.aircraftType != _selectedAircraftType) {
          return false;
        }

        // Filter by max price
        if (aircraft.totalPrice > _maxPrice) {
          return false;
        }

        return true;
      }).toList();

      // Apply sorting
      _sortAircraft();
    });
  }

  void _sortAircraft() {
    switch (_selectedSortBy) {
      case 'price':
        _filteredAircraft.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
        break;
      case 'duration':
        _filteredAircraft
            .sort((a, b) => a.flightDuration.compareTo(b.flightDuration));
        break;
      case 'distance':
        _filteredAircraft.sort((a, b) => a.distance.compareTo(b.distance));
        break;
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltersBottomSheet(),
    );
  }

  Widget _buildFiltersBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters & Sort',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Sort by
                Text(
                  'Sort by',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip(
                        'price', 'Price', _selectedSortBy == 'price'),
                    _buildFilterChip(
                        'duration', 'Duration', _selectedSortBy == 'duration'),
                    _buildFilterChip(
                        'distance', 'Distance', _selectedSortBy == 'distance'),
                  ],
                ),
                const SizedBox(height: 20),

                // Aircraft type filter
                Text(
                  'Aircraft Type',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip(
                        'all', 'All', _selectedAircraftType == 'all'),
                    _buildFilterChip(
                        'jet', 'Private Jet', _selectedAircraftType == 'jet'),
                    _buildFilterChip('helicopter', 'Helicopter',
                        _selectedAircraftType == 'helicopter'),
                    _buildFilterChip('fixedWing', 'Fixed Wing',
                        _selectedAircraftType == 'fixedWing'),
                  ],
                ),
                const SizedBox(height: 20),

                // Price range
                Text(
                  'Max Price',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _maxPrice == double.infinity ? 10000 : _maxPrice,
                  min: 100,
                  max: 10000,
                  divisions: 99,
                  label:
                      '\$${_maxPrice == double.infinity ? '∞' : _maxPrice.toStringAsFixed(0)}',
                  onChanged: (value) {
                    setState(() {
                      _maxPrice = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (value == 'price' || value == 'duration' || value == 'distance') {
            _selectedSortBy = value;
          } else {
            _selectedAircraftType = value;
          }
        });
      },
      selectedColor: Colors.black,
      checkmarkColor: Colors.white,
      labelStyle: GoogleFonts.inter(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _selectAircraft(AvailableAircraft aircraft) {
    // Check if aircraft has pricing
    if (aircraft.totalPrice > 0) {
      // Navigate to aircraft selection page for booking
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AircraftSelectionPage(
            aircraft: aircraft,
            origin: widget.origin,
            destination: widget.destination,
            departureDate: widget.departureDate,
            returnDate: widget.returnDate,
            passengerCount: widget.passengerCount,
            isRoundTrip: widget.isRoundTrip,
          ),
        ),
      );
    } else {
      // Show inquiry options for aircraft without pricing
      _showInquiryOptions(aircraft);
    }
  }

  void _showInquiryOptions(AvailableAircraft aircraft) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No Pricing Available',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'This aircraft doesn\'t have pricing for your route. Would you like to send an inquiry?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Inquiry button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _createInquiry(aircraft);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Send Inquiry',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _createInquiry(AvailableAircraft aircraft) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateInquiryScreen(
          aircraft: aircraft,
          origin: widget.origin,
          destination: widget.destination,
          departureDate: widget.departureDate,
          returnDate: widget.returnDate,
          passengerCount: widget.passengerCount,
          isRoundTrip: widget.isRoundTrip,
        ),
      ),
    );
  }

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
          'Available Aircraft',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Route summary
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.origin.name} → ${widget.destination.name}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.passengerCount} passenger${widget.passengerCount > 1 ? 's' : ''} • ${widget.departureDate.day}/${widget.departureDate.month}/${widget.departureDate.year}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_filteredAircraft.length} available',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAvailableAircraft,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _filteredAircraft.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.airplanemode_inactive,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No aircraft available',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your filters or dates',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredAircraft.length,
                            itemBuilder: (context, index) {
                              final aircraft = _filteredAircraft[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: AircraftCard(
                                  aircraft: aircraft,
                                  onTap: aircraft.totalPrice > 0
                                      ? () => _selectAircraft(aircraft)
                                      : null,
                                  onInquiryTap: aircraft.totalPrice <= 0
                                      ? () => _createInquiry(aircraft)
                                      : null,
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
