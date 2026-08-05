import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/admin/widgets/stat_card.dart';
import 'package:nexcampus_app/features/admin/widgets/activity_item.dart';
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
import 'admin_preview_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  int managementStep = 0;
  OversightView _oversightInitialView = OversightView.mainMenu;

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Oversight tab मा थिच्दा सधैं मुख्य Oversight Menu देखिन्छ
      if (index == 2) {
        _oversightInitialView = OversightView.mainMenu;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(context),
      // ManagementScreenContent(
      //   onBackToHome: () => setState(() => _selectedIndex = 0),
      // ),
      const ManagementScreenContent(),
      OversightScreenContent(
        key: ValueKey(_oversightInitialView),
        initialView: _oversightInitialView,
        onBackToHome: () => setState(() => _selectedIndex = 0),
      ),
      const Center(child: Text("Profile Screen")),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onBottomNavTapped,
            selectedItemColor: const Color(0xFF3F51B5),
            unselectedItemColor: const Color(0xFF9CA3AF),
            selectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.manage_accounts_outlined),
                label: 'Management',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insert_chart_outlined_rounded),
                label: 'Oversight',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modal Sheet for Adding/Viewing Students or Teachers
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

  // 🏠 Home Tab Content
  Widget _buildHomeContent(BuildContext context) {
    final List<Map<String, dynamic>> dashboardItems = [
      {
        'title': 'Attendance',
        'icon': Icons.fact_check_outlined,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminAttendanceViewScreen(),
          ),
        ),
      },
      {
        'title': 'Notice',
        'icon': Icons.campaign_outlined,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NoticeManagementScreen(),
          ),
        ),
      },
      {
        'title': 'Course',
        'icon': Icons.folder_open_outlined,
        // Dashboard को Course मा थिच्दा सिधै Published Notes खुल्छ
        'onTap': () {
          setState(() {
            _oversightInitialView = OversightView.publishedNotes;
            _selectedIndex = 2;
          });
        },
      },
      {
        'title': 'Assignment',
        'icon': Icons.assignment_outlined,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AssignmentManagementScreen(),
          ),
        ),
      },
      {
        'title': 'Preview',
        'icon': Icons.visibility_outlined,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminPreviewScreen()),
        ),
      },
      {
        'title': 'Student Reports',
        'icon': Icons.report_problem_outlined,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReportMonitoringScreen(),
          ),
        ),
      },
      {
        'title': 'Digital Queue',
        'icon': Icons.confirmation_number_outlined,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminQueueManagementScreen(),
          ),
        ),
      },
      {
        'title': 'Add Student',
        'icon': Icons.person_add_alt_1_outlined,
        'onTap': () => _showManagementMenu(context, "Student"),
      },
      {
        'title': 'Add Teacher',
        'icon': Icons.person_add_outlined,
        'onTap': () => _showManagementMenu(context, "Teacher"),
      },
      {
        'title': 'Project Teams',
        'icon': Icons.groups_outlined,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminTeamManagementScreen(),
          ),
        ),
      },
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2140A7), Color(0xFF283984)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 16,
              20,
              30,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Namaste,",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Administrator",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          ),
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: StatCard(value: '12', label: 'Pending Reports'),
                      ),
                      Container(width: 12),
                      Container(
                        height: 48,
                        width: 1,
                        color: Colors.grey.shade200,
                      ),
                      Container(width: 12),
                      const Expanded(
                        child: StatCard(value: '08', label: 'Active Queues'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              "Quick Access",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.0,
              mainAxisSpacing: 14.0,
              childAspectRatio: 1.25,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildServiceCard(dashboardItems[index]),
              childCount: dashboardItems.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Activity",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildActivityCard(
                icon: Icons.person_add_outlined,
                title: "New User Registered",
                subtitle: "Kiran Thapa joined as Faculty",
                time: "15m ago",
              ),
              const SizedBox(height: 12),
              _buildActivityCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: "System Notice Published",
                subtitle: "Holiday declared for Dashain",
                time: "1h ago",
              ),
              const SizedBox(height: 12),
              _buildActivityCard(
                icon: Icons.check_circle_outline_rounded,
                title: "Report Resolved",
                subtitle: "Server latency issue addressed",
                time: "3h ago",
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item['onTap'],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'],
                color: const Color(0xFF3F51B5),
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item['title'],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return ActivityItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      time: time,
    );
  }
}

// 📄 MANAGEMENT SCREEN CONTENT
// class ManagementScreenContent extends StatelessWidget {
//   final VoidCallback onBackToHome;

//   const ManagementScreenContent({super.key, required this.onBackToHome});

