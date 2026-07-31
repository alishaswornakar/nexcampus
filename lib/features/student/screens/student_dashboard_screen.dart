import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/recent_notices_section.dart';
import 'package:nexcampus_app/features/student/widgets/bottom_nav_bar.dart';
import '../widgets/greeting_card.dart';
import 'package:nexcampus_app/features/student/widgets/weekly_schedule_section.dart';
import '../widgets/upcoming_deadlines_assignment.dart';

class StudentDashboardScreen extends StatelessWidget {
  final User user;

  const StudentDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: AppTheme.primary,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(0.0),
            child: Padding(padding: EdgeInsets.all(16.0)),
          ),
        ),
      ),
      body: Column(
        children: [
          GreetingCard(studentId: user.uid),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const QuickAccessGrid(studentId: ''),
                  const SizedBox(height: 20),
                  UpcomingDeadlinesAssignment(studentId: user.uid),
                  const SizedBox(height: 24),
                  WeeklyScheduleSection(studentId: user.uid),
                  const SizedBox(height: 10),
                  const RecentNoticesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}
