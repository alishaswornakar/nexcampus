import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quick_tile.dart';
import '../screens/alerts_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/digital_queue_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/syllabus_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/fees_screen.dart';
import '../screens/notices_screen.dart';
import '../screens/issue_reporting_screen.dart';
import '../screens/team_finder_screen.dart';
import '../screens/library_screen.dart';
import '../screens/tasks_screen.dart';

// import '../models/assignment_model.dart';
class QuickAccessGrid extends StatelessWidget {
  final String studentId;
  const QuickAccessGrid({required this.studentId, super.key});

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
            QuickTile(
              icon: Icons.assignment,
              label: "Tasks",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TasksScreen(
                    department: '',
                    semester: '',
                    studentId: studentId,
                  ),
                ),
              ),
            ),
            QuickTile(
              icon: Icons.queue,
              label: "Digital Queue",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DigitalQueueScreen(),
                ),
              ),
            ),
            QuickTile(
              icon: Icons.notifications,
              label: "Alerts",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertsScreen()),
              ),
            ),
            QuickTile(
              icon: Icons.menu_book,
              label: "Notes",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotesScreen()),
              ),
            ),
            QuickTile(
              icon: Icons.book,
              label: "Syllabus",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SyllabusScreen()),
              ),
            ),
            QuickTile(
              icon: Icons.schedule,
              label: "Schedule",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScheduleScreen()),
              ),
            ),
            QuickTile(
              icon: Icons.payment,
              label: "Fees",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeesScreen()),
              ),
            ),
            QuickTile(
              icon: Icons.campaign,
              label: "Notices",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NoticesScreen()),
              ),
            ),
            QuickTile(
              icon: Icons.support_agent,
              label: "Issue",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IssueReportingScreen(),
                ),
              ),
            ),
            QuickTile(
              icon: Icons.local_library,
              label: "Library",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LibraryScreen()),
              ),
            ),
            QuickTile(
              icon: Icons.group,
              label: "Team",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeamFinderScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
