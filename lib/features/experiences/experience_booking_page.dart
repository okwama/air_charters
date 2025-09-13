import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:air_charters/core/models/experience_booking_model.dart';
import 'package:air_charters/core/services/experience_booking_service.dart';
import 'package:air_charters/core/network/api_client.dart';
import 'package:air_charters/shared/widgets/calendar_selector.dart';
import 'package:air_charters/config/env/app_config.dart';
import 'experience_passenger_form.dart';

class ExperienceBookingPage extends StatefulWidget {
  final int experienceId;
  final String title;
  final String location;
  final String imageUrl;
  final double price;
  final String priceUnit;
  final int durationMinutes;
  final String description;

  const ExperienceBookingPage({
    super.key,
    required this.experienceId,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.priceUnit,
    required this.durationMinutes,
    required this.description,
  });

  @override
  State<ExperienceBookingPage> createState() => _ExperienceBookingPageState();
}

class _ExperienceBookingPageState extends State<ExperienceBookingPage> {
  late ExperienceBookingService _bookingService;
  DateTime? _selectedDate;
  String? _selectedTime;
  int _passengersCount = 1;
  bool _isLoading = false;
  List<Map<String, dynamic>> _availableTimeSlots = [];
  String? _errorMessage;
  final Map<String, List<Map<String, dynamic>>> _dateSchedules =
      {}; // Cache schedules by date

  @override
  void initState() {
    super.initState();
    _bookingService = ExperienceBookingService(ApiClient());

    // Set initial date to tomorrow
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    print(
        '📅 Initial date set to: ${_selectedDate!.toIso8601String().split('T')[0]}');

    _loadAvailableTimeSlots();
    _preloadSchedulesForMonth(_selectedDate!); // Preload current month
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDate == null) return;

    final dateKey = _selectedDate!.toIso8601String().split('T')[0];
    print('🕐 Loading time slots for date: $dateKey');

