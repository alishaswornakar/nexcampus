import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../../../../student/blocs/notification/widgets/notification_tile.dart';
import '../bloc/teacher_notification_bloc.dart';
import '../bloc/teacher_notification_event.dart';
import '../bloc/teacher_notification_state.dart';
import 'compose_notice_sheet.dart';

class TeacherNotificationScreen extends StatelessWidget {
  const TeacherNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<TeacherNotificationBloc>().add(
                const TeacherNotificationMarkAllAsReadRequested(),
              );
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        onPressed: () => showComposeNoticeSheet(context),
        icon: const Icon(Icons.campaign_outlined, color: Colors.white),
        label: const Text(
          "New Notice",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocBuilder<TeacherNotificationBloc, TeacherNotificationState>(
        builder: (context, state) {
          if (state.status == TeacherNotificationStatus.loading ||
              state.status == TeacherNotificationStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TeacherNotificationStatus.error) {
            return Center(
              child: Text(state.errorMessage ?? 'Something went wrong.'),
            );
          }

          if (state.notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.separated(
            itemCount: state.notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = state.notifications[index];
              final isRead = notification.isReadBy(state.teacherId);
              return NotificationTile(
                notification: notification,
                isRead: isRead,
                onTap: () {
                  if (!isRead) {
                    context.read<TeacherNotificationBloc>().add(
                      TeacherNotificationMarkAsReadRequested(notification.id),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
