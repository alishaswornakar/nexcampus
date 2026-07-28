import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/authentication/presentation/pages/login_screen.dart';
import 'package:nexcampus_app/features/teachers/screens/widgets/quick_access_grid.dart';
import 'package:nexcampus_app/features/teachers/screens/widgets/bottom_nav_bar.dart';
import 'package:nexcampus_app/features/teachers/screens/widgets/dashboard_header.dart';
import 'package:nexcampus_app/features/teachers/screens/widgets/recent_activity_card.dart';

import 'package:nexcampus_app/features/teachers/shared_screens/department_semester_selection_screen.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notices/screens/notice_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/screens/teacher_profile_screen.dart';



class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() =>
      _TeacherDashboardState();
}

class _TeacherDashboardState
    extends State<TeacherDashboard> {

  int _currentIndex = 0;

  Future<void> _logout() async {

    final shouldLogout =
        await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Logout"),
                content: const Text(
                  "Are you sure you want to logout?",
                ),
                actions: [

                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),

                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, true),
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
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
      (_) => false,
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const TeacherProfileScreen(),
      ),
    );
  }

  void _openNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Notification feature coming soon.",
        ),
      ),
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
            builder: (_) =>
                const DepartmentSemesterSelectionScreen(
              feature: FeatureType.courses,
            ),
          ),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const DepartmentSemesterSelectionScreen(
              feature: FeatureType.schedules,
            ),
          ),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const TeacherProfileScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F7FB),

      body: SafeArea(

        child: SingleChildScrollView(

          child: Column(

            children: [

              DashboardHeader(
                onNotificationTap:
                    _openNotification,
                onProfileTap:
                    _openProfile,
              ),

              Padding(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const SizedBox(height: 25),

                    const Text(
                      "Quick Access",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    QuickAccessGrid(
                      onLogout: _logout,
                    ),

                    const SizedBox(height: 30),
                                        const Text(
                      "Recent Activity",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

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
                      color:  AppTheme.primary,
                      title: "Attendance Updated",
                      subtitle:
                          "Civil Engineering • Semester 2",
                      time: "1 hour ago",
                    ),

                    const RecentActivityCard(
                      icon: Icons.campaign_outlined,
                      color:  AppTheme.primary,
                      title: "Holiday Notice Published",
                      subtitle: "All Departments",
                      time: "Yesterday",
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _currentIndex,
        onTap: _onBottomTap,
      ),
    );
  }
}