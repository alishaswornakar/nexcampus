import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/attendance_model.dart';

class AttendanceCalendar extends StatefulWidget {
  final List<AttendanceModel> attendanceList;
  final Function(DateTime)? onDaySelected;

  const AttendanceCalendar({
    super.key,
    required this.attendanceList,
    this.onDaySelected,
  });

  @override
  State<AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Status palette — kept distinct from AppTheme brand colors on purpose,
  // since these need to read instantly as "good/bad".
  static const Color _present = Color(0xFF16A34A);
  static const Color _absent = Color(0xFFDC2626);

  AttendanceModel? _attendanceForDay(DateTime day) {
    for (final attendance in widget.attendanceList) {
      if (attendance.date.year == day.year &&
          attendance.date.month == day.month &&
          attendance.date.day == day.day) {
        return attendance;
      }
    }
    return null;
  }

  Color _statusColor(bool isPresent) => isPresent ? _present : _absent;

  Widget _dayCell(
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
    bool isOutside = false,
  }) {
    final attendance = _attendanceForDay(day);
    final statusColor = attendance != null
        ? _statusColor(attendance.isPresent)
        : null;

    Color background = Colors.transparent;
    Color textColor = isOutside
        ? AppTheme.textSecondary.withValues(alpha: 0.4)
        : AppTheme.textPrimary;
    Border? border;
    FontWeight weight = FontWeight.w500;

    if (isSelected) {
      background = AppTheme.primary;
      textColor = Colors.white;
      weight = FontWeight.w700;
    } else if (isToday) {
      border = Border.all(color: AppTheme.primary, width: 1.6);
      textColor = AppTheme.secondary;
      weight = FontWeight.w700;
    } else if (statusColor != null && !isOutside) {
      background = statusColor.withValues(alpha: 0.12);
      weight = FontWeight.w600;
    }

    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: background,
          border: border,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: weight,
                fontSize: 14,
              ),
            ),
            if (statusColor != null && !isSelected && !isOutside)
              Positioned(
                bottom: 2,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      decoration: BoxDecoration(
        color: AppTheme.background,
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
          const Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: AppTheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Attendance Calendar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2035),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            daysOfWeekHeight: 28,
            rowHeight: 46,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDaySelected?.call(selectedDay);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: AppTheme.primary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.primary,
              ),
              headerPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              weekendStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: true,
              cellMargin: EdgeInsets.zero,
              cellPadding: EdgeInsets.zero,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) => _dayCell(day),
              todayBuilder: (context, day, focusedDay) =>
                  _dayCell(day, isToday: true),
              selectedBuilder: (context, day, focusedDay) =>
                  _dayCell(day, isSelected: true),
              outsideBuilder: (context, day, focusedDay) =>
                  _dayCell(day, isOutside: true),
            ),
          ),
          const Divider(height: 28, color: AppTheme.border),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _legendDot(_present, 'Present'),
              _legendDot(_absent, 'Absent'),
            ],
          ),
        ],
      ),
    );
  }
}
