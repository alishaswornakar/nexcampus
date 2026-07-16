import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quick_tile.dart';
//import '../screens/alerts_screen.dart';
import '../screens/attendance_screen.dart';
// import '../screens/digital_queue_screen.dart';
// import '../screens/notes_screen.dart';
// import '../screens/syllabus_screen.dart';
// import '../screens/schedule_screen.dart';
// import '../screens/fees_screen.dart';
// import '../screens/notices_screen.dart';
// import '../screens/issue_reporting_screen.dart';
// import '../screens/team_finder_screen.dart';

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = FirebaseAuth.instance.currentUser!.uid; // add this
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Access",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            QuickTile(
              icon: Icons.calendar_today,
              label: "Attendance",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceScreen(studentId: studentId),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
