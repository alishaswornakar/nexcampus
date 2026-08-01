import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/admin/screens/assignment_management_screen.dart';
import 'notice_management_screen.dart';
import 'report_monitoring_screen.dart';
import '../../authentication/presentation/pages/login_screen.dart';
import 'student_management_screen.dart';
import 'teacher_management_screen.dart';
import 'admin_attendance_view_screen.dart';
import 'admin_team_management_screen.dart';
import 'admin_queue_management_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NoticeManagementScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // 📂 Management Menu for Student/Teacher (Add & View)
  void _showManagementMenu(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Manage ${type}s",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1, color: Colors.pink),
                title: Text("Add New $type"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => type == "Student"
                          ? const StudentManagementScreen()
                          : const TeacherManagementScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blue),
                title: Text("View Registered ${type}s"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UserListView(role: type.toLowerCase()),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 📂 Course Files Menu: Admin file option removed, directly opens Teacher's Notes
  void _showCourseFileMenu(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TeacherNotesViewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.primaryColor ?? Colors.blue;

    final List<Map<String, dynamic>> dashboardItems = [
      {
        'title': 'View Attendance',
        'icon': Icons.fact_check_outlined,
        'color': Colors.purple,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminAttendanceViewScreen(),
          ),
        ),
      },
      {
        'title': 'Course Files',
        'icon': Icons.folder_open_outlined,
        'color': Colors.teal,
        'onTap': () => _showCourseFileMenu(context),
      },
      {
        'title': 'Notices',
        'icon': Icons.campaign_outlined,
        'color': Colors.orange,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NoticeManagementScreen(),
          ),
        ),
      },
      {
        'title': 'Student Reports',
        'icon': Icons.report_problem_outlined,
        'color': Colors.deepPurple,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReportMonitoringScreen(),
          ),
        ),
      },
      {
        'title': 'Add New Student',
        'icon': Icons.person_add_alt_1_outlined,
        'color': Colors.pink,
        'onTap': () => _showManagementMenu(context, "Student"),
      },
      {
        'title': 'Add New Teacher',
        'icon': Icons.person_add_outlined,
        'color': Colors.pink,
        'onTap': () => _showManagementMenu(context, "Teacher"),
      },
      {
        'title': 'Assignments',
        'icon': Icons.assignment_outlined,
        'color': Colors.blueAccent,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AssignmentManagementScreen(),
          ),
        ),
      },
      {
        'title': 'Digital Queue',
        'icon': Icons.confirmation_number_outlined,
        'color': Colors.indigo,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminQueueManagementScreen(),
          ),
        ),
      },
      {
        'title': 'Project Teams',
        'icon': Icons.groups_outlined,
        'color': Colors.blue,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminTeamManagementScreen(),
          ),
        ),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E6091), Color(0xFF0077B6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back,",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Administrator 👋",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildServiceCard(dashboardItems[index]),
                  childCount: dashboardItems.length,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            label: 'Notices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: item['onTap'],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: (item['color'] as Color).withValues(alpha: 0.1),
              child: Icon(item['icon'], color: item['color']),
            ),
            const SizedBox(height: 10),
            Text(
              item['title'],
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// 📄 TEACHER LE HALEKO NOTES HERNE SCREEN
class TeacherNotesViewScreen extends StatelessWidget {
  const TeacherNotesViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher's Uploaded Notes"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No teacher notes found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var note =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(Icons.description, color: Colors.white),
                  ),
                  title: Text(
                    note['title'] ?? "Untitled Note",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "By: ${note['uploadedBy'] ?? 'Unknown'}\nCourse: ${note['courseName'] ?? 'N/A'}",
                  ),
                  trailing: const Icon(Icons.open_in_new, color: Colors.blue),
                  onTap: () async {
                    final url = note['fileUrl'];
                    if (url != null && await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Could not open file")),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// 📄 REALTIME USER LIST VIEW (Student/Teacher)
class UserListView extends StatelessWidget {
  final String role;
  const UserListView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${role.toUpperCase()} Details"),
        backgroundColor: role == "student" ? Colors.blue : Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: role)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No ${role}s found."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var user =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user['fullName']?[0] ?? "U"),
                  ),
                  title: Text(
                    user['fullName'] ?? "N/A",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Email: ${user['email']}\n${role == "student" ? "Roll: ${user['roll']}" : "Dept: ${user['department']}"}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
