import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';

class TimePickerModal extends StatefulWidget {
  final DateTime? initialTime;
  final String title;

  const TimePickerModal({
    super.key,
    this.initialTime,
    this.title = 'Select Time',
  });

  @override
  State<TimePickerModal> createState() => _TimePickerModalState();
}

class _TimePickerModalState extends State<TimePickerModal> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedPeriod; // 0 = AM, 1 = PM

  // Popular times (24-hour format)
  final List<Map<String, dynamic>> _popularTimes = [
    {'label': '6:00 AM', 'hour': 6, 'minute': 0},
    {'label': '9:00 AM', 'hour': 9, 'minute': 0},
    {'label': '12:00 PM', 'hour': 12, 'minute': 0},
    {'label': '3:00 PM', 'hour': 15, 'minute': 0},
    {'label': '6:00 PM', 'hour': 18, 'minute': 0},
    {'label': '9:00 PM', 'hour': 21, 'minute': 0},
  ];

  @override
  void initState() {
    super.initState();
    final now = widget.initialTime ?? DateTime.now();

    // Convert 24h to 12h format
    int hour24 = now.hour;
    _selectedPeriod = hour24 >= 12 ? 1 : 0;
    _selectedHour = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);
    _selectedMinute = now.minute;
  }

  DateTime _getSelectedDateTime() {
    int hour24 = _selectedHour;
    if (_selectedPeriod == 1 && _selectedHour != 12) {
      hour24 = _selectedHour + 12;
    } else if (_selectedPeriod == 0 && _selectedHour == 12) {
      hour24 = 0;
    }

    final now = widget.initialTime ?? DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      hour24,
      _selectedMinute,
    );
  }

  void _selectPopularTime(int hour24, int minute) {
    setState(() {
      _selectedPeriod = hour24 >= 12 ? 1 : 0;
      _selectedHour = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);
      _selectedMinute = minute;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
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
                    Navigator.pop(context, _getSelectedDateTime());
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

          // Wheel Pickers
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hour picker
                  SizedBox(
                    width: 80,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedHour - 1,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedHour = index + 1;
                        });
                      },
                      children: List.generate(12, (index) {
                        return Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Separator
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Minute picker
                  SizedBox(
                    width: 80,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedMinute ~/ 5,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMinute = index * 5;
                        });
                      },
                      children: List.generate(12, (index) {
                        return Center(
                          child: Text(
                            '${(index * 5).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // AM/PM picker
                  SizedBox(
                    width: 80,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedPeriod,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedPeriod = index;
                        });
                      },
                      children: const [
                        Center(
                          child: Text(
                            'AM',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'PM',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Popular times chips
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
                    'Popular times',
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
                  children: _popularTimes.map((time) {
                    final isSelected = _isTimeSelected(
                      time['hour'] as int,
                      time['minute'] as int,
                    );

                    return GestureDetector(
                      onTap: () {
                        _selectPopularTime(
                          time['hour'] as int,
                          time['minute'] as int,
                        );
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
                          time['label'] as String,
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

  bool _isTimeSelected(int hour24, int minute) {
    int currentHour24 = _selectedHour;
    if (_selectedPeriod == 1 && _selectedHour != 12) {
      currentHour24 = _selectedHour + 12;
    } else if (_selectedPeriod == 0 && _selectedHour == 12) {
      currentHour24 = 0;
    }

    return currentHour24 == hour24 && _selectedMinute == minute;
  }
}
