import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/models/attendance_model.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/models/subject_attendance_summary.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/bloc/attendance_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/bloc/attendance_event.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/bloc/attendance_state.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/repository/attendance_repository.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/widgets/attendance_overview_header_card.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/widgets/attendance_subject_card.dart';

import 'attendance_subject_detail_screen.dart';

class AttendanceScreen extends StatelessWidget {
  final String studentId;

  const AttendanceScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AttendanceBloc(repository: AttendanceRepository())
            ..add(ListenAttendance(studentId)),
      child: _AttendanceOverviewView(studentId: studentId),
    );
  }
}

class _AttendanceOverviewView extends StatelessWidget {
  final String studentId;

  const _AttendanceOverviewView({required this.studentId});

  Future<void> _refresh(BuildContext context) async {
    context.read<AttendanceBloc>().add(ListenAttendance(studentId));
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => context.read<AttendanceBloc>().add(
                ListenAttendance(studentId),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 72,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No attendance records found.',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<AttendanceModel> fullList) {
    if (fullList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [SizedBox(height: 300, child: _buildEmpty())],
      );
    }

    final summaries = SubjectAttendanceSummary.groupBySubject(fullList);
    final overallPercentage = SubjectAttendanceSummary.overallPercentage(
      fullList,
    );
    final department = fullList.first.department;
    final semester = fullList.first.semester;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        AttendanceOverviewHeaderCard(
          percentage: overallPercentage,
          department: department,
          semester: semester,
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            'COURSE BREAKDOWN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ),
        for (final summary in summaries)
          AttendanceSubjectCard(
            summary: summary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AttendanceSubjectDetailScreen(summary: summary),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AttendanceSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading || state is AttendanceInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AttendanceError) {
            return _buildError(context, state.message);
          }

          List<AttendanceModel> fullList = [];
          if (state is AttendanceLoaded) {
            fullList = state.attendanceList;
          }

          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: _buildContent(context, fullList),
          );
        },
      ),
    );
  }
}
