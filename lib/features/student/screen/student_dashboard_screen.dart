import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexcampus_app/features/authentication/services/auth_service.dart';
import 'package:nexcampus_app/features/authentication/services/auth_wrapper.dart';

class StudentDashboardScreen extends StatelessWidget {
  final User user;

  const StudentDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          "NexCampus",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Image.asset(
              "assets/images/mbman_app_icon.png",
              fit: BoxFit.cover,
              width: 40,
              height: 40,
            ),
          ),
        ),
        actions: [
          const Icon(Icons.notifications_none, color: Colors.white),
          const SizedBox(width: 10),
          const Icon(Icons.mail_outline, color: Colors.white),
          const SizedBox(width: 10),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          await AuthService().signOut();

                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthWrapper(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Cancel"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      // ===== BODY =====
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== PROFILE CARD =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/150?img=3",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user.displayName ?? "No Name",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: 70,
                    width: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE6F0FF),
                    ),
                    child: const Center(
                      child: Text(
                        "88%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== QUICK ACCESS =====
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
              children: const [
                _QuickTile(Icons.calendar_today, "Attendance"),
                _QuickTile(Icons.assignment, "Pending"),
                _QuickTile(Icons.star, "GPA"),
                _QuickTile(Icons.notifications, "Alerts"),
                _QuickTile(Icons.menu_book, "Notes"),
                _QuickTile(Icons.book, "Syllabus"),
                _QuickTile(Icons.schedule, "Schedule"),
                _QuickTile(Icons.payment, "Fees"),
                _QuickTile(Icons.campaign, "Notices"),
                _QuickTile(Icons.support_agent, "Support"),
                _QuickTile(Icons.local_library, "Library"),
                _QuickTile(Icons.group, "Clubs"),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Today's Schedule",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const _ScheduleCard(
              subject: "Data Structures",
              time: "09:00 AM - 10:00 AM",
              teacher: "Prof. Gupta",
              room: "302",
            ),
            const _ScheduleCard(
              subject: "Operating Systems",
              time: "11:00 AM - 12:00 PM",
              teacher: "Dr. Khan",
              room: "304",
            ),
            const _ScheduleCard(
              subject: "Machine Learning",
              time: "02:00 PM - 03:00 PM",
              teacher: "Ms. Verma",
              room: "308",
            ),

            const SizedBox(height: 20),

            const Text(
              "Announcements",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.blue),
                    title: Text("Mid-Semester Exams start from Nov 15th"),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.warning, color: Colors.red),
                    title: Text("Hostel Fees due by Oct 31st"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ===== BOTTOM NAV =====
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Courses"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Results",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ===== QUICK TILE WIDGET =====
class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickTile(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}

// ===== SCHEDULE CARD =====
class _ScheduleCard extends StatelessWidget {
  final String subject;
  final String time;
  final String teacher;
  final String room;

  const _ScheduleCard({
    //super.key,
    required this.subject,
    required this.time,
    required this.teacher,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(time),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [Text(teacher), Text("Rm $room")],
          ),
        ],
      ),
    );
  }
}
