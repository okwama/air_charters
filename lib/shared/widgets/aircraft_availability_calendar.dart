import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme/app_theme.dart';
import '../../core/services/aircraft_availability_service.dart';

class AircraftAvailabilityCalendar extends StatefulWidget {
  final int aircraftId;
  final String authToken;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final DateTime? initialDate;

  const AircraftAvailabilityCalendar({
    super.key,
    required this.aircraftId,
    required this.authToken,
    this.selectedDate,
    required this.onDateSelected,
    this.initialDate,
  });

  @override
  State<AircraftAvailabilityCalendar> createState() =>
      _AircraftAvailabilityCalendarState();
}

class _AircraftAvailabilityCalendarState
    extends State<AircraftAvailabilityCalendar> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  final AircraftAvailabilityService _availabilityService =
      AircraftAvailabilityService();
  Map<DateTime, bool> _availabilityMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _loadAvailabilityData();
  }

  Future<void> _loadAvailabilityData() async {
    setState(() => _isLoading = true);

    try {
      // Load availability for current month and next month
      final startDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final endDate = DateTime(_currentMonth.year, _currentMonth.month + 2, 0);

      final availability = await _availabilityService.getAvailabilityStatus(
        aircraftId: widget.aircraftId,
        startDate: startDate,
        endDate: endDate,
        authToken: widget.authToken,
      );

      setState(() {
        _availabilityMap = availability;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // If loading fails, assume all dates are available
      _availabilityMap = {};
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadAvailabilityData();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadAvailabilityData();
  }

  bool _isDateAvailable(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _availabilityMap[dateKey] ??
        true; // Default to available if not in map
  }

  bool _isDateSelected(DateTime date) {
    return _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;
  }

  bool _isDateToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  Color _getDateColor(DateTime date) {
    if (_isDateSelected(date)) {
      return AppTheme.primaryColor;
    } else if (!_isDateAvailable(date)) {
      return Colors.red[100]!;
    } else if (_isDateToday(date)) {
      return Colors.blue[100]!;
    } else {
      return Colors.transparent;
    }
  }

  Color _getDateTextColor(DateTime date) {
    if (_isDateSelected(date)) {
      return Colors.white;
    } else if (!_isDateAvailable(date)) {
      return Colors.red[600]!;
    } else if (_isDateToday(date)) {
      return Colors.blue[600]!;
    } else {
      return Colors.black;
    }
  }

  Widget _buildDateCell(DateTime date) {
    final isAvailable = _isDateAvailable(date);
    final isSelected = _isDateSelected(date);
    final isToday = _isDateToday(date);

    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                _selectedDate = date;
              });
              widget.onDateSelected(date);
            }
          : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getDateColor(date),
          borderRadius: BorderRadius.circular(20),
          border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${date.day}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: _getDateTextColor(date),
                ),
              ),
            ),
            if (!isAvailable)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.block,
                  size: 12,
                  color: Colors.red[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 1; i < firstDayWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      dayWidgets.add(_buildDateCell(date));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.black,
                ),
              ),
              Text(
                '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Text(
                      day,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )
          else
            _buildCalendarGrid(),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                color: Colors.blue[100]!,
                textColor: Colors.blue[600]!,
                label: 'Today',
              ),
              _buildLegendItem(
                color: AppTheme.primaryColor,
                textColor: Colors.white,
                label: 'Selected',
              ),
              _buildLegendItem(
                color: Colors.red[100]!,
                textColor: Colors.red[600]!,
                label: 'Booked',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required Color textColor,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
