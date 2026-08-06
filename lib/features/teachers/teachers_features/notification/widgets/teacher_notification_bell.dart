import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/teacher_notification_bloc.dart';
import '../bloc/teacher_notification_state.dart';
import '../screens/teacher_notification_screen.dart';

/// Bell icon that reads unread count from TeacherNotificationBloc and
/// opens TeacherNotificationScreen. Must be built under a
/// TeacherNotificationBloc provider (see TeacherDashboard for the wiring).
class TeacherNotificationBell extends StatelessWidget {
  const TeacherNotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherNotificationBloc, TeacherNotificationState>(
      builder: (context, state) {
        final unread = state.unreadCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<TeacherNotificationBloc>(),
                      child: const TeacherNotificationScreen(),
                    ),
                  ),
                );
              },
            ),
            if (unread > 0)
              Positioned(
                right: 4,
                top: 4,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
