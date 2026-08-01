import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../widgets/greeting_card.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/recent_notices_section.dart';
import '../widgets/upcoming_deadlines_assignment.dart';
import '../widgets/weekly_schedule_section.dart';

import 'package:nexcampus_app/features/student/widgets/bottom_nav_bar.dart';

class StudentDashboardScreen extends StatelessWidget {
  final User user;

  const StudentDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    final double horizontalPadding =
        isMobile ? 16 : (isTablet ? 20 : 28);

    final double spacing =
        isMobile ? 20 : 28;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: AppTheme.primary,
          elevation: 0,
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            GreetingCard(
              studentId: user.uid,
            ),

            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1000,
                  ),

                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16,
                    ),

                    child: Column(
                      children: [

                        QuickAccessGrid(
                          studentId: user.uid,
                        ),

                        SizedBox(height: spacing),

                        UpcomingDeadlinesAssignment(
                          studentId: user.uid,
                        ),

                        SizedBox(height: spacing),

                        WeeklyScheduleSection(
                          studentId: user.uid,
                        ),

                        SizedBox(height: spacing),

                        const RecentNoticesSection(),

                        SizedBox(height: spacing),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}