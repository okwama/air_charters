import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/theme/app_theme.dart';

class CalendarPickerModal extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  const CalendarPickerModal({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.title = 'Select Date',
  });

  @override
  State<CalendarPickerModal> createState() => _CalendarPickerModalState();
}

class _CalendarPickerModalState extends State<CalendarPickerModal> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  // Quick date presets
  final List<Map<String, dynamic>> _quickDates = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);

    // Generate quick dates
    final now = DateTime.now();
    _quickDates.addAll([
      {
        'label': 'Today',
        'date': DateTime(now.year, now.month, now.day),
      },
      {
        'label': 'Tomorrow',
        'date': DateTime(now.year, now.month, now.day + 1),
      },
      {
        'label': 'In 3 days',
        'date': DateTime(now.year, now.month, now.day + 3),
      },
      {
        'label': 'Next week',
        'date': DateTime(now.year, now.month, now.day + 7),
      },
    ]);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  List<DateTime> _getDaysInMonth() {
    final firstDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);

    final days = <DateTime>[];

    // Add empty days for alignment
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
    for (int i = 0; i < firstWeekday; i++) {
      days.add(DateTime(0)); // Placeholder
    }

    // Add actual days
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      days.add(DateTime(_displayedMonth.year, _displayedMonth.month, i));
    }

    return days;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  bool _isDisabled(DateTime date) {
    return date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedDate);
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Calendar
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Month navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _previousMonth,
                        icon: const Icon(LucideIcons.chevronLeft),
                        color: AppTheme.primaryColor,
                      ),
                      Text(
                        '${_getMonthName(_displayedMonth.month)} ${_displayedMonth.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(LucideIcons.chevronRight),
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Weekday headers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map((day) => SizedBox(
                              width: 40,
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondaryColor
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),

                  // Calendar grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _getDaysInMonth().length,
                    itemBuilder: (context, index) {
                      final date = _getDaysInMonth()[index];

                      // Empty placeholder
                      if (date.year == 0) {
                        return const SizedBox();
                      }

                      final isSelected = _isSameDay(date, _selectedDate);
                      final isToday = _isToday(date);
                      final isDisabled = _isDisabled(date);

                      return GestureDetector(
                        onTap: isDisabled ? null : () => _selectDate(date),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : isToday
                                    ? AppTheme.primaryColor
                                        .withValues(alpha: 0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isToday && !isSelected
                                ? Border.all(
                                    color: AppTheme.primaryColor,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isDisabled
                                    ? AppTheme.textSecondaryColor
                                        .withValues(alpha: 0.3)
                                    : isSelected
                                        ? Colors.white
                                        : AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Quick dates
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.5),
              border: Border(
                top: BorderSide(
                  color: AppTheme.borderColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Quick select',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickDates.map((quickDate) {
                    final date = quickDate['date'] as DateTime;
                    final isSelected = _isSameDay(date, _selectedDate);

                    return GestureDetector(
                      onTap: () {
                        _selectDate(date);
                        setState(() {
                          _displayedMonth = DateTime(date.year, date.month);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.borderColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          quickDate['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
