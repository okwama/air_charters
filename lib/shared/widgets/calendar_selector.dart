import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarSelector extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onDateSelected;
  final String title;
  final bool allowRangeSelection;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime, DateTime?)? onRangeSelected;
  final List<DateTime>? availableDates;

  const CalendarSelector({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.onDateSelected,
    this.title = 'Select Date',
    this.allowRangeSelection = false,
    this.initialStartDate,
    this.initialEndDate,
    this.onRangeSelected,
    this.availableDates,
  });

  @override
  State<CalendarSelector> createState() => _CalendarSelectorState();
}

class _CalendarSelectorState extends State<CalendarSelector> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.initialDate;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF666666),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable calendar content
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Calendar
                  _buildCalendar(),

                  // Action buttons
                  _buildActionButtons(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF666666),
                  size: 28,
                ),
              ),
              Text(
                _getMonthYearString(_currentMonth),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month + 1,
                    );
                  });
                },
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF666666),
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 12),

          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Empty cells for days before the first day of the month
    for (int i = 0; i < firstDayWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      dayWidgets.add(_buildDayWidget(date));
    }

    // Create rows of 7 days each
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayWidgets.sublist(
            i,
            i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
          ),
        ),
      );
      if (i + 7 < dayWidgets.length) {
        rows.add(const SizedBox(height: 8));
      }
    }

    return Column(children: rows);
  }

  Widget _buildDayWidget(DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = widget.allowRangeSelection
        ? _isDateInRange(date)
        : _isSameDay(date, _selectedDate);
    final isDisabled = _isDateDisabled(date);
    final isStartDate =
        widget.allowRangeSelection && _isSameDay(date, _startDate);
    final isEndDate = widget.allowRangeSelection && _isSameDay(date, _endDate);
    final hasAvailableSchedules =
        widget.availableDates?.any((d) => _isSameDay(d, date)) ?? false;

    Color backgroundColor = Colors.transparent;
    Color textColor = Colors.black;
    Color borderColor = Colors.transparent;

    if (isDisabled) {
      textColor = const Color(0xFFCCCCCC);
    } else if (isSelected) {
      if (widget.allowRangeSelection) {
        if (isStartDate || isEndDate) {
          backgroundColor = Colors.black;
          textColor = Colors.white;
        } else {
          backgroundColor = const Color(0xFFF0F0F0);
          textColor = Colors.black;
        }
      } else {
        backgroundColor = Colors.black;
        textColor = Colors.white;
      }
    } else if (isToday) {
      borderColor = Colors.black;
      textColor = Colors.black;
    } else if (hasAvailableSchedules) {
      // Show available dates with a subtle indicator
      backgroundColor = const Color(0xFFE8F5E8);
      borderColor = const Color(0xFF4CAF50);
      textColor = const Color(0xFF2E7D32);
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => _onDateTap(date),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Clear button
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                  _startDate = null;
                  _endDate = null;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Clear',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF666666),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Apply button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canApply() ? _onApply : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Apply',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (widget.allowRangeSelection) {
        if (_startDate == null || (_startDate != null && _endDate != null)) {
          // Start new selection
          _startDate = date;
          _endDate = null;
        } else if (_startDate != null && _endDate == null) {
          // Complete the range
          if (date.isBefore(_startDate!)) {
            _endDate = _startDate;
            _startDate = date;
          } else {
            _endDate = date;
          }
        }
      } else {
        _selectedDate = date;
      }
    });
  }

  bool _canApply() {
    if (widget.allowRangeSelection) {
      return _startDate != null;
    } else {
      return _selectedDate != null;
    }
  }

  void _onApply() {
    if (widget.allowRangeSelection) {
      if (_startDate != null && widget.onRangeSelected != null) {
        widget.onRangeSelected!(_startDate!, _endDate);
      }
    } else {
      if (_selectedDate != null) {
        widget.onDateSelected(_selectedDate!);
      }
    }
    Navigator.pop(context);
  }

  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null) return false;
    if (_endDate == null) return _isSameDay(date, _startDate);
    return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
        date.isBefore(_endDate!.add(const Duration(days: 1)));
  }

  bool _isDateDisabled(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (widget.firstDate != null && date.isBefore(widget.firstDate!)) {
      return true;
    }
    if (widget.lastDate != null && date.isAfter(widget.lastDate!)) {
      return true;
    }

    // Disable past dates by default
    return date.isBefore(today);
  }

  String _getMonthYearString(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }
}

// Helper function to show the calendar
Future<DateTime?> showCalendarSelector({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = 'Select Date',
  List<DateTime>? availableDates,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CalendarSelector(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        title: title,
        onDateSelected: (date) => Navigator.pop(context, date),
        availableDates: availableDates,
      ),
    ),
  );
}

// Helper function for range selection
Future<Map<String, DateTime>?> showCalendarRangeSelector({
  required BuildContext context,
  DateTime? initialStartDate,
  DateTime? initialEndDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = 'Select Date Range',
}) {
  return showModalBottomSheet<Map<String, DateTime>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CalendarSelector(
        allowRangeSelection: true,
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        firstDate: firstDate,
        lastDate: lastDate,
        title: title,
        onDateSelected: (date) {}, // Not used in range mode
        onRangeSelected: (start, end) {
          Navigator.pop(context, {
            'start': start,
            'end': end ?? start,
          });
        },
      ),
    ),
  );
}
