import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/attendance_model.dart';

class AttendanceMonthCalendar extends StatefulWidget {
  final List<AttendanceModel> records;

  const AttendanceMonthCalendar({super.key, required this.records});

  @override
  State<AttendanceMonthCalendar> createState() =>
      _AttendanceMonthCalendarState();
}

class _AttendanceMonthCalendarState extends State<AttendanceMonthCalendar> {
  static const Color _present = Color(0xFF16A34A);
  static const Color _absent = Color(0xFFDC2626);
  static const Color _holiday = Color(0xFFB0B4C2);

  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  static const List<String> _weekdayLabels = [
    'SU',
    'MO',
    'TU',
    'WE',
    'TH',
    'FR',
    'SA',
  ];
  static const List<String> _monthNames = [
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
    'December',
  ];

  @override
  void initState() {
    super.initState();
    final latest = widget.records.isNotEmpty
        ? (List<AttendanceModel>.from(
            widget.records,
          )..sort((a, b) => b.date.compareTo(a.date))).first.date
        : DateTime.now();
    _focusedMonth = DateTime(latest.year, latest.month);
  }

  AttendanceModel? _recordForDay(DateTime day) {
    for (final record in widget.records) {
      if (record.date.year == day.year &&
          record.date.month == day.month &&
          record.date.day == day.day) {
        return record;
      }
    }
    return null;
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
      _selectedDay = null;
    });
  }

  void _onDayTap(DateTime day, AttendanceModel? record, bool isHoliday) {
    setState(() => _selectedDay = day);

    final label = record != null
        ? record.status
        : (isHoliday ? 'Holiday' : 'No class recorded');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${day.day}/${day.month}/${day.year} — $label'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // Sunday = 0

    final cells = <Widget>[];
    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final record = _recordForDay(date);
      final isHoliday =
          record?.isHoliday ?? (date.weekday == DateTime.saturday);
      final isSelected =
          _selectedDay != null &&
          _selectedDay!.year == date.year &&
          _selectedDay!.month == date.month &&
          _selectedDay!.day == date.day;

      Color? dotColor;
      if (record != null && !isHoliday) {
        dotColor = record.isPresent ? _present : _absent;
      } else if (isHoliday) {
        dotColor = _holiday;
      }

      cells.add(
        GestureDetector(
          onTap: () => _onDayTap(date, record, isHoliday),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? (record != null && !record.isPresent
                        ? _absent.withValues(alpha: 0.12)
                        : AppTheme.primary.withValues(alpha: 0.12))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? (record != null && !record.isPresent
                              ? _absent
                              : AppTheme.primary)
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                if (dotColor != null)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppTheme.primary,
                ),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.primary,
                ),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          Row(
            children: _weekdayLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: cells,
          ),
          const Divider(height: 24, color: AppTheme.border),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _legendDot(_present, 'Present'),
              _legendDot(_absent, 'Absent'),
              _legendDot(_holiday, 'Holiday'),
            ],
          ),
        ],
      ),
    );
  }
}
