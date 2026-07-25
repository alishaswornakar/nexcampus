import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/student_app_bar.dart';
//import '../widgets/student_profile_card.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/announcements_section.dart';
import 'package:nexcampus_app/features/student/widgets/bottom_nav_bar.dart';
import '../widgets/schedule_card.dart';

class StudentDashboardScreen extends StatelessWidget {
  final User user;

  const StudentDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF6F8FB),

      appBar: StudentAppBar(),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // StudentProfileCard(user: user),
            SizedBox(height: 20),

            QuickAccessGrid(studentId: ''),

            SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Today's Schedule",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            SizedBox(height: 20),

            AnnouncementsSection(),
          ],
        ),
      ),

      bottomNavigationBar: AppBottomNavBar(currentIndex: 0),
    );
  }
}
