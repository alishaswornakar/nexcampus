// lib/features/student/widgets/greeting_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/authentication/services/auth_service.dart';
import 'package:nexcampus_app/features/authentication/services/auth_wrapper.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/student/blocs/user_profile/bloc/user_profile_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/user_profile/bloc/user_profile_event.dart';
import 'package:nexcampus_app/features/student/blocs/user_profile/bloc/user_profile_state.dart';
import 'package:nexcampus_app/features/student/blocs/user_profile/screens/user_profile_screen.dart';

import 'package:nexcampus_app/features/student/blocs/attendance/bloc/attendance_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/bloc/attendance_event.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/bloc/attendance_state.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/repository/attendance_repository.dart';

import 'package:nexcampus_app/features/student/blocs/assignment/bloc/assignment_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/assignment/bloc/assignment_event.dart';
import 'package:nexcampus_app/features/student/blocs/assignment/bloc/assignment_state.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_submission_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_submission_service.dart';

import 'package:nexcampus_app/features/student/blocs/digital_queue/bloc/digital_queue_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/digital_queue/bloc/digital_queue_event.dart';
import 'package:nexcampus_app/features/student/blocs/digital_queue/bloc/digital_queue_state.dart';
import 'package:nexcampus_app/features/student/blocs/digital_queue/repository/digital_queue_repository.dart';

import 'package:nexcampus_app/features/student/blocs/notification/bloc/notification_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/notification/bloc/notification_event.dart';
import 'package:nexcampus_app/features/student/blocs/notification/widgets/notification_bell.dart';

/// Replaces the old [StudentAppBar] at the top of the student dashboard.
///
/// Owns its own BLoCs (UserProfile / Attendance / Assignment /
/// DigitalQueue / Notification) so it can be dropped into the dashboard
/// with nothing more than a [studentId] — matching the "each screen wires
/// its own BlocProviders" convention already used by AttendanceScreen and
/// TasksScreen.
///
/// [department]/[semester] for the assignment stream are NOT passed in —
/// they're read off the student's own [UserProfileModel] once it loads,
/// since that's the single source of truth for "which class is this
/// student in" (see UserProfileModel.department / .semester).
class GreetingCard extends StatelessWidget {
  final String studentId;

  const GreetingCard({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              UserProfileBloc()
                ..add(UserProfileSubscriptionRequested(studentId)),
        ),
        BlocProvider(
          create: (_) =>
              AttendanceBloc(repository: AttendanceRepository())
                ..add(ListenAttendance(studentId)),
        ),
        BlocProvider(
          create: (_) => AssignmentBloc(
            AssignmentRepository(AssignmentService()),
            AssignmentSubmissionRepository(AssignmentSubmissionService()),
          ),
        ),
        BlocProvider(
          create: (_) =>
              DigitalQueueBloc(repository: DigitalQueueRepositoryImpl())..add(
                DigitalQueueActiveTokenSubscriptionRequested(
                  studentId: studentId,
                ),
              ),
        ),
        BlocProvider(
          create: (_) =>
              NotificationBloc()
                ..add(NotificationSubscribeRequested(studentId)),
        ),
      ],
      child: _GreetingCardBody(studentId: studentId),
    );
  }
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await AuthService().signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthWrapper()),
                (_) => false,
              );
            }
          },
          child: const Text('Logout', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

class _GreetingCardBody extends StatelessWidget {
  final String studentId;

  const _GreetingCardBody({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: BlocListener<UserProfileBloc, UserProfileState>(
        // Assignments need department + semester, which only exist once the
        // profile has loaded. Fire LoadAssignments exactly once, the moment
        // both become available (not on every profile emission).
        listenWhen: (previous, current) =>
            current.profile != null &&
            current.profile!.department != null &&
            current.profile!.semester != null &&
            (previous.profile?.department != current.profile?.department ||
                previous.profile?.semester != current.profile?.semester),
        listener: (context, state) {
          final profile = state.profile!;
          context.read<AssignmentBloc>().add(
            LoadAssignments(
              department: profile.department!,
              semester: profile.semester!,
              studentId: studentId,
            ),
          );
        },
        child: Container(
          color: AppTheme.primary,
          height:
              180, // INCREASE THIS VALUE to move the blue line further down!
          width: double.infinity,
          padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
          // Leaves room for the stats card to overlap the bottom edge
          // without covering whatever comes next in the dashboard's Column.
          margin: const EdgeInsets.only(bottom: 2),
          child: SafeArea(
            bottom: false,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 44),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BlocBuilder<UserProfileBloc, UserProfileState>(
                          builder: (context, state) {
                            final name = state.profile?.fullName;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Namaste,',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ), // this is for the namaste
                                Text(
                                  (name == null || name.isEmpty)
                                      ? 'Student'
                                      : name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ), // this is for the name
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4), // this is for the avatar
                      BlocProvider.value(
                        value: context.read<NotificationBloc>(),
                        child: const NotificationBell(),
                      ),
                      const SizedBox(width: 12), // this is for the bell
                      BlocBuilder<UserProfileBloc, UserProfileState>(
                        builder: (context, state) {
                          final photoUrl = state.profile?.photoUrl;
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UserProfileScreen(),
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white24,
                              backgroundImage:
                                  (photoUrl != null && photoUrl.isNotEmpty)
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: (photoUrl == null || photoUrl.isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                      // NEW — logout, top-right, after the avatar
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 86,
                  left: 16,
                  right: 16,
                  bottom: 4,
                  child: _StatsRow(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await AuthService().signOut();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthWrapper()),
                  (route) => false,
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}

/// The white "Attendance / Assignments / Queue Pos." row that overlaps
/// the bottom edge of the blue card.
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 50,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                String value = '--';
                if (state is AttendanceLoaded) {
                  final list = state.attendanceList;
                  if (list.isNotEmpty) {
                    final present = list
                        .where((a) => a.status.toLowerCase() == 'present')
                        .length;
                    value =
                        '${((present / list.length) * 100).toStringAsFixed(1)}%';
                  } else {
                    value = '0%';
                  }
                }
                return _StatItem(label: 'ATTENDANCE', value: value);
              },
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: BlocBuilder<AssignmentBloc, AssignmentState>(
              builder: (context, state) {
                final value = state is AssignmentLoaded
                    ? '${state.pendingCount}'
                    : '--';
                return _StatItem(label: 'ASSIGNMENTS', value: value);
              },
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: BlocBuilder<DigitalQueueBloc, DigitalQueueState>(
              builder: (context, state) {
                final value = state.hasActiveToken
                    ? '#${state.activeToken!.queuePosition}'
                    : '--';
                return _StatItem(label: 'QUEUE POS.', value: value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4), //this is for the spacing
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      color: AppTheme.border,
    ); //this is for the spacing
  }
}
