import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/recent_notices_section.dart';
import 'package:nexcampus_app/features/student/widgets/bottom_nav_bar.dart';
import '../widgets/schedule_card.dart';
import '../widgets/greeting_card.dart'; // NEW

class StudentDashboardScreen extends StatelessWidget {
  final User user;

  const StudentDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        // Set your custom height here (e.g., 150.0 pixels)
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: AppTheme.secondary,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(80.0),
            child: Padding(
              padding: EdgeInsets.all(
                16.0,
              ), // Set your desired background color here
            ),
          ),
          // appBar removed — GreetingCard replaces it and needs full width,
          // so it moved out of the AppBar slot into the body.
        ),
      ),
      body: Column(
        children: [
          GreetingCard(studentId: user.uid), // NEW

          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  QuickAccessGrid(studentId: ''),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Today's Schedule",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ScheduleCard(
                    subject: "Data Structures",
                    time: "09:00 AM - 10:00 AM",
                    teacher: "Prof. Gupta",
                    room: "302",
                  ),
                  ScheduleCard(
                    subject: "Operating Systems",
                    time: "11:00 AM - 12:00 PM",
                    teacher: "Dr. Khan",
                    room: "304",
                  ),
                  ScheduleCard(
                    subject: "Machine Learning",
                    time: "02:00 PM - 03:00 PM",
                    teacher: "Ms. Verma",
                    room: "308",
                  ),
                  SizedBox(height: 30), //this is for the spacing
                  RecentNoticesSection(),
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
