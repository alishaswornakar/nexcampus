import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 Firestore import thapiyo
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/admin/screens/assignment_management_screen.dart';
import 'notice_management_screen.dart';
import 'report_monitoring_screen.dart';
import '../../authentication/presentation/pages/login_screen.dart';
import 'student_management_screen.dart';
import 'teacher_management_screen.dart';
import 'admin_attendance_view_screen.dart';
import 'course_file_management_scree.dart';
import 'admin_team_management_screen.dart';
import 'admin_queue_management_screen.dart'; // 👈 1. Digital Queue Import थपियो

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      // 📢 Notices tab click गर्दा Notice Management Screen मा जाने
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

  // 📂 Professional Folder-Style Menu for Student/Teacher
  void showManagementMenu(BuildContext context, String type) {
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.primaryColor ?? Colors.blue;

    final List<Map<String, dynamic>> dashboardItems = [
      {
        'title': 'View Attendance',
        'subtitle': '',
        'icon': Icons.fact_check_outlined,
        'color': Colors.purple,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAttendanceViewScreen(),
            ),
          );
        },
      },
      {
        'title': 'Course Files',
        'subtitle': '',
        'icon': Icons.folder_open_outlined,
        'color': Colors.teal,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CourseFileManagementScreen(),
            ),
          );
        },
      },
      {
        'title': 'Notices',
        'subtitle': '',
        'icon': Icons.campaign_outlined,
        'color': Colors.orange,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoticeManagementScreen(),
            ),
          );
        },
      },
      {
        'title': 'Student Reports',
        'subtitle': '',
        'icon': Icons.report_problem_outlined,
        'color': Colors.deepPurple,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportMonitoringScreen(),
            ),
          );
        },
      },
      {
        'title': 'Add New Student',
        'subtitle': '',
        'icon': Icons.person_add_alt_1_outlined,
        'color': Colors.pink,
        'onTap': () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentManagementScreen(),
            ),
          );
          setState(() {});
        },
      },
      {
        'title': 'Add New Teacher',
        'subtitle': '',
        'icon': Icons.person_add_outlined,
        'color': Colors.pink,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TeacherManagementScreen(),
            ),
          );
        },
      },
      {
        'title': 'Assignments',
        'subtitle': '',
        'icon': Icons.assignment_outlined,
        'color': Colors.blueAccent,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AssignmentManagementScreen(),
            ),
          );
        },
      },
      {
        'title':
            'Digital Queue', // 👈 2. SnackBar को सट्टा Navigation जोडिएको छ
        'subtitle': '',
        'icon': Icons.confirmation_number_outlined,
        'color': Colors.indigo,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminQueueManagementScreen(),
            ),
          );
        },
      },
      {
        'title': 'Project Teams',
        'subtitle': '',
        'icon': Icons.groups_outlined,
        'color': Colors.blue,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminTeamManagementScreen(),
            ),
          );
        },
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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

                      // Logout Action
                      InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = dashboardItems[index];
                  return _buildServiceCard(item);
                }, childCount: dashboardItems.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
            // ignore: deprecated_member_use
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

// 📄 REALTIME USER LIST VIEW (Student/Teacher details dekhuna)
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

// import 'package:flutter/material.dart';
// import 'package:nexcampus_app/core/constants/app_theme.dart';
// import 'package:nexcampus_app/features/admin/screens/assignment_management_screen.dart';
// import 'notice_management_screen.dart';
// import 'report_monitoring_screen.dart';
// import '../../authentication/presentation/pages/login_screen.dart';
// import 'student_management_screen.dart';
// import 'teacher_management_screen.dart';
// import 'admin_attendance_view_screen.dart';
// import 'course_file_management_scree.dart';
// import 'admin_team_management_screen.dart';
// import 'admin_queue_management_screen.dart'; // 👈 1. Digital Queue Import थपियो

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   int _selectedIndex = 0;

//   // Bottom Navigation Click Handlers
//   void _onBottomNavTapped(int index) {
//     if (index == 1) {
//       // 📢 Notices tab click गर्दा Notice Management Screen मा जाने
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const NoticeManagementScreen(),
//         ),
//       );
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = AppTheme.primaryColor ?? Colors.blue;

