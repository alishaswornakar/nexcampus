// lib/features/student/blocs/schedule/screens/student_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:intl/intl.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/student/blocs/schedule/bloc/schedule_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/model/schedule_model.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/repository/schedule_repository.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/services/schedule_service.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/widgets/student_schedule_entry_card.dart';

/// Full-page, read-only counterpart of TeacherScheduleScreen.
///
/// Takes department + semester directly (same as
/// TeacherScheduleScreen's constructor) so it can be pushed straight
/// from a Quick Access tile once the caller already has the student's
/// profile loaded — no internal UserProfileBloc needed here.
class StudentScheduleScreen extends StatelessWidget {
  final String department;
  final String semester;

  const StudentScheduleScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  static const List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleBloc(ScheduleRepository(ScheduleService()))
        ..add(
          LoadStudentSchedulesEvent(department: department, semester: semester),
        ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: const Text('My Schedule'),
        ),
        body: BlocBuilder<ScheduleBloc, ScheduleState>(
          builder: (context, state) {
            if (state is ScheduleLoading || state is ScheduleInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ScheduleError) {
              return Center(
                child: Text(
                  "Couldn't load schedule: ${state.message}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final schedules = state is SchedulesLoaded
                ? state.schedules
                : <ScheduleModel>[];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: _days.map((day) {
                final dayEntries =
                    schedules
                        .where((s) => s.day.toLowerCase() == day.toLowerCase())
                        .toList()
                      ..sort((a, b) => a.startTime.compareTo(b.startTime));

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (dayEntries.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 2, bottom: 4),
                          child: Text(
                            'No classes scheduled',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        )
                      else
                        ...dayEntries.map(
                          (s) => StudentScheduleEntryCard(schedule: s),
                        ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