//   void _showUserTypeSelectionModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "Select User Type",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 15),
//               ListTile(
//                 leading: const Icon(Icons.school, color: Color(0xFF3F51B5)),
//                 title: const Text("Student Management"),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const StudentManagementScreen(),
//                     ),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.person, color: Color(0xFF3F51B5)),
//                 title: const Text("Teacher Management"),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const TeacherManagementScreen(),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

// MANAGEMENT SCREEN CONTENT (Yo code le aafno purano ManagementScreenContent lai replace garnus)
class ManagementScreenContent extends StatelessWidget {
  const ManagementScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header matching mockup
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Manage Users",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2938),
                  ),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Info subtitle
            const Text(
              "Add, view, and manage student and teacher accounts.",
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            // Students Card
            _buildSelectionCard(
              context: context,
              title: "Students",
              subtitle: "Add, view, edit, and manage student accounts.",
              icon: Icons.school_outlined,
              iconBgColor: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0284C7),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentManagementScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // Teachers Card
            _buildSelectionCard(
              context: context,
              title: "Teachers",
              subtitle: "Add, view, edit, and manage teacher accounts.",
              icon: Icons.person_outline_rounded,
              iconBgColor: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherManagementScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Additional management shortcuts to match mockup
            _buildSelectionCard(
              context: context,
              title: "Queue Management",
              subtitle: "Configure service counters and manage digital queues.",
              icon: Icons.add_box_outlined,
              iconBgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF3F51B5),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminQueueManagementScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            _buildSelectionCard(
              context: context,
              title: "Project Teams",
              subtitle: "Review and manage student project teams.",
              icon: Icons.hub_outlined,
              iconBgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF3F51B5),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminTeamManagementScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            _buildSelectionCard(
              context: context,
              title: "Notice Board",
              subtitle: "Publish and manage campus-wide announcements.",
              icon: Icons.campaign_outlined,
              iconBgColor: const Color(0xFFFFF5EE),
              iconColor: const Color(0xFFFB923C),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NoticeManagementScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2938),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class UserListView extends StatelessWidget {
  final String role;
  const UserListView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registered ${role.toUpperCase()}s")),
      body: Center(child: Text("List of $role")),
    );
  }
}

// -----------------------------------------------------------------------------
// 👁️ OVERSIGHT SCREEN CONTENT (Exact matching for Oversight main screen & sub-screens)
// -----------------------------------------------------------------------------
enum OversightView { mainMenu, courseFilesOptions, publishedNotes }

class OversightScreenContent extends StatefulWidget {
  final VoidCallback onBackToHome;
  final OversightView initialView;

  const OversightScreenContent({
    super.key,
    required this.onBackToHome,
    this.initialView = OversightView.mainMenu,
  });

  @override
  State<OversightScreenContent> createState() => _OversightScreenContentState();
}

class _OversightScreenContentState extends State<OversightScreenContent> {
  late OversightView _currentView;

