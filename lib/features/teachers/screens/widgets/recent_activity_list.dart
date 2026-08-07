import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notices/models/notice_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/repository/teacher_notice_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/services/teacher_notice_service.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/assignments/models/assignment_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/models/assignment_submission_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_submission_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_submission_service.dart';

import 'activity_item.dart';
import 'recent_activity_card.dart';

/// Live, merged "Recent Activity" feed for the teacher dashboard:
/// - Notices the teacher posted
/// - Assignments the teacher created
/// - Student submissions against those assignments
///
/// All three are Firestore streams; they're combined and re-sorted by
/// time on every rebuild via nested StreamBuilders (no extra deps).
class RecentActivityList extends StatelessWidget {
  final String teacherId;
  final int maxItems;

  RecentActivityList({
    super.key,
    required this.teacherId,
    this.maxItems = 5,
  });

  final TeacherNoticeRepository _noticeRepo =
      TeacherNoticeRepository(TeacherNoticeService());
  final AssignmentRepository _assignmentRepo =
      AssignmentRepository(AssignmentService());
  final AssignmentSubmissionRepository _submissionRepo =
      AssignmentSubmissionRepository(AssignmentSubmissionService());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TeacherNoticeModel>>(
      stream: _noticeRepo.getNotices(),
      builder: (context, noticeSnap) {
        return StreamBuilder<List<AssignmentModel>>(
          stream: _assignmentRepo.getTeacherAssignments(teacherId: teacherId),
          builder: (context, assignmentSnap) {
            final assignments = assignmentSnap.data ?? [];
            final assignmentIds = assignments.map((a) => a.id).toList();

            return StreamBuilder<List<AssignmentSubmissionModel>>(
              stream: assignmentIds.isEmpty
                  ? Stream.value(const [])
                  : _submissionRepo.getSubmissionsForAssignments(
                      assignmentIds: assignmentIds,
                    ),
              builder: (context, submissionSnap) {
                final stillLoading =
                    noticeSnap.connectionState == ConnectionState.waiting &&
                        assignmentSnap.connectionState ==
                            ConnectionState.waiting;

                if (stillLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notices = (noticeSnap.data ?? [])
                    .where((n) => n.teacherId == teacherId)
                    .toList();
                final submissions = submissionSnap.data ?? [];

                final items = <ActivityItem>[
                  ...notices.map(
                    (n) => ActivityItem(
                      type: ActivityType.notice,
                      icon: Icons.campaign_outlined,
                      color: AppTheme.primary,
                      title: n.title,
                      subtitle: n.targetAudience == 'All'
                          ? "All Departments"
                          : n.targetAudience,
                      time: n.createdAt,
                    ),
                  ),
                  ...assignments.map(
                    (a) => ActivityItem(
                      type: ActivityType.assignment,
                      icon: Icons.assignment_outlined,
                      color: Colors.orange,
                      title: a.title,
                      subtitle: "${a.department} • Semester ${a.semester}",
                      time: a.createdAt,
                    ),
                  ),
                  ...submissions.map((s) {
                    final matches =
                        assignments.where((a) => a.id == s.assignmentId);
                    final assignmentTitle =
                        matches.isNotEmpty ? matches.first.title : s.title;

                    return ActivityItem(
                      type: ActivityType.submission,
                      icon: Icons.fact_check_outlined,
                      color: Colors.green,
                      title: "${s.studentName} submitted",
                      subtitle: assignmentTitle,
                      time: s.submittedAt,
                    );
                  }),
                ];

                items.sort((a, b) => b.time.compareTo(a.time));
                final recent = items.take(maxItems).toList();

                if (recent.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        "No recent activity yet",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  );
                }

                return Column(
                  children: recent
                      .map(
                        (item) => RecentActivityCard(
                          icon: item.icon,
                          color: item.color,
                          title: item.title,
                          subtitle: item.subtitle,
                          time: item.timeAgo,
                        ),
                      )
                      .toList(),
                );
              },
            );
          },
        );
      },
    );
  }
}
