import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/services/aircraft_type_service.dart';
import '../../config/theme/app_theme.dart';
import '../../shared/components/skeleton/skeleton_loading.dart';
import '../../shared/components/passengers.dart';
import '../../shared/widgets/enhanced_location_picker.dart';
import '../../shared/utils/currency_utils.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/dynamic_pricing_service.dart';
import '../../core/services/booking_inquiry_service.dart';
import '../../core/services/direct_charter_service.dart';
import '../../core/models/booking_inquiry_model.dart';
import '../../core/models/location_model.dart';
import '../../core/models/passenger_model.dart';
import '../../core/models/booking_stop_model.dart' as booking_stop;
import '../booking/payment/in_app_checkout_screen.dart';
import '../booking/booking_confirmation_page.dart';
import '../mytrips/trips.dart';
import '../../shared/widgets/passenger_form.dart';
import '../plan/stops_selection_screen.dart';
import '../../shared/widgets/aircraft_info_card.dart';
import '../../shared/widgets/trip_type_selector.dart';
import '../../shared/widgets/location_picker_section.dart';
import '../../shared/widgets/date_picker_section.dart';
import '../../shared/widgets/stops_section.dart';
import '../../shared/widgets/booking_summary_card.dart';
import '../../shared/widgets/loading_spinner.dart';

class FlightConfigurationScreen extends StatefulWidget {
  final Aircraft aircraft;

  const FlightConfigurationScreen({
    super.key,
    required this.aircraft,
  });

  @override
  State<FlightConfigurationScreen> createState() =>
      _FlightConfigurationScreenState();
}

