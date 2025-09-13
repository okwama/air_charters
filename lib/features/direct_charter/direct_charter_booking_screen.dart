import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/direct_charter_model.dart';
import '../../core/models/location_model.dart';
import '../../core/services/direct_charter_service.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/utils/app_utils.dart';
import '../plan/stops_selection_screen.dart';
import '../booking/booking_confirmation_page.dart';
import '../booking/payment/payment_screen.dart';

class DirectCharterBookingScreen extends StatefulWidget {
  final DirectCharterAircraft aircraft;
  final Map<String, dynamic> searchData;

  const DirectCharterBookingScreen({
    super.key,
    required this.aircraft,
    required this.searchData,
  });

  @override
  State<DirectCharterBookingScreen> createState() =>
      _DirectCharterBookingScreenState();
}

class _DirectCharterBookingScreenState
    extends State<DirectCharterBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _directCharterService = DirectCharterService();
  final _specialRequestsController = TextEditingController();

  bool _isLoading = false;
  bool _agreeToTerms = false;

  // Stops functionality
  List<Map<String, dynamic>> _stops = [];
  final _stopNameController = TextEditingController();
  final _stopLatitudeController = TextEditingController();
  final _stopLongitudeController = TextEditingController();
  final _stopPriceController = TextEditingController();
  final _stopDateTimeController = TextEditingController();

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _navigateToPaymentConfirmation(Map<String, dynamic> bookingData) {
    // Navigate to booking confirmation page for payment
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationPage(
            bookingData: bookingData,
          ),
        ),
      );
    }
  }

  void _navigateToPaymentScreen(Map<String, dynamic> paymentData) {
    // Navigate directly to payment screen with client secret
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            bookingId: paymentData['bookingId'],
            clientSecret: paymentData['clientSecret'],
            amount: paymentData['amount'],
            currency: 'USD',
            paymentIntentId: paymentData['paymentIntentId'],
          ),
        ),
      );
    }
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please agree to the terms and conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse dates safely
      DateTime departureDateTime;
      DateTime? returnDateTime;

      try {
        departureDateTime =
            DateTime.parse(widget.searchData['departureDateTime']);
      } catch (e) {
        throw Exception(
            'Invalid departure date format: ${widget.searchData['departureDateTime']}');
      }

      if (widget.searchData['returnDateTime'] != null) {
        try {
          returnDateTime = DateTime.parse(widget.searchData['returnDateTime']);
        } catch (e) {
          throw Exception(
              'Invalid return date format: ${widget.searchData['returnDateTime']}');
        }
      }

      final result = await _directCharterService.bookDirectCharter(
        aircraftId: widget.aircraft.id,
        origin: widget.searchData['origin'],
        destination: widget.searchData['destination'],
        departureDateTime: departureDateTime,
        returnDateTime: returnDateTime,
        passengerCount: widget.searchData['passengerCount'],
        totalPrice: widget.aircraft.totalPrice,
        pricePerHour: widget.aircraft.pricePerHour,
        repositioningCost: widget.aircraft.repositioningCost,
        tripType: widget.searchData['tripType'],
        specialRequests: _specialRequestsController.text.trim().isEmpty
            ? null
            : _specialRequestsController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (mounted) {
        // Prepare booking data for confirmation
        final bookingData = {
          // Flight details
          'aircraft': widget.aircraft.name,
          'departure': widget.searchData['origin'],
          'destination': widget.searchData['destination'],
          'date': AppUtils.formatDateTime(departureDateTime),

          // Booking details - align with backend Booking entity
          'reference': result.booking['referenceNumber'],
          'id': result.booking['id'],
          'status': result.booking['bookingStatus'],
          'bookingStatus': result.booking['bookingStatus'],
          'paymentStatus': result.booking['paymentStatus'],

          // Passenger information
          'passengerCount': widget.searchData['passengerCount'],
          'passengers': [
            {
              'firstName': 'Direct Charter',
              'lastName': 'Passenger',
              'age': 25,
              'nationality': 'Kenyan',
              'idPassportNumber': 'N/A',
              'isUser': true,
            }
          ],

          // Pricing
          'totalAmount': result.booking['totalPrice'],
          'totalPrice': result.booking['totalPrice'],
          'basePrice': widget.aircraft.pricePerHour,
          'repositioningCost': widget.aircraft.repositioningCost,

          // Flight details
          'departureDate': departureDateTime.toIso8601String(),
          'returnDate': returnDateTime?.toIso8601String(),
          'isRoundTrip': widget.searchData['tripType'] == 'roundtrip',
          'flightDuration': widget.aircraft.flightDurationHours,
          'distance': widget.aircraft.flightDurationHours * 500,

          // Aircraft details
          'aircraftId': widget.aircraft.id,
          'aircraftType': widget.aircraft.model,
          'capacity': widget.aircraft.capacity,
          'companyName': widget.aircraft.companyName,

          // Additional info
          'amenities': [],
          'images': widget.aircraft.imageUrl != null
              ? [widget.aircraft.imageUrl!]
              : [],
          'specialRequirements': _specialRequestsController.text.trim().isEmpty
              ? null
              : _specialRequestsController.text.trim(),
          'stops': _stops,
        };

        _navigateToPaymentConfirmation(bookingData);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: ${e.toString()}')),
        );
      }
    }
  }

  void _addStop() {
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StopsSelectionScreen(
            onStopsSelected: (selectedStops) {
              setState(() {
                _stops = selectedStops
                    .map((stop) => {
                          'name': stop.name,
                          'latitude': stop.latitude,
                          'longitude': stop.longitude,
                          'price': 0.0, // Default price, can be updated later
                        })
                    .toList();
              });
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Confirm Booking',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Flight Summary
                _buildFlightSummary(),
                const SizedBox(height: 16),

                // Aircraft Details
                _buildAircraftDetails(),
                const SizedBox(height: 16),

                // Pricing Breakdown
                _buildPricingBreakdown(),
                const SizedBox(height: 16),

                // Stops Section
                _buildStopsSection(),
                const SizedBox(height: 16),

                // Special Requests
                _buildSpecialRequests(),
                const SizedBox(height: 16),

                // Terms and Conditions
                _buildTermsAndConditions(),
                const SizedBox(height: 24),

                // Confirm Booking Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const LoadingWidget()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.credit_card),
                            const SizedBox(width: 8),
                            Text(
                              'Confirm Booking',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error in DirectCharterBookingScreen build: $e');
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading booking screen',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildFlightSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flight Summary',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),

        // Origin Display
        _buildLocationDisplay(
          title: 'From',
          location: widget.searchData['origin'],
        ),

        const SizedBox(height: 16),

        // Destination Display
        _buildLocationDisplay(
          title: 'To',
          location: widget.searchData['destination'],
        ),

        const SizedBox(height: 16),

        // Date and passenger info
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Departure',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppUtils.formatDateTime(
                        DateTime.parse(widget.searchData['departureDateTime'])),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.searchData['returnDateTime'] != null) ...[
              const Icon(Icons.arrow_forward, color: Colors.grey),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Return',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.searchData['returnDateTime'] != null
                          ? AppUtils.formatDateTime(DateTime.parse(
                              widget.searchData['returnDateTime']))
                          : 'N/A',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 8),
        Text(
          'Passengers: ${widget.searchData['passengerCount']}',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDisplay({
    required String title,
    required String location,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
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
                  location,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile({
    required String title,
    required LocationModel? location,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
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

  Widget _buildAircraftDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aircraft Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.aircraft.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.aircraft.imageUrl!,
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            const Icon(LucideIcons.plane, color: Colors.grey),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.plane, color: Colors.grey),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.aircraft.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.aircraft.model,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.aircraft.capacity} seats • ${widget.aircraft.companyName}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  Widget _buildPricingBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing Breakdown',
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
                'Price per hour:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '\$${widget.aircraft.pricePerHour.toStringAsFixed(2)}',
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
                'Flight duration:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${widget.aircraft.flightDurationHours.toStringAsFixed(1)}h',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          if (widget.aircraft.repositioningCost > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Repositioning cost:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '\$${widget.aircraft.repositioningCost.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price:',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                '\$${widget.aircraft.totalPrice.toStringAsFixed(2)}',
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
    );
  }

  Widget _buildStopsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stops',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          if (_stops.isEmpty)
            Text(
              'No stops added yet.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stops.length,
              itemBuilder: (context, index) {
                final stop = _stops[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop['name'] ?? 'Stop ${index + 1}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${stop['latitude']?.toStringAsFixed(4) ?? 'N/A'}, ${stop['longitude']?.toStringAsFixed(4) ?? 'N/A'}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (stop['price'] != null && stop['price'] > 0)
                        Text(
                          '\$${stop['price'].toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _addStop,
            icon: const Icon(Icons.add_location, size: 18),
            label: const Text('Select Stops'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRequests() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Requests (Optional)',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _specialRequestsController,
            maxLines: 3,
            style: GoogleFonts.inter(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Any special requests or requirements...',
              hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() => _agreeToTerms = value ?? false);
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _agreeToTerms = !_agreeToTerms);
              },
              child: Text(
                'I agree to the terms and conditions and privacy policy',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[800]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
