import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/aircraft_availability_model.dart';
import '../../core/models/location_model.dart';
import '../../core/services/booking_business_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/booking_model.dart';
import '../../core/error/network_error_handler.dart';
import '../../shared/widgets/custom_button.dart';

class AircraftSelectionPage extends StatefulWidget {
  final AvailableAircraft aircraft;
  final LocationModel origin;
  final LocationModel destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int passengerCount;
  final bool isRoundTrip;

  const AircraftSelectionPage({
    super.key,
    required this.aircraft,
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.passengerCount,
    this.isRoundTrip = false,
  });

  @override
  State<AircraftSelectionPage> createState() => _AircraftSelectionPageState();
}

class _AircraftSelectionPageState extends State<AircraftSelectionPage> {
  bool _isLoading = false;

  void _proceedToBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create real booking first using BookingBusinessService
      final bookingService =
          Provider.of<BookingBusinessService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (!authProvider.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to continue with booking'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create booking with payment intent
      final result = await bookingService.createBookingWithPaymentIntent(
        dealId: widget.aircraft.aircraftId, // Use aircraft ID as deal ID
        totalPrice: widget.aircraft.totalPrice,
        onboardDining: false, // Default values
        groundTransportation: false,
        billingRegion: 'United States', // Default
        paymentMethod: PaymentMethod.card, // Default for Paystack
      );

      setState(() {
        _isLoading = false;
      });

      if (result.isSuccess && result.booking != null) {
        // Create booking data structure with real booking ID
        final bookingData = {
          // Flight details
          'aircraft': widget.aircraft.aircraftName,
          'departure': widget.origin.name,
          'destination': widget.destination.name,
          'date':
              '${widget.departureDate.day}/${widget.departureDate.month}/${widget.departureDate.year}',

          // Booking details - use real booking data
          'reference': result.booking!.referenceNumber ?? 'N/A',
          'id': result.booking!.id.toString(),
          'status': result.booking!.bookingStatus.name,
          'bookingStatus': result.booking!.bookingStatus.name,
          'paymentStatus': result.booking!.paymentStatus.name,

          // Passenger information
          'passengerCount': widget.passengerCount,
          'passengers': [
            {
              'firstName': 'User',
              'lastName': 'Name',
              'age': 25,
              'nationality': 'Kenyan',
            }
          ],

          // Pricing
          'totalAmount': widget.aircraft.totalPrice,
          'totalPrice': widget.aircraft.totalPrice,
          'basePrice': widget.aircraft.basePrice,
          'repositioningCost': widget.aircraft.repositioningCost ?? 0.0,

          // Flight details
          'departureDate': widget.departureDate.toIso8601String(),
          'returnDate': widget.returnDate?.toIso8601String(),
          'isRoundTrip': widget.isRoundTrip,
          'flightDuration': widget.aircraft.flightDuration,
          'distance': widget.aircraft.distance,

          // Aircraft details
          'aircraftId': widget.aircraft.aircraftId,
          'aircraftType': widget.aircraft.aircraftType,
          'capacity': widget.aircraft.capacity,
          'companyId': widget.aircraft.companyId,
          'companyName': widget.aircraft.companyName,

          // Additional info
          'amenities': widget.aircraft.amenities,
          'images': widget.aircraft.images,
        };

        // Navigate to booking confirmation with real booking data
        Navigator.pushNamed(
          context,
          '/booking-confirmation',
          arguments: bookingData,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: ${result.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      final errorResult = NetworkErrorResult.fromException(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: ${errorResult.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Aircraft Details',
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
            // Aircraft Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
              ),
              child: widget.aircraft.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.aircraft.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue[50]!,
                                  Colors.blue[100]!,
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.flight,
                              size: 80,
                              color: Colors.blue[600],
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue[50]!,
                            Colors.blue[100]!,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.flight,
                        size: 80,
                        color: Colors.blue[600],
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // Aircraft Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.aircraft.aircraftName,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.aircraft.formattedPrice,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.aircraft.aircraftTypeDisplay,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Flight Details
                  _buildDetailRow('Company', widget.aircraft.companyName),
                  _buildDetailRow(
                      'Capacity', '${widget.aircraft.capacity} passengers'),
                  _buildDetailRow('Available Seats',
                      '${widget.aircraft.availableSeats} seats'),
                  _buildDetailRow(
                      'Flight Duration', widget.aircraft.formattedDuration),
                  _buildDetailRow(
                      'Distance', widget.aircraft.formattedDistance),
                  _buildDetailRow(
                      'Departure Time', widget.aircraft.departureTime),
                  _buildDetailRow('Arrival Time', widget.aircraft.arrivalTime),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                    'Flight Route',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.origin.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.grey),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'To',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.destination.name,
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
                  const SizedBox(height: 16),
                  Text(
                    'Date: ${widget.departureDate.day}/${widget.departureDate.month}/${widget.departureDate.year}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (widget.returnDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Return: ${widget.returnDate!.day}/${widget.returnDate!.month}/${widget.returnDate!.year}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Passengers: ${widget.passengerCount}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Amenities Card
            if (widget.aircraft.amenities.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                      'Amenities',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.aircraft.amenities
                          .map((amenity) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  amenity,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Pricing Breakdown
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPricingRow(
                      'Base Price', widget.aircraft.formattedBasePrice),
                  if (widget.aircraft.hasRepositioningCost)
                    _buildPricingRow('Repositioning',
                        widget.aircraft.formattedRepositioningCost),
                  const Divider(),
                  _buildPricingRow(
                    'Total',
                    widget.aircraft.formattedPrice,
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Book This Aircraft',
                onPressed: _isLoading ? null : _proceedToBooking,
                isLoading: _isLoading,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