class _FlightConfigurationScreenState extends State<FlightConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _passengerCountController = TextEditingController(text: '1');
  final _specialRequirementsController = TextEditingController();

  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _isRoundTrip = false;
  bool _isLoading = false;
  bool _onboardDining = false;
  bool _groundTransportation = false;
  String? _billingRegion;

  // Enhanced location and pricing
  LocationModel? _originLocation;
  LocationModel? _destinationLocation;
  FlightPricingResult? _pricingResult;
  bool _isCalculatingPrice = false;
  final DynamicPricingService _pricingService = DynamicPricingService();
  final BookingInquiryService _inquiryService = BookingInquiryService();
  
  // Passenger data
  List<PassengerModel> _passengers = [];
  
  // Stops data
  List<LocationModel> _stops = [];

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _passengerCountController.dispose();
    _specialRequirementsController.dispose();
    super.dispose();
  }

  void _selectDepartureDate() async {
    // First select date
    final date = await showDatePicker(
      context: context,
      initialDate:
          _departureDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      // Then select time
      final time = await showTimePicker(
        context: context,
        initialTime: _departureDate != null
            ? TimeOfDay.fromDateTime(_departureDate!)
            : const TimeOfDay(hour: 12, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppTheme.primaryColor,
                onPrimary: Colors.white,
                surface: AppTheme.surfaceColor,
                onSurface: AppTheme.textPrimaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          _departureDate = dateTime;
          // If return date is before departure date, clear it
          if (_returnDate != null && _returnDate!.isBefore(dateTime)) {
            _returnDate = null;
          }
        });
      }
    }
  }

  void _selectReturnDate() async {
    if (_departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select departure date first'),
        ),
      );
      return;
    }

    // First select date
    final date = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? _departureDate!.add(const Duration(days: 1)),
      firstDate: _departureDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      // Then select time
      final time = await showTimePicker(
        context: context,
        initialTime: _returnDate != null
            ? TimeOfDay.fromDateTime(_returnDate!)
            : const TimeOfDay(hour: 12, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppTheme.primaryColor,
                onPrimary: Colors.white,
                surface: AppTheme.surfaceColor,
                onSurface: AppTheme.textPrimaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          _returnDate = dateTime;
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
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

    final month = months[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$month $day, $year • $hour:$minute';
  }

  Future<void> _calculateDynamicPrice() async {
    if (_originLocation == null || _destinationLocation == null) {
      return;
    }

    // Check if aircraft supports dynamic pricing
    if (!_pricingService.canCalculateDynamicPrice(
      pricePerHour: widget.aircraft.pricePerHour,
      aircraftSpeed: null, // We don't have speed in the current model
    )) {
      return;
    }

    setState(() {
      _isCalculatingPrice = true;
    });

    try {
      final result = await _pricingService.calculateFlightPrice(
        pricePerHour: widget.aircraft.pricePerHour,
        aircraftSpeed: null, // Use default speed
        origin: _originLocation!,
        destination: _destinationLocation!,
        isRoundTrip: _isRoundTrip,
        stops: null, // TODO: Add stops support
      );

      setState(() {
        _pricingResult =
            result; // This can be null if pricing calculation fails
        _isCalculatingPrice = false;
      });
    } catch (e) {
      setState(() {
        _pricingResult = null; // Set to null to show inquiry option
        _isCalculatingPrice = false;
      });
      // Log error for debugging but don't show to user
      // The pricing will fallback to inquiry mode
    }
  }

  void _showLocationPicker(String field) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedLocationPicker(
          title: field == 'origin' ? 'Select Origin' : 'Select Destination',
          selectedLocation:
              field == 'origin' ? _originLocation : _destinationLocation,
          placeholder: field == 'origin'
              ? 'Where are you departing from?'
              : 'Where are you flying to?',
          onLocationSelected: (location) {
            if (field == 'origin') {
              setState(() {
                _originLocation = location;
                _originController.text = location.name;
              });
            } else {
              setState(() {
                _destinationLocation = location;
                _destinationController.text = location.name;
              });
            }
            _calculateDynamicPrice();
          },
        ),
      ),
    );
  }

  void _showStopsSelection() {
    print('=== FLIGHT CONFIG: OPENING STOPS SELECTION ===');
    print('Current stops: ${_stops.length}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StopsSelectionScreen(
          existingStops: _stops,
          onStopsSelected: (selectedStops) {
            print('=== FLIGHT CONFIG: STOPS SELECTED ===');
            print('Selected stops: ${selectedStops.length}');
            print('Selected stops details: $selectedStops');
            setState(() {
              _stops = selectedStops;
            });
            print('Updated _stops: ${_stops.length}');
            _calculateDynamicPrice();
          },
        ),
      ),
    );
  }

  void _submitConfiguration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select departure date'),
        ),
      );
      return;
    }

    if (_isRoundTrip && _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select return date for round trip'),
        ),
      );
      return;
    }

    // Additional validation for passenger count
    final passengerCount = int.tryParse(_passengerCountController.text);
    if (passengerCount == null || passengerCount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid passenger count'),
        ),
      );
      return;
    }

    if (passengerCount > widget.aircraft.capacity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Passenger count ($passengerCount) cannot exceed aircraft capacity (${widget.aircraft.capacity})',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if we have pricing or need to create inquiry
      if (_pricingResult != null) {
        // We have pricing, proceed with normal booking
        await Future.delayed(const Duration(seconds: 2));
        _showBookingOptions();
      } else {
        // No pricing available, create inquiry
        await _createBookingInquiry(passengerCount);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createBookingInquiry(int passengerCount) async {
    print('=== FRONTEND: CREATING BOOKING INQUIRY ===');
    
    // Set loading state
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authData = authProvider.authData;

    if (authData == null) {
      print('ERROR: User not authenticated');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to create an inquiry'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_originLocation == null || _destinationLocation == null) {
      print('ERROR: Missing origin or destination');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select origin and destination'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    print('Inquiry Details:');
    print('- Aircraft ID: ${widget.aircraft.id}');
    print('- Passenger Count: $passengerCount');
    print('- _passengers count: ${_passengers.length}');
    print('- Origin: ${_originLocation!.name}');
    print('- Destination: ${_destinationLocation!.name}');
    print('- Stops: ${_stops.length} stops');
    print('- Departure Date: ${_departureDate!}');
    print('- Return Date: ${_isRoundTrip ? _returnDate : 'N/A'}');
    print('- Special Requirements: ${_specialRequirementsController.text.isNotEmpty ? _specialRequirementsController.text : 'None'}');
    print('- Onboard Dining: $_onboardDining');
    print('- Ground Transportation: $_groundTransportation');
    print('- Billing Region: $_billingRegion');
    print('=== FLIGHT CONFIG: STOPS DEBUG ===');
    print('_stops.length: ${_stops.length}');
    print('_stops: $_stops');
    print('Passing stops to createInquiry: ${_stops.isNotEmpty ? _stops : null}');

    final result = await _inquiryService.createInquiry(
      aircraftId: widget.aircraft.id,
      requestedSeats: passengerCount,
      origin: _originLocation!,
      destination: _destinationLocation!,
      departureDate: _departureDate!,
      returnDate: _isRoundTrip ? _returnDate : null,
      specialRequirements: _specialRequirementsController.text.isNotEmpty
          ? _specialRequirementsController.text
          : null,
      onboardDining: _onboardDining,
      groundTransportation: _groundTransportation,
      billingRegion: _billingRegion,
      userNotes: 'Custom charter request - pricing calculation unavailable',
      stops: _stops.isNotEmpty ? _stops : null,
      authToken: authData.accessToken,
      passengers: _passengers.map((passenger) => passenger.toCreateJson()).toList(), // Include passenger data
    );

    print('=== FRONTEND: INQUIRY RESULT ===');
    print('Success: ${result.success}');
    print('Message: ${result.message}');
    print('Inquiry: ${result.inquiry?.referenceNumber ?? 'null'}');

    if (result.success && result.inquiry != null) {
      setState(() {
        _isLoading = false;
      });
      _showInquirySuccess(result.inquiry!);
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showInquirySuccess(BookingInquiry inquiry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
          children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 32),

                // Success icon with animation
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.successColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
              LucideIcons.checkCircle,
              color: AppTheme.successColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Inquiry Submitted Successfully!',
                  style: AppTheme.heading2.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Your charter inquiry has been submitted and is being processed.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Reference number card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
          children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.fileText,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
            Text(
                            'Reference Number',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
            Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
                        child: Text(
                          inquiry.referenceNumber,
                          style: AppTheme.heading3.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Timeline info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.successColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.clock,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                              'Response Time',
                              style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryColor,
                                fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                              'We\'ll review and send a custom quote within 24 hours',
                    style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textPrimaryColor,
                                fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info note
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.borderColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        color: AppTheme.textSecondaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can track this inquiry in My Trips → Pending',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondaryColor,
                          ),
              ),
            ),
          ],
        ),
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close modal
                          // Navigate back to home page (clear all previous routes)
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/dashboard', // Home page route
                            (route) => false, // Remove all previous routes
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.borderColor),
                          foregroundColor: AppTheme.textSecondaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close modal
              // Navigate to My Trips, Pending tab
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TripsPage(initialTabIndex: 0),
                ),
              );
            },
                        style: AppTheme.primaryButtonStyle.copyWith(
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.eye,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'View Inquiry',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.plane,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete Your Booking',
                        style: AppTheme.heading3.copyWith(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Review your flight details and choose an option',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Booking summary
            _isLoading
                ? _buildSkeletonBookingSummary()
                : BookingSummaryCard(
                    aircraft: widget.aircraft,
                    originText: _originController.text,
                    destinationText: _destinationController.text,
                    stops: _stops.map((s) => s.name).toList(),
                    passengerCount: int.tryParse(_passengerCountController.text) ?? 1,
                    isRoundTrip: _isRoundTrip,
                    pricingResult: _pricingResult,
                    isCalculatingPrice: _isCalculatingPrice,
                  ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Check if we have passenger data
                      if (_passengers.isNotEmpty) {
                        _createBookingInquiry(_passengers.length);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add passenger details first'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryColor),
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(LucideIcons.messageCircle, size: 18),
                    label: Text(
                      'Send Inquiry',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Check if we have passenger data
                      if (_passengers.isNotEmpty) {
                      _proceedToPayment();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add passenger details first'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    },
                    style: AppTheme.primaryButtonStyle,
                    icon: const Icon(LucideIcons.creditCard, size: 18),
                    label: Text(
                      'Pay Now',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  Widget _buildSkeletonBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.borderColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoading(
            width: 200,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoading(
                      width: 120,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    SkeletonLoading(
                      width: 100,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    SkeletonLoading(
                      width: 80,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    SkeletonLoading(
                      width: 90,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SkeletonLoading(
                    width: 80,
                    height: 10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  SkeletonLoading(
                    width: 60,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }




  void _proceedToPayment() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to continue with payment'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Calculate estimated price
    double estimatedPrice;
    if (_pricingResult != null) {
      estimatedPrice = _pricingResult!.totalPrice;
    } else {
      estimatedPrice = widget.aircraft.pricePerHour *
          widget.aircraft.flightDurationHours *
          (_isRoundTrip ? 2 : 1);
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Convert stops to BookingStopModel objects
      print('=== FLIGHT CONFIG: STOPS CONVERSION ===');
      print('_stops.length: ${_stops.length}');
      print('_stops: $_stops');
      
      List<booking_stop.BookingStopModel> bookingStops = [];
      if (_stops.isNotEmpty) {
        print('Converting ${_stops.length} stops to BookingStopModel objects');
        for (int i = 0; i < _stops.length; i++) {
          final stop = _stops[i];
          print('Converting stop $i: ${stop.name} (${stop.latitude}, ${stop.longitude})');
          bookingStops.add(booking_stop.BookingStopModel(
            id: 0, // Will be set by backend
            bookingId: 0, // Will be set by backend
            stopName: stop.name,
            longitude: stop.longitude ?? 0.0,
            latitude: stop.latitude ?? 0.0,
            datetime: _departureDate!.add(Duration(hours: i + 1)), // Estimate stop time
            stopOrder: i + 1,
            locationType: booking_stop.LocationType.custom,
            locationCode: stop.code,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }
        print('Created ${bookingStops.length} BookingStopModel objects');
      } else {
        print('No stops to convert');
      }

      // Create the actual booking first
      final directCharterService = DirectCharterService();
      final result = await directCharterService.bookDirectCharter(
        aircraftId: widget.aircraft.id,
        origin: _originLocation?.name ?? 'Nairobi',
        destination: _destinationLocation?.name ?? 'Mombasa',
        departureDateTime: _departureDate!,
        returnDateTime: _isRoundTrip ? _returnDate : null,
        passengerCount: int.tryParse(_passengerCountController.text) ?? 1,
        totalPrice: estimatedPrice,
        pricePerHour: widget.aircraft.pricePerHour,
        repositioningCost: 0.0, // Default repositioning cost
        tripType: _isRoundTrip ? 'roundtrip' : 'oneway',
        specialRequests: _specialRequirementsController.text.trim().isEmpty
            ? null
            : _specialRequirementsController.text.trim(),
        stops: bookingStops.isNotEmpty ? bookingStops : null,
      );

      setState(() {
        _isLoading = false;
      });

      // Navigate to payment screen with the actual booking ID
      final paymentResult = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => InAppCheckoutScreen(
            bookingId: result.booking['id'].toString(),
            amount: estimatedPrice,
            currency: 'USD', // Use USD as the pricing currency
            email: authProvider.currentUser?.email ?? '',
            companyId: widget.aircraft.companyId ??
                1, // Use aircraft's company ID or fallback
            preferredPaymentMethod: 'card',
          ),
        ),
      );

      // Handle payment result
      if (paymentResult == true) {
        // Payment successful, navigate to booking confirmation
        _navigateToBookingConfirmation(result.booking, estimatedPrice);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create booking: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _navigateToBookingConfirmation(
      Map<String, dynamic> booking, double totalPrice) {
    // Prepare booking data for confirmation page
    final bookingData = {
      // Flight details
      'aircraft': widget.aircraft.name,
      'departure': _originLocation?.name ?? 'Nairobi',
      'destination': _destinationLocation?.name ?? 'Mombasa',
      'date': _departureDate != null ? _formatDateTime(_departureDate!) : 'TBD',

      // Booking details
      'reference': booking['referenceNumber'],
      'id': booking['id'],
      'status': booking['bookingStatus'],
      'bookingStatus': booking['bookingStatus'],
      'paymentStatus': 'PAID', // Payment was successful

      // Passenger information
      'passengerCount': int.tryParse(_passengerCountController.text) ?? 1,
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
      'totalAmount': totalPrice,
      'totalPrice': totalPrice,
      'basePrice': widget.aircraft.pricePerHour,
      'repositioningCost': 0.0,

      // Flight details
      'departureDate': _departureDate?.toIso8601String(),
      'returnDate': _isRoundTrip ? _returnDate?.toIso8601String() : null,
      'isRoundTrip': _isRoundTrip,
      'flightDuration': widget.aircraft.flightDurationHours,
      'distance': widget.aircraft.flightDurationHours * 500,

      // Aircraft details
      'aircraftId': widget.aircraft.id,
      'aircraftType': widget.aircraft.model,
      'capacity': widget.aircraft.capacity,
      'companyId': widget.aircraft.companyId,
      'companyName': widget.aircraft.companyName,

      // Additional info
      'amenities': [],
      'images':
          widget.aircraft.imageUrl != null ? [widget.aircraft.imageUrl!] : [],
      'specialRequirements': _specialRequirementsController.text.trim().isEmpty
          ? null
          : _specialRequirementsController.text.trim(),
      'stops': [],
    };

    // Navigate to booking confirmation page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmationPage(
          bookingData: bookingData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Configure Flight',
          style: AppTheme.heading3.copyWith(color: AppTheme.textPrimaryColor),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aircraft info card
              AircraftInfoCard(aircraft: widget.aircraft),
              const SizedBox(height: 24),

              // Flight Details Section
              _buildSectionHeader(
                  'Flight Details', 'Configure your flight preferences'),
              const SizedBox(height: 16),

              // Trip type
              TripTypeSelector(
                isRoundTrip: _isRoundTrip,
                onChanged: (value) {
                  setState(() {
                    _isRoundTrip = value;
                    if (!_isRoundTrip) {
                      _returnDate = null;
                    }
                  });
                  _calculateDynamicPrice();
                },
              ),
              const SizedBox(height: 20),

              // Origin and destination
              LocationPickerSection(
                originLocation: _originLocation,
                destinationLocation: _destinationLocation,
                originText: _originController.text,
                destinationText: _destinationController.text,
                onLocationSelected: (location, field) {
                  if (field == 'origin') {
                    setState(() {
                      _originLocation = location;
                      _originController.text = location.name;
                    });
                  } else {
                    setState(() {
                      _destinationLocation = location;
                      _destinationController.text = location.name;
                    });
                  }
                  _calculateDynamicPrice();
                },
              ),
              const SizedBox(height: 20),

              // Dates
              DatePickerSection(
                departureDate: _departureDate,
                returnDate: _returnDate,
                isRoundTrip: _isRoundTrip,
                onDepartureDateTap: _selectDepartureDate,
                onReturnDateTap: _selectReturnDate,
              ),
              const SizedBox(height: 20),

              // Stops
              StopsSection(
                stops: _stops,
                onStopsSelection: _showStopsSelection,
              ),
              const SizedBox(height: 20),

              // Passenger count
              PassengerSelector(
                maxPassengers: widget.aircraft.capacity,
                initialCount: int.tryParse(_passengerCountController.text) ?? 1,
                onCountChanged: (count) {
                  _passengerCountController.text = count.toString();
                },
                onPassengersChanged: (passengers) {
                  // Store the passenger data for booking
                  _passengers = passengers;
                  print('FLIGHT_CONFIG: PassengerSelector updated, count: ${_passengers.length}');
                },
              ),
              const SizedBox(height: 32),

              // Submit button
              _buildSubmitButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.heading3.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }






  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitConfiguration,
        style: AppTheme.primaryButtonStyle.copyWith(
          // Ensure button maintains its color when disabled
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return AppTheme.primaryColor.withValues(alpha: 0.7);
              }
              return AppTheme.primaryColor;
            },
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingSpinner(size: 20, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Processing...',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _pricingResult != null
                        ? LucideIcons.arrowRight
                        : LucideIcons.messageCircle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _pricingResult != null
                        ? 'Continue to Booking'
                        : 'Send Inquiry',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }


  bool _isInternationalFlight() {
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();
    
    // Simple logic to determine if it's an international flight
    // You can enhance this with more sophisticated logic if needed
    if (origin.isEmpty || destination.isEmpty) {
      return false;
    }
    
    // For now, assume any flight between different countries is international
    // You can replace this with your actual logic
    return origin.toLowerCase() != destination.toLowerCase();
  }
}