    // Check if we already have schedules for this date
    if (_dateSchedules.containsKey(dateKey)) {
      print(
          '🕐 Using cached schedules for $dateKey: ${_dateSchedules[dateKey]!.length} slots');
      setState(() {
        _availableTimeSlots = _dateSchedules[dateKey]!;
      });

      // Auto-select first available time slot
      if (_availableTimeSlots.isNotEmpty && _selectedTime == null) {
        _selectedTime = _availableTimeSlots.first['time'];
      }
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('🕐 Fetching time slots from API for date: $dateKey');
      print('🕐 Experience ID: ${widget.experienceId}');
      print(
          '🕐 API Endpoint: ${AppConfig.experienceSchedulesEndpoint}/${widget.experienceId}/schedules?date=$dateKey');

      final timeSlots = await _bookingService.getAvailableTimeSlots(
        widget.experienceId,
        _selectedDate!,
      );

      print('🕐 Received ${timeSlots.length} time slots from API');
      print('🕐 Time slots: $timeSlots');

      // Debug each time slot
      for (int i = 0; i < timeSlots.length; i++) {
        final slot = timeSlots[i];
        print('🕐 Slot $i: ${slot.toString()}');
        print('🕐   - time: ${slot['time']}');
        print('🕐   - startTime: ${slot['startTime']}');
        print('🕐   - endTime: ${slot['endTime']}');
        print('🕐   - available: ${slot['available']}');
        print('🕐   - seatsAvailable: ${slot['seatsAvailable']}');
        print('🕐   - price: ${slot['price']}');
      }

      setState(() {
        _availableTimeSlots = timeSlots;
        _dateSchedules[dateKey] = timeSlots; // Cache the results
        _isLoading = false;
      });

      // Auto-select first available time slot
      if (_availableTimeSlots.isNotEmpty && _selectedTime == null) {
        _selectedTime = _availableTimeSlots.first['time'];
      }
    } catch (e) {
      print('❌ Error loading time slots: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTime = null; // Reset time when date changes
    });
    _loadAvailableTimeSlots();
  }

  void _onTimeSelected(String time) {
    setState(() {
      _selectedTime = time;
    });
  }

  void _onPassengersChanged(int count) {
    setState(() {
      _passengersCount = count;
    });
  }

  double get _totalPrice => widget.price * _passengersCount;

  bool get _canProceed =>
      _selectedDate != null &&
      _selectedTime != null &&
      _passengersCount > 0 &&
      _isValidDate(_selectedDate!) &&
      _isValidTime(_selectedTime!);

  bool _isValidDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return date.isAfter(tomorrow.subtract(const Duration(days: 1)));
  }

  bool _isValidTime(String time) {
    return _availableTimeSlots
        .any((slot) => slot['time'] == time && slot['available'] == true);
  }

  bool _hasAvailableSchedules(DateTime date) {
    final dateKey = date.toIso8601String().split('T')[0];
    final schedules = _dateSchedules[dateKey];
    return schedules != null && schedules.isNotEmpty;
  }

  Future<void> _preloadSchedulesForMonth(DateTime month) async {
    // Preload schedules for the current month to show available dates
    try {
      print('📅 Preloading schedules for month: ${month.year}-${month.month}');
      print('📅 Experience ID: ${widget.experienceId}');
      print(
          '📅 API Endpoint: ${AppConfig.experienceSchedulesEndpoint}/${widget.experienceId}/schedules');

      final response = await _bookingService.getAvailableTimeSlots(
        widget.experienceId,
        month,
      );

      print('📅 Received ${response.length} schedules for preloading');
      print('📅 Raw response: $response');

      // Group by date
      final Map<String, List<Map<String, dynamic>>> monthSchedules = {};
      for (final schedule in response) {
        print('📅 Processing schedule: $schedule');
        final dateStr = schedule['startTime'].toString().split('T')[0];
        print('📅 Extracted date: $dateStr');
        if (!monthSchedules.containsKey(dateStr)) {
          monthSchedules[dateStr] = [];
        }
        monthSchedules[dateStr]!.add(schedule);
      }

      print('📅 Grouped schedules by date: ${monthSchedules.keys.toList()}');
      print('📅 Final month schedules: $monthSchedules');

      setState(() {
        _dateSchedules.addAll(monthSchedules);
      });
    } catch (e) {
      // Silently fail for preloading
      print('❌ Failed to preload schedules: $e');
    }
  }

  String? _getDateValidationError() {
    if (_selectedDate == null) {
      return 'Please select a date';
    }
    if (!_isValidDate(_selectedDate!)) {
      return 'Please select a future date';
    }
    return null;
  }

  String? _getTimeValidationError() {
    if (_selectedTime == null) {
      return 'Please select a time';
    }
    if (!_isValidTime(_selectedTime!)) {
      return 'Selected time is not available';
    }
    return null;
  }

  void _sendInquiry() {
    // Show a dialog or navigate to inquiry form
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Send Experience Inquiry',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'We\'ll help you plan this experience or find similar alternatives. Would you like to send an inquiry?',
          style: GoogleFonts.inter(
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToInquiryForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Send Inquiry',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToInquiryForm() {
    // Navigate to inquiry form or contact page
    // You can implement this based on your app's navigation structure
    Navigator.pushNamed(context, '/contact', arguments: {
      'subject': 'Experience Inquiry: ${widget.title}',
      'experienceId': widget.experienceId,
      'experienceTitle': widget.title,
    });
  }

  void _proceedToPassengerForm() {
    if (!_canProceed) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExperiencePassengerForm(
          booking: ExperienceBookingModel(
            experienceId: widget.experienceId,
            experienceTitle: widget.title,
            location: widget.location,
            imageUrl: widget.imageUrl,
            price: widget.price,
            priceUnit: widget.priceUnit,
            durationMinutes: widget.durationMinutes,
            selectedDate: _selectedDate!,
            selectedTime: _selectedTime!,
            passengersCount: _passengersCount,
            passengers: [],
            status: 'pending',
            createdAt: DateTime.now(),
          ),
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
          'Book Experience',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Experience Summary Card
                  _buildExperienceSummary(),
                  const SizedBox(height: 24),

                  // Date Selection
                  _buildDateSelection(),
                  const SizedBox(height: 24),

                  // Time Selection
                  _buildTimeSelection(),
                  const SizedBox(height: 24),

                  // Passenger Count
                  _buildPassengerCount(),
                  const SizedBox(height: 24),

                  // Price Summary
                  _buildPriceSummary(),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildExperienceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              errorWidget: (context, url, error) => Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade300,
                child: const Icon(Icons.error, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.location,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.durationMinutes} minutes',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    final bool hasNoSchedules = _dateSchedules.isEmpty && !_isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Date',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_getDateValidationError() != null)
              Text(
                _getDateValidationError()!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.red.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (hasNoSchedules)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No scheduled dates available. This experience may be seasonal or temporarily unavailable.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox.shrink(),
        const SizedBox(height: 12),
        CalendarSelector(
          initialDate: _selectedDate,
          onDateSelected: _onDateSelected,
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          availableDates: _dateSchedules.keys.map((dateStr) {
            final parts = dateStr.split('-');
            return DateTime(
                int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Time',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_getTimeValidationError() != null)
              Text(
                _getTimeValidationError()!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.red.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.red.shade700,
              ),
            ),
          )
        else if (_availableTimeSlots.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Experience Not Currently Available',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This experience has passed its scheduled dates and hasn\'t been renewed yet. We\'d be happy to help you plan a similar experience or check for future availability.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sendInquiry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.email_outlined, size: 18),
                    label: Text(
                      'Send Inquiry',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTimeSlots.map((slot) {
              final time = slot['time'] as String;
              final isSelected = _selectedTime == time;
              final isAvailable = slot['available'] == true;
              final seatsAvailable = slot['seatsAvailable'] as int? ?? 0;
              final price = slot['price'] as String? ?? '';

              return GestureDetector(
                onTap: isAvailable ? () => _onTimeSelected(time) : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.black
                        : isAvailable
                            ? Colors.grey.shade100
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isAvailable
                                  ? Colors.black
                                  : Colors.grey.shade500,
                        ),
                      ),
                      if (isAvailable && seatsAvailable > 0)
                        Text(
                          '$seatsAvailable seats',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPassengerCount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Passengers',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _passengersCount > 1
                    ? () => _onPassengersChanged(_passengersCount - 1)
                    : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: _passengersCount > 1 ? Colors.black : Colors.grey,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_passengersCount',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _passengersCount < 10
                    ? () => _onPassengersChanged(_passengersCount + 1)
                    : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: _passengersCount < 10 ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price per person',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '\$${widget.price.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Passengers',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'x $_passengersCount',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${_totalPrice.toStringAsFixed(2)}',
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

  Widget _buildBottomActionBar() {
    // Show different button when no time slots are available
    final bool hasNoTimeSlots =
        _availableTimeSlots.isEmpty && !_isLoading && _errorMessage == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasNoTimeSlots
                ? _sendInquiry
                : (_canProceed ? _proceedToPassengerForm : null),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  hasNoTimeSlots ? Colors.blue.shade600 : Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              hasNoTimeSlots ? 'Send Inquiry' : 'Continue to Passenger Details',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
