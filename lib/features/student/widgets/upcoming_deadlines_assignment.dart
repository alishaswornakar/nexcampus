import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/student/blocs/assignment/bloc/assignment_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/assignment/bloc/assignment_event.dart';
import 'package:nexcampus_app/features/student/blocs/assignment/bloc/assignment_state.dart';
import 'package:nexcampus_app/features/student/blocs/assignment/models/assignment_model.dart';
import 'package:nexcampus_app/features/student/blocs/assignment/screens/tasks_screen.dart';
import 'package:nexcampus_app/features/student/blocs/assignment/screens/assignment_tasks_detail_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_submission_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_submission_service.dart';

/// Embeddable dashboard "Upcoming Deadlines" section — replaces the old
/// hardcoded _UpcomingDeadlinesSection with real data pulled from
/// AssignmentBloc. Shows the closest 2 pending/overdue assignments.
///
/// No Scaffold, no independent scrolling — plain Column so it stays safe
/// inside the dashboard's existing SingleChildScrollView (same pattern as
/// WeeklyScheduleSection).
///
/// Takes only [studentId]; resolves department/semester itself via one
/// Firestore read on users/{uid}, since LoadAssignments needs those two
/// fields.
class UpcomingDeadlinesAssignment extends StatefulWidget {
  final String studentId;

  const UpcomingDeadlinesAssignment({super.key, required this.studentId});

  @override
  State<UpcomingDeadlinesAssignment> createState() =>
      _UpcomingDeadlinesAssignmentState();
}

class _UpcomingDeadlinesAssignmentState
    extends State<UpcomingDeadlinesAssignment> {
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
              AssignmentBloc(
                AssignmentRepository(AssignmentService()),
                AssignmentSubmissionRepository(AssignmentSubmissionService()),
              )..add(
                LoadAssignments(
                  department: info.department,
                  semester: info.semester,
                  studentId: widget.studentId,
                ),
              ),
          child: _DeadlinesBody(
            department: info.department,
            semester: info.semester,
            studentId: widget.studentId,
          ),
        );
      },
    );
  }
}

class _DeadlinesBody extends StatelessWidget {
  final String department;
  final String semester;
  final String studentId;

  const _DeadlinesBody({
    required this.department,
    required this.semester,
    required this.studentId,
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
              "Upcoming Deadlines",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TasksScreen(
                    department: department,
                    semester: semester,
                    studentId: studentId,
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
        BlocBuilder<AssignmentBloc, AssignmentState>(
          builder: (context, state) {
            if (state is AssignmentLoading || state is AssignmentInitial) {
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

            if (state is AssignmentError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Couldn't load deadlines: ${state.message}",
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              );
            }

            if (state is AssignmentLoaded) {
              // Only pending + overdue count as "upcoming" — submitted/
              // graded work is done, nothing left to act on.
              final upcoming = [
                ...state.pendingAssignments,
                ...state.overdueAssignments,
              ]..sort((a, b) => a.dueDate.compareTo(b.dueDate));

              if (upcoming.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "No upcoming deadlines",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }

              final preview = upcoming.take(2).toList();

              return Column(
                children: [
                  for (final item in preview) ...[
                    _DeadlineCard(item: item, studentId: studentId),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final StudentAssignmentModel item;
  final String studentId;

  const _DeadlineCard({required this.item, required this.studentId});

  ({String text, Color color}) get _badge {
    if (item.isOverdue) {
      return (text: "OVERDUE", color: const Color(0xFFE05263));
    }
    final daysLeft = item.dueDate.difference(DateTime.now()).inDays;
    if (item.isDueToday) {
      return (text: "DUE TODAY", color: const Color(0xFFE05263));
    }
    if (daysLeft <= 1) {
      return (text: "DUE TOMORROW", color: const Color(0xFFE05263));
    }
    if (daysLeft <= 3) {
      return (text: "IN $daysLeft DAYS", color: const Color(0xFFF0A73A));
    }
    return (text: "IN $daysLeft DAYS", color: AppTheme.primary);
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badge;
    final dueDateText = DateFormat('MMM d, hh:mm a').format(item.dueDate);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AssignmentTasksDetailScreen(
            assignment: item,
            studentId: studentId,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badge.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge.text,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badge.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                dueDateText,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeptSemester {
  final String department;
  final String semester;
  const _DeptSemester({required this.department, required this.semester});
}
