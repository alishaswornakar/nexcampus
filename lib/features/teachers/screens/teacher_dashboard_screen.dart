import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/authentication/presentation/pages/login_screen.dart';
import 'package:nexcampus_app/features/teachers/screens/widgets/bottom_nav_bar.dart';
import 'package:nexcampus_app/features/teachers/screens/widgets/dashboard_greeting_card.dart';
import 'package:nexcampus_app/features/teachers/screens/widgets/quick_access_grid.dart';
import 'package:nexcampus_app/features/teachers/screens/widgets/recent_activity_card.dart';

import 'package:nexcampus_app/features/teachers/shared_screens/department_semester_selection_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/blocs/bloc/teacherprofile_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/blocs/bloc/teacherprofile_event.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/blocs/bloc/teacherprofile_state.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/repository/teacher_profile_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/screens/teacher_profile_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/services/teacher_profile_service.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notification/bloc/teacher_notification_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notification/bloc/teacher_notification_event.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notification/widgets/teacher_notification_bell.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _currentIndex = 0;

  Future<void> _logout() async {
    final shouldLogout =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Logout"),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TeacherProfileScreen()),
    );
  }

  void _onBottomTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DepartmentSemesterSelectionScreen(
              feature: FeatureType.courses,
            ),
          ),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DepartmentSemesterSelectionScreen(
              feature: FeatureType.schedules,
            ),
          ),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TeacherProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    final double horizontalPadding = isMobile ? 16 : (isTablet ? 20 : 28);

    final double spacing = isMobile ? 20 : 28;

    final double titleSize = isMobile ? 18 : (isTablet ? 20 : 22);

    final teacherId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              TeacherProfileBloc(
                  TeacherProfileRepository(TeacherProfileService()))
                ..add(const LoadTeacherProfileEvent()),
        ),
        BlocProvider(
          create: (_) => TeacherNotificationBloc()
            ..add(TeacherNotificationSubscribeRequested(teacherId)),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<TeacherProfileBloc, TeacherProfileState>(
            listenWhen: (previous, current) =>
                current is TeacherProfileLoaded,
            listener: (context, state) {
              if (state is TeacherProfileLoaded) {
                context
                    .read<TeacherNotificationBloc>()
                    .setTeacherName(state.profile.fullName);
              }
            },
            child: BlocBuilder<TeacherProfileBloc, TeacherProfileState>(
              builder: (context, state) {
                String? photoUrl;
                String fullName = "Teacher";
                final isLoading = state is TeacherProfileLoading;

                if (state is TeacherProfileLoaded) {
                  photoUrl = state.profile.photoUrl;
                  fullName = state.profile.fullName;
                }

                return Scaffold(
                  backgroundColor: const Color(0xFFF5F7FB),

                  // No separate AppBar — the greeting header below acts as
                  // the merged app bar, same as the student dashboard.
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(0),
                    child: AppBar(
                      backgroundColor: AppTheme.primary,
                      elevation: 0,
                    ),
                  ),

                  body: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        // Merged header: greeting + notification bell +
                        // avatar + logout, matching the student dashboard.
                        DashboardGreetingCard(
                          fullName: fullName,
                          photoUrl: photoUrl,
                          isLoading: isLoading,
                          onTap: _openProfile,
                          onLogout: _logout,
                          notificationBell: const TeacherNotificationBell(),
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Quick Access",
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                QuickAccessGrid(onLogout: _logout),

                                SizedBox(height: spacing),

                                Text(
                                  "Recent Activity",
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                const RecentActivityCard(
                                  icon: Icons.assignment_outlined,
                                  color: Colors.green,
                                  title: "Flutter Assignment Submitted",
                                  subtitle:
                                      "Computer Engineering • Semester 6",
                                  time: "15 min ago",
                                ),

                                const RecentActivityCard(
                                  icon: Icons.fact_check_outlined,
                                  color: AppTheme.primary,
                                  title: "Attendance Updated",
                                  subtitle: "Civil Engineering • Semester 2",
                                  time: "1 hour ago",
                                ),

                                const RecentActivityCard(
                                  icon: Icons.campaign_outlined,
                                  color: AppTheme.primary,
                                  title: "Holiday Notice Published",
                                  subtitle: "All Departments",
                                  time: "Yesterday",
                                ),

                                SizedBox(height: spacing),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  bottomNavigationBar: DashboardBottomNav(
                    currentIndex: _currentIndex,
                    onTap: _onBottomTap,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
