import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widgets/notification_tile.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotificationBloc>().add(
                const NotificationMarkAllAsReadRequested(),
              );
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading ||
              state.status == NotificationStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NotificationStatus.error) {
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
              final isRead = notification.isReadBy(state.studentId);
              return NotificationTile(
                notification: notification,
                isRead: isRead,
                onTap: () {
                  if (!isRead) {
                    context.read<NotificationBloc>().add(
                      NotificationMarkAsReadRequested(notification.id),
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
