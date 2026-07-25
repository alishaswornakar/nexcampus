import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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

  AttendanceModel? _attendanceForDay(DateTime day) {
    try {
      return widget.attendanceList.firstWhere(
        (attendance) =>
            attendance.date.year == day.year &&
            attendance.date.month == day.month &&
            attendance.date.day == day.day,
      );
    } catch (_) {
      return null;
    }
  }

  Color? _markerColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'leave':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TableCalendar(
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2035),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            widget.onDaySelected?.call(selectedDay);
          },

          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              final attendance = _attendanceForDay(date);

              if (attendance == null) {
                return const SizedBox.shrink();
              }

              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _markerColor(attendance.status),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.indigo,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.deepOrange,
              shape: BoxShape.circle,
            ),
          ),

          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),
        ),
      ),
    );
  }
}
