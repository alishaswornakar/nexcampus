import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/bloc/schedule_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/model/schedule_model.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/repository/schedule_repository.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/services/schedule_service.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/widgets/student_schedule_entry_card.dart';

/// Embeddable dashboard preview of the student's weekly schedule.
///
/// Unlike [StudentScheduleScreen] (which owns a Scaffold + AppBar and is
/// meant to be pushed as a full route), this widget has NO Scaffold and
/// NO independently-scrolling list — it renders as a plain Column so it
/// can live inside the dashboard's existing SingleChildScrollView without
/// fighting it for layout/scroll ownership.
///
/// Takes only [studentId] (matches how it's called from the dashboard,
/// which no longer provides UserProfileBloc). Resolves department/semester
/// itself via a single Firestore read, since LoadStudentSchedulesEvent
/// needs those two fields, not the uid.
class WeeklyScheduleSection extends StatefulWidget {
  final String studentId;

  const WeeklyScheduleSection({super.key, required this.studentId});

  @override
  State<WeeklyScheduleSection> createState() => _WeeklyScheduleSectionState();
}

class _WeeklyScheduleSectionState extends State<WeeklyScheduleSection> {
  static const List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  late Future<_DeptSemester> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadDeptSemester();
  }

  Future<_DeptSemester> _loadDeptSemester() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.studentId)
        .get();
    final data = snap.data() ?? const {};
    return _DeptSemester(
      department: (data['department'] as String?) ?? '',
      semester: (data['semester'] as String?) ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Schedule",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FutureBuilder<_DeptSemester>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final info = snapshot.data;
            if (info == null ||
                info.department.isEmpty ||
                info.semester.isEmpty) {
              return const SizedBox.shrink();
            }

            return BlocProvider(
              create: (_) =>
                  ScheduleBloc(ScheduleRepository(ScheduleService()))..add(
                    LoadStudentSchedulesEvent(
                      department: info.department,
                      semester: info.semester,
                    ),
                  ),
              child: BlocBuilder<ScheduleBloc, ScheduleState>(
                builder: (context, state) {
                  if (state is ScheduleLoading || state is ScheduleInitial) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  if (state is ScheduleError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Couldn't load schedule: ${state.message}",
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    );
                  }

                  final schedules = state is SchedulesLoaded
                      ? state.schedules
                      : <ScheduleModel>[];

                  if (schedules.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "No classes scheduled this week",
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    );
                  }

                  // Plain, non-scrolling Column — the outer
                  // SingleChildScrollView on the dashboard owns scrolling.
                  return Column(
                    children: _days.map((day) {
                      final dayEntries =
                          schedules
                              .where(
                                (s) => s.day.toLowerCase() == day.toLowerCase(),
                              )
                              .toList()
                            ..sort(
                              (a, b) => a.startTime.compareTo(b.startTime),
                            );

                      if (dayEntries.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
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
            );
          },
        ),
      ],
    );
  }
}

class _DeptSemester {
  final String department;
  final String semester;
  const _DeptSemester({required this.department, required this.semester});
}
