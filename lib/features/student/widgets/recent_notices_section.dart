import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/models/notice_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/repository/teacher_notice_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/services/teacher_notice_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/blocs/bloc/notices_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/blocs/bloc/notices_event.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/blocs/bloc/notices_state.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/screens/notice_detail_screen.dart';
import '../blocs/notices/screens/notices_screen.dart';

/// Dashboard preview of the same `notices` collection the full Notices
/// screen shows — reuses NoticeBloc so there's no separate data path.
/// Shows at most the first 2 notices as returned by the repository stream.
class RecentNoticesSection extends StatelessWidget {
  const RecentNoticesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          NoticeBloc(TeacherNoticeRepository(TeacherNoticeService()))
            ..add(LoadNoticesEvent()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Notices",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NoticesScreen()),
                ),
                child: const Text("VIEW ALL"),
              ),
            ],
          ),
          const SizedBox(height: 6),
          BlocBuilder<NoticeBloc, NoticeState>(
            builder: (context, state) {
              if (state is NoticeLoading || state is NoticeInitial) {
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

              if (state is NoticeError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                );
              }

              if (state is NoticesLoaded) {
                if (state.notices.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "No notices yet",
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }

                final preview = state.notices.take(2).toList();

                return Column(
                  children: [
                    for (final notice in preview) ...[
                      _RecentNoticeTile(notice: notice),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}

class _RecentNoticeTile extends StatelessWidget {
  final TeacherNoticeModel notice;

  const _RecentNoticeTile({required this.notice});

  String get _relativeTime {
    final diff = DateTime.now().difference(notice.createdAt);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays == 1) return "Yesterday";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return "${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = notice.isPinned ? Colors.red : AppTheme.secondary;
    final icon = notice.isPinned ? Icons.push_pin : Icons.campaign;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NoticeDetailScreen(notice: notice)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEFF9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.15),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${notice.teacherName} • $_relativeTime",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
