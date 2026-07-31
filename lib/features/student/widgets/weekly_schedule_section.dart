import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/bloc/schedule_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/model/schedule_model.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/repository/schedule_repository.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/services/schedule_service.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/screens/student_schedule_screen.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/widgets/student_schedule_entry_card.dart';

/// Embeddable dashboard "Today's Schedule" preview — shows only today's
/// classes. VIEW ALL pushes the full weekly view (StudentScheduleScreen),
/// which already owns its own Scaffold/AppBar (AppTheme.primary, white
/// back button) so no styling is duplicated here.
///
/// No Scaffold, no independent scrolling — plain Column so it stays safe
/// inside the dashboard's existing SingleChildScrollView.
///
/// Takes only [studentId]; resolves department/semester itself via one
/// Firestore read on users/{uid}, since LoadStudentSchedulesEvent needs
/// those two fields.
class WeeklyScheduleSection extends StatefulWidget {
  final String studentId;

  const WeeklyScheduleSection({super.key, required this.studentId});

  @override
  State<WeeklyScheduleSection> createState() => _WeeklyScheduleSectionState();
}

class _WeeklyScheduleSectionState extends State<WeeklyScheduleSection> {
  late Future<_DeptSemester> _profileFuture;
  final String _today = DateFormat('EEEE').format(DateTime.now());

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
    return FutureBuilder<_DeptSemester>(
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
        if (info == null || info.department.isEmpty || info.semester.isEmpty) {
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
          child: _TodayScheduleBody(
            department: info.department,
            semester: info.semester,
            today: _today,
          ),
        );
      },
    );
  }
}

class _TodayScheduleBody extends StatelessWidget {
  final String department;
  final String semester;
  final String today;

  const _TodayScheduleBody({
    required this.department,
    required this.semester,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Schedule",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentScheduleScreen(
                    department: department,
                    semester: semester,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "VIEW ALL",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        BlocBuilder<ScheduleBloc, ScheduleState>(
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

            final todayEntries =
                schedules
                    .where((s) => s.day.toLowerCase() == today.toLowerCase())
                    .toList()
                  ..sort((a, b) => a.startTime.compareTo(b.startTime));

            if (todayEntries.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "No classes scheduled today",
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              );
            }

            return Column(
              children: todayEntries
                  .map((s) => StudentScheduleEntryCard(schedule: s))
                  .toList(),
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