//     // List of Dashboard Grid Items
//     final List<Map<String, dynamic>> dashboardItems = [
//       {
//         'title': 'View Attendance',
//         'subtitle': '',
//         'icon': Icons.fact_check_outlined,
//         'color': Colors.purple,
//         'onTap': () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AdminAttendanceHistoryScreen(),
//             ),
//           );
//         },
//       },
//       {
//         'title': 'Course Files',
//         'subtitle': '',
//         'icon': Icons.folder_open_outlined,
//         'color': Colors.teal,
//         'onTap': () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const CourseFileManagementScreen(),
//             ),
//           );
//         },
//       },
//       {
//         'title': 'Notices',
//         'subtitle': '',
//         'icon': Icons.campaign_outlined,
//         'color': Colors.orange,
//         'onTap': () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const NoticeManagementScreen(),
//             ),
//           );
//         },
//       },
//       {
//         'title': 'Student Reports',
//         'subtitle': '',
//         'icon': Icons.report_problem_outlined,
//         'color': Colors.deepPurple,
//         'onTap': () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ReportMonitoringScreen(),
//             ),
//           );
//         },
//       },
//       {
//         'title': 'Add New Student',
//         'subtitle': '',
//         'icon': Icons.person_add_alt_1_outlined,
//         'color': Colors.pink,
//         'onTap': () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const StudentManagementScreen(),
//             ),
//           );
//           setState(() {});
//         },
//       },
//       {
//         'title': 'Add New Teacher',
//         'subtitle': '',
//         'icon': Icons.person_add_outlined,
//         'color': Colors.pink,
//         'onTap': () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const TeacherManagementScreen(),
//             ),
//           );
//         },
//       },
//       {
//         'title': 'Assignments',
//         'subtitle': '',
//         'icon': Icons.assignment_outlined,
//         'color': Colors.blueAccent,
//         'onTap': () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AssignmentManagementScreen(),
//             ),
//           );
//         },
//       },
//       {
//         'title': 'Digital Queue', // 👈 2. SnackBar को सट्टा Navigation जोडिएको छ
//         'subtitle': '',
//         'icon': Icons.confirmation_number_outlined,
//         'color': Colors.indigo,
//         'onTap': () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AdminQueueManagementScreen(),
//             ),
//           );
//         },
//       },
//       {
//         'title': 'Project Teams',
//         'subtitle': '',
//         'icon': Icons.groups_outlined,
//         'color': Colors.blue,
//         'onTap': () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AdminTeamManagementScreen(),
//             ),
//           );
//         },
//       },
//     ];

//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F5FB),
//       body: SafeArea(
//         child: CustomScrollView(
//           slivers: [
//             // 1. Blue Header Banner
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
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withValues(alpha:0.2),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
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
//                           SizedBox(height: 4),
//                           Text(
//                             "Administrator 👋",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             "Manage your institution with ease",
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),

//                       // Logout Action
//                       InkWell(
//                         onTap: () {
//                           Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const LoginScreen(),
//                             ),
//                             (route) => false,
//                           );
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withValues(alpha:0.2),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.logout_outlined,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // 2. 2-Column Dashboard Cards Grid
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
//                   (context, index) {
//                     final item = dashboardItems[index];
//                     return _buildServiceCard(item);
//                   },
//                   childCount: dashboardItems.length,
//                 ),
//               ),
//             ),
//             const SliverToBoxAdapter(
//               child: SizedBox(height: 20),
//             ),
//           ],
//         ),
//       ),

//       // 3. Bottom Navigation Bar
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onBottomNavTapped,
//         selectedItemColor: primaryColor,
//         unselectedItemColor: Colors.grey,
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

//   // Card Widget Builder
//   Widget _buildServiceCard(Map<String, dynamic> item) {
//     bool hasSubtitle = item['subtitle'].toString().isNotEmpty;

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(20),
//           onTap: item['onTap'],
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Circular Background Icon
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: (item['color'] as Color).withValues(alpha:0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     item['icon'],
//                     color: item['color'],
//                     size: 26,
//                   ),
//                 ),
//                 const SizedBox(height: 10),

//                 // Main Text / Title
//                 Text(
//                   item['title'],
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: hasSubtitle ? 20 : 13,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),

//                 // Subtitle (if available)
//                 if (hasSubtitle) ...[
//                   const SizedBox(height: 2),
//                   Text(
//                     item['subtitle'],
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