  @override
  void initState() {
    super.initState();
    _currentView = widget.initialView;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentView == OversightView.mainMenu,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          if (_currentView == OversightView.publishedNotes) {
            _currentView = OversightView.courseFilesOptions;
          } else {
            _currentView = OversightView.mainMenu;
          }
        });
      },
      child: _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      // 🎓 Published Notes List View
      case OversightView.publishedNotes:
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => setState(
                () => _currentView = OversightView.courseFilesOptions,
              ),
            ),
            title: const Text(
              'Published Notes',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notes')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              int count = docs.length;

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3352E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Reviewing ${count > 0 ? count : 6} Published Notes",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Faculty uploads pending audit.",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "12 New Today",
                                style: TextStyle(
                                  color: Color(0xFF3352E0),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "3 Departments",
                                style: TextStyle(
                                  color: Color(0xFF3352E0),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (docs.isEmpty) ...[
                    _buildNoteCard(
                      title: "Math",
                      author: "ranju",
                      department: "General",
                      url: "",
                    ),
                    _buildNoteCard(
                      title: "chapter 1",
                      author: "ranju",
                      department: "General",
                      url: "",
                    ),
                    _buildNoteCard(
                      title: "C Programming",
                      author: "ranju",
                      department: "General",
                      url: "",
                    ),
                    _buildNoteCard(
                      title: "notes",
                      author: "ranju",
                      department: "General",
                      url: "",
                    ),
                    _buildNoteCard(
                      title: "unit 1",
                      author: "ranju",
                      department: "General",
                      url: "",
                    ),
                    _buildNoteCard(
                      title: "edc notes",
                      author: "ranju",
                      department: "General",
                      url: "",
                    ),
                  ] else ...[
                    ...docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildNoteCard(
                        title: data['title'] ?? 'Untitled Note',
                        author:
                            data['uploadedBy'] ?? data['author'] ?? 'Faculty',
                        department: data['department'] ?? 'General',
                        url: data['fileUrl'] ?? '',
                      );
                    }),
                  ],
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        );

      // 📁 Course Files View
      case OversightView.courseFilesOptions:
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () =>
                  setState(() => _currentView = OversightView.mainMenu),
            ),
            title: const Text(
              'Course Files',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _currentView = OversightView.publishedNotes;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school_outlined,
                            color: Color(0xFF3F51B5),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Teacher's Uploaded Notes",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "View notes shared by faculty members.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF64748B),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      // 👁️ Main Oversight Screen (Matches Screenshot Exact UI)
      case OversightView.mainMenu:
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: widget.onBackToHome,
            ),
            title: const Text(
              'Oversight',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // 1. Attendance Option
              _buildOversightMenuCard(
                icon: Icons.calendar_today_outlined,
                title: "Attendance",
                subtitle: "View and monitor student attendance records.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminAttendanceViewScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // 2. Course Files Option
              _buildOversightMenuCard(
                icon: Icons.folder_open_outlined,
                title: "Course Files",
                subtitle:
                    "Review courses materials uploaded by administrators and teachers.",
                onTap: () {
                  setState(() {
                    _currentView = OversightView.courseFilesOptions;
                  });
                },
              ),
              const SizedBox(height: 14),

              // 3. Reports Option
              _buildOversightMenuCard(
                icon: Icons.description_outlined,
                title: "Reports",
                subtitle: "Review reported issues and administrative reports.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportMonitoringScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
    }
  }

  // Card Widget for Main Oversight Menu
  Widget _buildOversightMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF3F51B5), size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF64748B),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Individual Note Item Card
  Widget _buildNoteCard({
    required String title,
    required String author,
    required String department,
    required String url,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDBE2FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF3F51B5),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "By $author",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
                Text(
                  department,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.open_in_new_rounded,
              color: Color(0xFF64748B),
              size: 22,
            ),
            onPressed: () async {
              if (url.isNotEmpty) {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:nexcampus_app/core/constants/app_theme.dart';
// import 'package:nexcampus_app/features/admin/screens/assignment_management_screen.dart';
// import 'notice_management_screen.dart';
// import 'report_monitoring_screen.dart';
// import '../../authentication/presentation/pages/login_screen.dart';
// import 'student_management_screen.dart';
// import 'teacher_management_screen.dart';
// import 'admin_attendance_view_screen.dart';
// import 'admin_team_management_screen.dart';
// import 'admin_queue_management_screen.dart';
// import 'package:url_launcher/url_launcher.dart';

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   int _selectedIndex = 0;

//   void _onBottomNavTapped(int index) {
//     if (index == 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const NoticeManagementScreen()),
//       );
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   // 📂 Management Menu for Student/Teacher (Add & View)
//   void _showManagementMenu(BuildContext context, String type) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Manage ${type}s",
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 15),
//               ListTile(
//                 leading: const Icon(Icons.person_add_alt_1, color: Colors.pink),
//                 title: Text("Add New $type"),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => type == "Student"
//                           ? const StudentManagementScreen()
//                           : const TeacherManagementScreen(),
//                     ),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.visibility, color: Colors.blue),
//                 title: Text("View Registered ${type}s"),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           UserListView(role: type.toLowerCase()),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // 📂 Course Files Menu: Admin file option removed, directly opens Teacher's Notes
//   void _showCourseFileMenu(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const TeacherNotesViewScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = AppTheme.primaryColor ?? Colors.blue;

//     final List<Map<String, dynamic>> dashboardItems = [
//       {
//         'title': 'View Attendance',
//         'icon': Icons.fact_check_outlined,
//         'color': Colors.purple,
//         'onTap': () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const AdminAttendanceViewScreen(),
//           ),
//         ),
//       },
//       {
//         'title': 'Course Files',
//         'icon': Icons.folder_open_outlined,
//         'color': Colors.teal,
//         'onTap': () => _showCourseFileMenu(context),
//       },
//       {
//         'title': 'Notices',
//         'icon': Icons.campaign_outlined,
//         'color': Colors.orange,
//         'onTap': () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const NoticeManagementScreen(),
//           ),
//         ),
//       },
//       {
//         'title': 'Student Reports',
//         'icon': Icons.report_problem_outlined,
//         'color': Colors.deepPurple,
//         'onTap': () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const ReportMonitoringScreen(),
//           ),
//         ),
//       },
//       {
//         'title': 'Add New Student',
//         'icon': Icons.person_add_alt_1_outlined,
//         'color': Colors.pink,
//         'onTap': () => _showManagementMenu(context, "Student"),
//       },
//       {
//         'title': 'Add New Teacher',
//         'icon': Icons.person_add_outlined,
//         'color': Colors.pink,
//         'onTap': () => _showManagementMenu(context, "Teacher"),
//       },
//       {
//         'title': 'Assignments',
//         'icon': Icons.assignment_outlined,
//         'color': Colors.blueAccent,
//         'onTap': () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const AssignmentManagementScreen(),
//           ),
//         ),
//       },
//       {
//         'title': 'Digital Queue',
//         'icon': Icons.confirmation_number_outlined,
//         'color': Colors.indigo,
//         'onTap': () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const AdminQueueManagementScreen(),
//           ),
//         ),
//       },
//       {
//         'title': 'Project Teams',
//         'icon': Icons.groups_outlined,
//         'color': Colors.blue,
//         'onTap': () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const AdminTeamManagementScreen(),
//           ),
//         ),
//       },
//     ];

//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F5FB),
//       body: SafeArea(
//         child: CustomScrollView(
//           slivers: [
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Container(
//                   padding: const EdgeInsets.all(20.0),
//                   decoration: BoxDecoration(
//                     color: primaryColor,
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF1E6091), Color(0xFF0077B6)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Welcome Back,",
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                           Text(
//                             "Administrator 👋",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       IconButton(
//                         icon: const Icon(
//                           Icons.logout_outlined,
//                           color: Colors.white,
//                         ),
//                         onPressed: () => Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const LoginScreen(),
//                           ),
//                           (route) => false,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SliverPadding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               sliver: SliverGrid(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12.0,
//                   mainAxisSpacing: 12.0,
//                   childAspectRatio: 1.1,
//                 ),
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) => _buildServiceCard(dashboardItems[index]),
//                   childCount: dashboardItems.length,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onBottomNavTapped,
//         selectedItemColor: primaryColor,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.grid_view_rounded),
//             label: 'Dashboard',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.campaign_outlined),
//             label: 'Notices',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildServiceCard(Map<String, dynamic> item) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
//         ],
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: item['onTap'],
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               backgroundColor: (item['color'] as Color).withValues(alpha: 0.1),
//               child: Icon(item['icon'], color: item['color']),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               item['title'],
//               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 📄 TEACHER LE HALEKO NOTES HERNE SCREEN
// class TeacherNotesViewScreen extends StatelessWidget {
//   const TeacherNotesViewScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Teacher's Uploaded Notes"),
//         backgroundColor: Colors.orange,
//         foregroundColor: Colors.white,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('notes')
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No teacher notes found."));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               var note =
//                   snapshot.data!.docs[index].data() as Map<String, dynamic>;
//               return Card(
//                 elevation: 2,
//                 margin: const EdgeInsets.only(bottom: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: ListTile(
//                   leading: const CircleAvatar(
//                     backgroundColor: Colors.orangeAccent,
//                     child: Icon(Icons.description, color: Colors.white),
//                   ),
//                   title: Text(
//                     note['title'] ?? "Untitled Note",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(
//                     "By: ${note['uploadedBy'] ?? 'Unknown'}\nCourse: ${note['courseName'] ?? 'N/A'}",
//                   ),
//                   trailing: const Icon(Icons.open_in_new, color: Colors.blue),
//                   onTap: () async {
//                     final url = note['fileUrl'];
//                     if (url != null && await canLaunchUrl(Uri.parse(url))) {
//                       await launchUrl(
//                         Uri.parse(url),
//                         mode: LaunchMode.externalApplication,
//                       );
//                     } else {
//                       if (!context.mounted) return;
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Could not open file")),
//                       );
//                     }
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// // 📄 REALTIME USER LIST VIEW (Student/Teacher)
// class UserListView extends StatelessWidget {
//   final String role;
//   const UserListView({super.key, required this.role});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("${role.toUpperCase()} Details"),
//         backgroundColor: role == "student" ? Colors.blue : Colors.green,
//         foregroundColor: Colors.white,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             .where('role', isEqualTo: role)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No ${role}s found."));
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               var user =
//                   snapshot.data!.docs[index].data() as Map<String, dynamic>;
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     child: Text(user['fullName']?[0] ?? "U"),
//                   ),
//                   title: Text(
//                     user['fullName'] ?? "N/A",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(
//                     "Email: ${user['email']}\n${role == "student" ? "Roll: ${user['roll']}" : "Dept: ${user['department']}"}",
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
