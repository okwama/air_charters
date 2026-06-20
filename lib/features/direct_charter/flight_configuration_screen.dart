import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/models/booking_inquiry_model.dart';
import '../../core/services/aircraft_type_service.dart';
import '../../config/theme/app_theme.dart';
import '../../shared/components/skeleton/skeleton_loading.dart';
import '../../shared/components/passengers.dart';
import '../../shared/widgets/enhanced_location_picker.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/passengers_provider.dart';
import '../../core/providers/trips_provider.dart';
import '../../core/services/dynamic_pricing_service.dart';
import '../../core/services/booking_inquiry_service.dart';
import '../../core/services/direct_charter_service.dart';
import '../../core/models/booking_inquiry_model.dart' as inquiry;
import '../../core/models/location_model.dart';
import '../../core/models/passenger_model.dart';
import '../../core/models/booking_stop_model.dart' as booking_stop;
import '../../core/models/user_trip_model.dart';
import '../../core/models/booking_model.dart' as booking_model;
import '../mytrips/trips.dart';
import '../plan/stops_selection_screen.dart';
import '../../shared/widgets/aircraft_info_card.dart';
import '../../shared/widgets/booking_summary_card.dart';
import '../../shared/widgets/loading_spinner.dart';
import '../../shared/widgets/network_error_widget.dart';
import '../../shared/widgets/time_picker_modal.dart';
import '../../shared/widgets/calendar_picker_modal.dart';
import 'direct_charter_inquiry_confirmation.dart';

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
  final bool _onboardDining = false;
  final bool _groundTransportation = false;
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

  // Computed property for form validity
  bool get _isFormValid {
    final passengerCount = int.tryParse(_passengerCountController.text) ?? 0;
    return _originLocation != null &&
        _destinationLocation != null &&
        _departureDate != null &&
        (!_isRoundTrip || _returnDate != null) &&
        passengerCount >= 1 &&
        passengerCount <= widget.aircraft.capacity;
  }

  @override
  void initState() {
    super.initState();
    // Initialize PassengerProvider in local mode (passengers will be sent with booking)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final passengerProvider =
          Provider.of<PassengerProvider>(context, listen: false);
      passengerProvider.initializeForBooking();
    });
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _passengerCountController.dispose();
    _specialRequirementsController.dispose();
    super.dispose();
  }

  /// Show error modal with icon and retry button
  void _showErrorModal(dynamic error) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuickNetworkErrorWidget(
              error: error,
              onRetry: () {
                Navigator.pop(context);
                _submitConfiguration();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectDepartureDate() async {
    // Show custom calendar modal
    final date = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CalendarPickerModal(
        title: 'Departure Date',
        initialDate:
            _departureDate ?? DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      ),
    );

    if (date != null && mounted) {
      // Then show custom time picker modal
      final selectedTime = await showModalBottomSheet<DateTime>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => TimePickerModal(
          title: 'Departure Time',
          initialTime: _departureDate ??
              DateTime(
                date.year,
                date.month,
                date.day,
                9,
                0,
              ),
        ),
      );

      if (selectedTime != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        setState(() {
          _departureDate = dateTime;
          // If return date is before departure date, clear it
          if (_returnDate != null && _returnDate!.isBefore(dateTime)) {
            _returnDate = null;
          }
        });
        _calculateDynamicPrice();
      }
    }
  }

  void _selectReturnDate() async {
    // If no departure date, do nothing (button will be disabled via _isFormValid)
    if (_departureDate == null) {
      return;
    }

    // Show custom calendar modal
    final date = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CalendarPickerModal(
        title: 'Return Date',
        initialDate:
            _returnDate ?? _departureDate!.add(const Duration(days: 1)),
        firstDate: _departureDate!,
        lastDate: DateTime.now().add(const Duration(days: 365)),
      ),
    );

    if (date != null && mounted) {
      // Then show custom time picker modal
      final selectedTime = await showModalBottomSheet<DateTime>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => TimePickerModal(
          title: 'Return Time',
          initialTime: _returnDate ??
              DateTime(
                date.year,
                date.month,
                date.day,
                17,
                0,
              ),
        ),
      );

      if (selectedTime != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        setState(() {
          _returnDate = dateTime;
        });
        _calculateDynamicPrice();
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');

    return '$hour12:$minuteStr $period';
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
    print('Origin: ${_originLocation?.name}');
    print('Destination: ${_destinationLocation?.name}');
    print('Current stops: ${_stops.length}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StopsSelectionScreen(
          origin: _originLocation,
          destination: _destinationLocation,
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
    // Form validation is handled by button disable state (_isFormValid)
    final passengerCount = int.parse(_passengerCountController.text);

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
      setState(() {
        _isLoading = false;
      });
      // Show error modal with icon and retry button
      _showErrorModal(e);
      return; // Exit early to prevent finally block
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      setState(() {
        _isLoading = false;
      });
      // Keep this toast for auth - critical issue
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to continue'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // No validation toasts - form is pre-validated by _isFormValid

    print('Inquiry Details:');
    print('- Aircraft ID: ${widget.aircraft.id}');
    print('- Passenger Count: $passengerCount');
    print('- _passengers count: ${_passengers.length}');
    print('- Origin: ${_originLocation!.name}');
    print('- Destination: ${_destinationLocation!.name}');
    print('- Stops: ${_stops.length} stops');
    print('- Departure Date: ${_departureDate!}');
    print('- Return Date: ${_isRoundTrip ? _returnDate : 'N/A'}');
    print(
        '- Special Requirements: ${_specialRequirementsController.text.isNotEmpty ? _specialRequirementsController.text : 'None'}');
    print('- Onboard Dining: $_onboardDining');
    print('- Ground Transportation: $_groundTransportation');
    print('- Billing Region: $_billingRegion');
    print('=== FLIGHT CONFIG: STOPS DEBUG ===');
    print('_stops.length: ${_stops.length}');
    print('_stops: $_stops');
    print(
        'Passing stops to createInquiry: ${_stops.isNotEmpty ? _stops : null}');

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
      passengers: _passengers
          .map((passenger) => passenger.toCreateJson())
          .toList(), // Include passenger data
    );

    print('=== FRONTEND: INQUIRY RESULT ===');
    print('Success: ${result.success}');
    print('Message: ${result.message}');
    print('Inquiry: ${result.inquiry?.referenceNumber ?? 'null'}');

    if (result.success && result.inquiry != null) {
      // ✨ OPTIMISTIC UPDATE: Add trip to UI immediately (Uber-style)
      try {
        // Extract departure time from departureDateTime
        String? departureTime;
        if (result.inquiry!.departureDateTime != null) {
          final dt = result.inquiry!.departureDateTime!;
          final hh = dt.hour.toString().padLeft(2, '0');
          final mm = dt.minute.toString().padLeft(2, '0');
          departureTime = '$hh:$mm';
        }

        final optimisticTrip = UserTripModel(
          id: 'temp_${result.inquiry!.id}',
          bookingId: result.inquiry!.id.toString(),
          status: UserTripStatus.pending,
          createdAt: DateTime.now(),
          booking: booking_model.BookingModel(
            id: result.inquiry!.id.toString(),
            referenceNumber: result.inquiry!.referenceNumber,
            userId: result.inquiry!.userId,
            dealId: 0,
            companyId: result.inquiry!.companyId,
            totalPrice: result.inquiry!.totalPrice ?? 0,
            bookingStatus: booking_model.BookingStatus.pending,
            paymentStatus: booking_model.PaymentStatus.pending,
            departure: result.inquiry!.originName,
            destination: result.inquiry!.destinationName,
            departureDate: result.inquiry!.departureDateTime,
            departureTime: departureTime,
            aircraftName: widget.aircraft.name, // Use aircraft from widget
            companyName: widget.aircraft.companyName, // Use company from widget
            passengers: [],
            stops: [],
          ),
        );

        context.read<TripsProvider>().addOptimisticTrip(optimisticTrip);
        debugPrint('✨ Optimistic update: Trip added to UI instantly');
      } catch (e) {
        debugPrint('⚠️ Optimistic update failed (non-critical): $e');
      }

      setState(() {
        _isLoading = false;
      });
      _showInquirySuccess(result.inquiry!);
    } else {
      setState(() {
        _isLoading = false;
      });
      // Show error modal instead of toast
      _showErrorModal(Exception(result.message));
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
                          // Navigate back to MainNavigationScreen (with bottom nav)
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          // Switch to Trips tab (index 3) to see the new inquiry
                          try {
                            context
                                .read<NavigationProvider>()
                                .setCurrentIndex(3);
                          } catch (e) {
                            print('Navigation error: $e');
                          }
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
                          style: AppTheme.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600),
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
                              builder: (context) =>
                                  const TripsPage(initialTabIndex: 0),
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
                    passengerCount:
                        int.tryParse(_passengerCountController.text) ?? 1,
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
                    onPressed: _passengers.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context);
                            _createBookingInquiry(_passengers.length);
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
                    onPressed: _passengers.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context);
                            _proceedToPayment();
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
          content: Text('Please log in to continue'),
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
          print(
              'Converting stop $i: ${stop.name} (${stop.latitude}, ${stop.longitude})');
          bookingStops.add(booking_stop.BookingStopModel(
            id: 0, // Will be set by backend
            bookingId: 0, // Will be set by backend
            stopName: stop.name,
            longitude: stop.longitude ?? 0.0,
            latitude: stop.latitude ?? 0.0,
            datetime: _departureDate!
                .add(Duration(hours: i + 1)), // Estimate stop time
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

      // Debug: Check if locations have coordinates BEFORE sending
      print('🔍 DEBUG: Origin Location Details:');
      print('   Name: ${_originLocation?.name}');
      print('   Latitude: ${_originLocation?.latitude}');
      print('   Longitude: ${_originLocation?.longitude}');
      print('🔍 DEBUG: Destination Location Details:');
      print('   Name: ${_destinationLocation?.name}');
      print('   Latitude: ${_destinationLocation?.latitude}');
      print('   Longitude: ${_destinationLocation?.longitude}');

      // Create INQUIRY (not booking with price)
      // Direct Charter requires admin to quote first
      final directCharterService = DirectCharterService();
      final result = await directCharterService.createInquiry(
        aircraftId: widget.aircraft.id,
        origin: _originLocation?.name ?? 'Nairobi',
        destination: _destinationLocation?.name ?? 'Mombasa',
        originLatitude: _originLocation?.latitude,
        originLongitude: _originLocation?.longitude,
        destinationLatitude: _destinationLocation?.latitude,
        destinationLongitude: _destinationLocation?.longitude,
        departureDateTime: _departureDate!,
        returnDateTime: _isRoundTrip ? _returnDate : null,
        passengerCount: int.tryParse(_passengerCountController.text) ?? 1,
        // NO totalPrice - this is an inquiry
        estimatedPrice: estimatedPrice, // For reference only
        pricePerHour: widget.aircraft.pricePerHour,
        repositioningCost: 0.0,
        tripType: _isRoundTrip ? 'roundtrip' : 'oneway',
        specialRequests: _specialRequirementsController.text.trim().isEmpty
            ? null
            : _specialRequirementsController.text.trim(),
        stops: bookingStops.isNotEmpty ? bookingStops : null,
      );

      setState(() {
        _isLoading = false;
      });

      // Navigate to inquiry confirmation (NOT payment)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DirectCharterInquiryConfirmation(
              inquiryData: result.booking,
              estimatedPrice: estimatedPrice,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error modal instead of raw error toast
      _showErrorModal(e);
    }
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
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Collapsible Aircraft Card
              _buildCollapsibleAircraftCard(),
              const SizedBox(height: 8),

              // Compact Trip Type Selector
              _buildCompactTripTypeSelector(),
              const SizedBox(height: 8),

              // Compact Location Picker
              _buildCompactLocationPicker(),
              const SizedBox(height: 8),

              // Compact Date Picker
              _buildCompactDatePicker(),
              const SizedBox(height: 8),

              // Collapsible Stops Section
              _buildCollapsibleStops(),
              const SizedBox(height: 12),

              // Compact Passenger Section
              _buildCompactPassengerSection(),
              const SizedBox(height: 12),

              // Price Summary
              if (_pricingResult != null) _buildPriceSummary(),
              const SizedBox(height: 16),

              // Submit button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSubmitButton(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ===== COMPACT WIDGETS (Uber/Bolt Style) =====

  Widget _buildCollapsibleAircraftCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Icon(LucideIcons.plane, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.aircraft.name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(LucideIcons.users,
                  size: 14, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 4),
              Text('${widget.aircraft.capacity}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              Text('\$${widget.aircraft.pricePerHour}/hr',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor)),
            ],
          ),
          children: [
            AircraftInfoCard(aircraft: widget.aircraft),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTripTypeSelector() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isRoundTrip = false;
                  _returnDate = null;
                });
                _calculateDynamicPrice();
              },
              child: Container(
                decoration: !_isRoundTrip
                    ? BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      )
                    : null,
                alignment: Alignment.center,
                child: Text(
                  'One Way',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        !_isRoundTrip ? FontWeight.w600 : FontWeight.w400,
                    color: !_isRoundTrip
                        ? AppTheme.primaryColor
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isRoundTrip = true;
                });
                _calculateDynamicPrice();
              },
              child: Container(
                decoration: _isRoundTrip
                    ? BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      )
                    : null,
                alignment: Alignment.center,
                child: Text(
                  'Round Trip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        _isRoundTrip ? FontWeight.w600 : FontWeight.w400,
                    color:
                        _isRoundTrip ? AppTheme.primaryColor : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLocationPicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // FROM section
          Expanded(
            child: InkWell(
              onTap: () async {
                final location = await showModalBottomSheet<LocationModel>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: EnhancedLocationPicker(
                      title: 'Select Origin',
                      onLocationSelected: (loc) {
                        Navigator.pop(context, loc);
                      },
                    ),
                  ),
                );
                if (location != null) {
                  setState(() {
                    _originLocation = location;
                    _originController.text = location.name;
                  });
                  _calculateDynamicPrice();
                }
              },
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FROM',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(LucideIcons.circle,
                            size: 12, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _originLocation?.name ?? 'Select origin',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _originLocation != null
                                  ? AppTheme.textPrimaryColor
                                  : AppTheme.textSecondaryColor
                                      .withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Vertical Divider
          Container(
            width: 1,
            height: 50,
            color: AppTheme.borderColor.withValues(alpha: 0.2),
          ),
          // TO section
          Expanded(
            child: InkWell(
              onTap: () async {
                final location = await showModalBottomSheet<LocationModel>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: EnhancedLocationPicker(
                      title: 'Select Destination',
                      onLocationSelected: (loc) {
                        Navigator.pop(context, loc);
                      },
                    ),
                  ),
                );
                if (location != null) {
                  setState(() {
                    _destinationLocation = location;
                    _destinationController.text = location.name;
                  });
                  _calculateDynamicPrice();
                }
              },
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TO',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(LucideIcons.navigation,
                            size: 12, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _destinationLocation?.name ?? 'Select destination',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _destinationLocation != null
                                  ? AppTheme.textPrimaryColor
                                  : AppTheme.textSecondaryColor
                                      .withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDatePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _selectDepartureDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _departureDate != null
                        ? AppTheme.primaryColor.withValues(alpha: 0.3)
                        : AppTheme.borderColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.calendar,
                            size: 14, color: AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        Text('DEPARTURE',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondaryColor,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (_departureDate != null) ...[
                      Text(
                        '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(_departureDate!),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ] else
                      const Text(
                        'Select date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_isRoundTrip) ...[
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _selectReturnDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _returnDate != null
                          ? AppTheme.primaryColor.withValues(alpha: 0.3)
                          : AppTheme.borderColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.calendar,
                              size: 14, color: AppTheme.primaryColor),
                          const SizedBox(width: 6),
                          Text('RETURN',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondaryColor,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _returnDate != null
                            ? '${_returnDate!.day}/${_returnDate!.month}/${_returnDate!.year}'
                            : 'Select date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _returnDate != null
                              ? AppTheme.textPrimaryColor
                              : AppTheme.textSecondaryColor,
                        ),
                      ),
                      if (_returnDate != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(_returnDate!),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapsibleStops() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: Row(
            children: [
              Icon(LucideIcons.mapPin,
                  size: 18, color: AppTheme.secondaryColor),
              const SizedBox(width: 8),
              Text(
                _stops.isEmpty
                    ? '+ Add Stops (Optional)'
                    : '${_stops.length} Stop${_stops.length > 1 ? 's' : ''} Added',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _stops.isEmpty
                      ? AppTheme.textSecondaryColor
                      : AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          children: [
            if (_stops.isNotEmpty)
              ...List.generate(_stops.length, (index) {
                final stop = _stops[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stop.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          setState(() {
                            _stops.removeAt(index);
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showStopsSelection,
                icon: Icon(LucideIcons.plus, size: 16),
                label: Text(_stops.isEmpty ? 'Add Stops' : 'Add More'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactPassengerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PassengerSelector(
        maxPassengers: widget.aircraft.capacity,
        initialCount: int.tryParse(_passengerCountController.text) ?? 1,
        onCountChanged: (count) {
          _passengerCountController.text = count.toString();
        },
        onPassengersChanged: (passengers) {
          _passengers = passengers;
        },
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.08),
            AppTheme.primaryColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(LucideIcons.dollarSign,
                size: 20, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Total',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondaryColor)),
                const SizedBox(height: 2),
                Text(
                  '\$${_pricingResult!.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
                if (_pricingResult!.flightDurationHours > 0)
                  Text(
                    '${_pricingResult!.flightDurationHours.toStringAsFixed(1)} hrs × \$${widget.aircraft.pricePerHour}/hr',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondaryColor.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
        onPressed: (_isLoading || !_isFormValid) ? null : _submitConfiguration,
        style: AppTheme.primaryButtonStyle.copyWith(
          // Ensure button maintains its color when disabled
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return AppTheme.primaryColor.withValues(alpha: 0.4);
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
                    'Send Inquiry',
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
