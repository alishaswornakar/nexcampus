import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/subject_attendance_summary.dart';
import '../widgets/attendance_subject_stats_card.dart';
import '../widgets/attendance_month_calendar.dart';

class AttendanceSubjectDetailScreen extends StatelessWidget {
  final SubjectAttendanceSummary summary;

  const AttendanceSubjectDetailScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          summary.subjectName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          AttendanceSubjectStatsCard(summary: summary),
          AttendanceMonthCalendar(records: summary.records),
        ],
      ),
    );
  }
}
