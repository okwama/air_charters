import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/models/direct_charter_model.dart';
import '../../core/models/aircraft_availability_model.dart';
import '../../core/models/location_model.dart';
import '../plan/inquiry/create_inquiry_screen.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/components/bottom_nav.dart';
import 'direct_charter_booking_screen.dart';

class DirectCharterResultsScreen extends StatelessWidget {
  final List<DirectCharterAircraft> aircraft;
  final Map<String, dynamic> searchData;

  const DirectCharterResultsScreen({
    super.key,
    required this.aircraft,
    required this.searchData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Available Aircraft',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: aircraft.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                _buildSearchSummary(context),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: aircraft.length,
                    itemBuilder: (context, index) {
                      return _buildAircraftCard(context, aircraft[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.plane,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Aircraft Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No aircraft are available for your selected criteria.\nTry adjusting your search parameters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Modify Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSummary(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.search, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Search Results (${aircraft.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From: ${searchData['origin']}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'To: ${searchData['destination']}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Passengers: ${searchData['passengerCount']}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${searchData['tripType'] == 'oneway' ? 'One Way' : 'Round Trip'}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
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

  Widget _buildAircraftCard(
      BuildContext context, DirectCharterAircraft aircraft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aircraft Image
          if (aircraft.imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                aircraft.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        LucideIcons.plane,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.plane,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),

          // Aircraft Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Aircraft Name and Priority
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        aircraft.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (aircraft.priority == 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Same City',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  aircraft.model,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                // Aircraft Specifications
                Row(
                  children: [
                    _buildSpecItem(
                      icon: LucideIcons.users,
                      label: '${aircraft.capacity} seats',
                    ),
                    const SizedBox(width: 16),
                    _buildSpecItem(
                      icon: LucideIcons.mapPin,
                      label: aircraft.baseCity,
                    ),
                    const SizedBox(width: 16),
                    _buildSpecItem(
                      icon: LucideIcons.building,
                      label: aircraft.companyName,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pricing Details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Price per hour:'),
                          Text(
                            '\$${aircraft.pricePerHour.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      if (aircraft.repositioningCost > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Repositioning:'),
                            Text(
                              '\$${aircraft.repositioningCost.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Flight duration:'),
                          Text(
                            '${aircraft.flightDurationHours.toStringAsFixed(1)}h',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Price:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${aircraft.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    if (aircraft.totalPrice > 0) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _navigateToBooking(context, aircraft),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.creditCard),
                              SizedBox(width: 8),
                              Text(
                                'Book This Aircraft',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _createInquiry(context, aircraft),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.messageSquare),
                              SizedBox(width: 8),
                              Text(
                                'Send Inquiry',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _navigateToBooking(
      BuildContext context, DirectCharterAircraft aircraft) {
    if (!context.mounted) return;

    try {
      // Use a more robust navigation approach
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DirectCharterBookingScreen(
                aircraft: aircraft,
                searchData: searchData,
              ),
            ),
          );
        }
      });
    } catch (e) {
      print('Error navigating to booking: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation error: $e')),
        );
      }
    }
  }

  void _createInquiry(BuildContext context, DirectCharterAircraft aircraft) {
    if (!context.mounted) return;

    try {
      // Convert DirectCharterAircraft to AvailableAircraft for inquiry
      final availableAircraft = AvailableAircraft(
        aircraftId: aircraft.id,
        aircraftName: aircraft.name,
        aircraftType: 'jet', // Default to jet type
        capacity: aircraft.capacity,
        basePrice: aircraft.totalPrice,
        totalPrice: aircraft.totalPrice,
        availableSeats: aircraft.capacity,
        departureTime: '10:00',
        arrivalTime: '12:00',
        flightDuration: (aircraft.flightDurationHours * 60).round(),
        distance: 0.0, // Will be calculated
        companyId: 1, // Default company ID
        companyName: aircraft.companyName,
        repositioningCost: aircraft.repositioningCost,
        amenities: [],
        images: aircraft.imageUrl != null ? [aircraft.imageUrl!] : [],
      );

      // Create location models from search data
      final origin = LocationModel(
        id: 1,
        name: searchData['origin'],
        code: '',
        country: '',
        type: LocationType.city,
        latitude: 0.0,
        longitude: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final destination = LocationModel(
        id: 2,
        name: searchData['destination'],
        code: '',
        country: '',
        type: LocationType.city,
        latitude: 0.0,
        longitude: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateInquiryScreen(
              aircraft: availableAircraft,
              origin: origin,
              destination: destination,
              departureDate: DateTime.parse(searchData['departureDateTime']),
              returnDate: searchData['returnDateTime'] != null
                  ? DateTime.parse(searchData['returnDateTime'])
                  : null,
              passengerCount: searchData['passengerCount'],
              isRoundTrip: searchData['tripType'] == 'roundtrip',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error creating inquiry: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
