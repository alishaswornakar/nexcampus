import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'quick_tile.dart';
import '../screens/alerts_screen.dart';
import '../screens/attendance_screen.dart';
import '../../../features/student/blocs/digital_queue/screens/digital_queue_home_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/syllabus_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/fees_screen.dart';
import '../screens/notices_screen.dart';
import '../screens/issue_reporting_screen.dart';
import 'package:nexcampus_app/features/student/blocs/team_finder/screens/team_finder_screen.dart';
import '../screens/library_screen.dart';
import '../screens/tasks_screen.dart';

/// Plain data holder for the logged-in student's profile, read once from
/// Firestore (`users/{uid}`) and reused across every Quick Access tile
/// that needs it (Digital Queue, Team Finder, Tasks, etc).
class _StudentProfile {
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String rollNumber;
  final String department;
  final String semester;

  const _StudentProfile({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
  });

  factory _StudentProfile.fromFirestore(
    String studentId,
    Map<String, dynamic>? data,
    User authUser,
  ) {
    final map = data ?? const {};
    return _StudentProfile(
      studentId: studentId,
      studentName: (map['fullName'] as String?)?.trim().isNotEmpty == true
          ? map['fullName'] as String
          : (authUser.displayName ?? 'Student'),
      studentEmail: (map['email'] as String?) ?? authUser.email ?? '',
      rollNumber:
          (map['rollNumber'] as String?) ?? (map['roll'] as String?) ?? '',
      department: (map['department'] as String?) ?? '',
      semester: (map['semester'] as String?) ?? '',
    );
  }
}

class QuickAccessGrid extends StatefulWidget {
  final String studentId;

  const QuickAccessGrid({required this.studentId, super.key});

  @override
  State<QuickAccessGrid> createState() => _QuickAccessGridState();
}

class _QuickAccessGridState extends State<QuickAccessGrid> {
  late final Future<_StudentProfile> _profileFuture = _loadProfile();

  Future<_StudentProfile> _loadProfile() async {
    final authUser = FirebaseAuth.instance.currentUser!;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(authUser.uid)
        .get();
    return _StudentProfile.fromFirestore(authUser.uid, snap.data(), authUser);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StudentProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Could not load your profile: ${snapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          );
        }

        final profile = snapshot.data!;
        final currentStudent = CurrentStudent(
          studentId: profile.studentId,
          studentName: profile.studentName,
          studentEmail: profile.studentEmail,
          rollNumber: profile.rollNumber,
          department: profile.department,
          semester: profile.semester,
        );

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
                      builder: (context) =>
                          AttendanceScreen(studentId: profile.studentId),
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
                        department: profile.department,
                        semester: profile.semester,
                        studentId: profile.studentId,
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
                      builder: (context) =>
                          DigitalQueueHomeScreen(student: currentStudent),
                    ),
                  ),
                ),
                QuickTile(
                  icon: Icons.notifications,
                  label: "Alerts",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlertsScreen(),
                    ),
                  ),
                ),
                QuickTile(
                  icon: Icons.menu_book,
                  label: "Notes",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotesScreen(),
                    ),
                  ),
                ),
                QuickTile(
                  icon: Icons.book,
                  label: "Syllabus",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SyllabusScreen(),
                    ),
                  ),
                ),
                QuickTile(
                  icon: Icons.schedule,
                  label: "Schedule",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScheduleScreen(),
                    ),
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
                    MaterialPageRoute(
                      builder: (context) => const NoticesScreen(),
                    ),
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
                    MaterialPageRoute(
                      builder: (context) => const LibraryScreen(),
                    ),
                  ),
                ),
                QuickTile(
                  icon: Icons.group,
                  label: "Team",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamFinderScreen(
                        studentId: profile.studentId,
                        studentName: profile.studentName,
                        studentEmail: profile.studentEmail,
                        rollNumber: profile.rollNumber,
                        department: profile.department,
                        semester: profile.semester,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
