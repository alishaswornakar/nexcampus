import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/authentication/services/auth_service.dart';
import 'package:nexcampus_app/features/authentication/services/auth_wrapper.dart';

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


class GreetingCard extends StatelessWidget {
  final String studentId;

  const GreetingCard({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserProfileBloc()
            ..add(
              UserProfileSubscriptionRequested(
                studentId,
              ),
            ),
        ),
        BlocProvider(
          create: (_) => AttendanceBloc(
            repository: AttendanceRepository(),
          )
            ..add(
              ListenAttendance(studentId),
            ),
        ),
        BlocProvider(
          create: (_) => AssignmentBloc(
            AssignmentRepository(
              AssignmentService(),
            ),
            AssignmentSubmissionRepository(
              AssignmentSubmissionService(),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => DigitalQueueBloc(
            repository: DigitalQueueRepositoryImpl(),
          )
            ..add(
              DigitalQueueActiveTokenSubscriptionRequested(
                studentId: studentId,
              ),
            ),
        ),
        BlocProvider(
          create: (_) => NotificationBloc()
            ..add(
              NotificationSubscribeRequested(
                studentId,
              ),
            ),
        ),
      ],
      child: _GreetingCardBody(
        studentId: studentId,
      ),
    );
  }
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().signOut();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AuthWrapper(),
                  ),
                  (_) => false,
                );
              }
            },
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _GreetingCardBody extends StatelessWidget {
  final String studentId;

  const _GreetingCardBody({
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    final double headerHeight = isMobile
        ? 210
        : isTablet
            ? 230
            : 250;

    final double horizontalPadding = isMobile
        ? 16
        : isTablet
            ? 24
            : 40;

    final double avatarRadius = isMobile
        ? 20
        : isTablet
            ? 24
            : 28;

    final double nameSize = isMobile
        ? 20
        : isTablet
            ? 24
            : 28;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: BlocListener<UserProfileBloc, UserProfileState>(
        listenWhen: (previous, current) {
          return current.profile != null &&
              current.profile!.department != null &&
              current.profile!.semester != null &&
              (previous.profile?.department != current.profile?.department ||
                  previous.profile?.semester != current.profile?.semester);
        },
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
          width: double.infinity,
          height: headerHeight,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    0,
                  ),
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
                                  "Namaste,",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  (name == null || name.isEmpty)
                                      ? "Student"
                                      : name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: nameSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      BlocProvider.value(
                        value: context.read<NotificationBloc>(),
                        child: const NotificationBell(),
                      ),
                      SizedBox(width: isMobile ? 10 : 16),
                      BlocBuilder<UserProfileBloc, UserProfileState>(
                        builder: (context, state) {
                          final photoUrl = state.profile?.photoUrl;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UserProfileScreen(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: Colors.white24,
                              backgroundImage:
                                  (photoUrl != null && photoUrl.isNotEmpty)
                                      ? NetworkImage(photoUrl)
                                      : null,
                              child: (photoUrl == null || photoUrl.isEmpty)
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: avatarRadius,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        onPressed: () => showLogoutDialog(context),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: 15,
                  child: const _StatsRow(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                String value = "--";

                if (state is AttendanceLoaded) {
                  final list = state.attendanceList;
                  if (list.isNotEmpty) {
                    final presentCount = list
                        .where(
                          (a) => a.status.toLowerCase() == "present",
                        )
                        .length;
                    // Exact percentage formula calculation as shown in Attendance screen overview card
                    double percentage = (presentCount / list.length) * 100;
                    value = "${percentage.toStringAsFixed(1)}%";
                  } else {
                    value = "0%";
                  }
                }

                return _StatItem(
                  label: "ATTENDANCE",
                  value: value,
                );
              },
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: BlocBuilder<AssignmentBloc, AssignmentState>(
              builder: (context, state) {
                final value = state is AssignmentLoaded
                    ? "${state.pendingCount}"
                    : "--";

                return _StatItem(
                  label: "ASSIGNMENTS",
                  value: value,
                );
              },
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: BlocBuilder<DigitalQueueBloc, DigitalQueueState>(
              builder: (context, state) {
                final value = state.hasActiveToken
                    ? "#${state.activeToken!.queuePosition}"
                    : "--";

                return _StatItem(
                  label: "QUEUE POS.",
                  value: value,
                );
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

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 9 : 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 15 : 18,
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
      height: 25,
      color: AppTheme.border,
    );
  }
}