import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/repository/teacher_notice_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/services/teacher_notice_service.dart';

import '../bloc/notices_bloc.dart';
import '../bloc/notices_event.dart';
import '../bloc/notices_state.dart';
import '../widgets/notice_tile.dart';
import 'notice_detail_screen.dart';

/// Student-facing Notices screen.
///
/// This is the "student" end of the teacher <-> student notices connection:
/// it listens to the same `notices` Firestore collection the teacher
/// `NoticeScreen` publishes to, so any notice a teacher adds/pins/edits
/// shows up here automatically, in real time. There is no floating action
/// button and no edit/delete/pin menu — students only view.
class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoticeBloc(
        TeacherNoticeRepository(
          TeacherNoticeService(),
        ),
      )..add(
          LoadNoticesEvent(),
        ),
      child: Scaffold(
        backgroundColor: AppTheme.background,

        appBar: AppBar(
          title: const Text("Notices"),
          centerTitle: true,
          backgroundColor: AppTheme.secondary,
          foregroundColor: Colors.white,
        ),

        body: BlocBuilder<NoticeBloc, NoticeState>(
          builder: (context, state) {
            if (state is NoticeLoading || state is NoticeInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            if (state is NoticeError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            if (state is NoticesLoaded) {
              if (state.notices.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 80,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(height: 15),
                      Text(
                        "No Notices Found",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () async {
                  context.read<NoticeBloc>().add(LoadNoticesEvent());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.notices.length,
                  itemBuilder: (context, index) {
                    final notice = state.notices[index];

                    return NoticeTile(
                      notice: notice,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoticeDetailScreen(notice: notice),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
