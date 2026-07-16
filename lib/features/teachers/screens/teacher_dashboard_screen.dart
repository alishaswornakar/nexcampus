// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:nexcampus_app/features/authentication/presentation/pages/login_screen.dart';

// // Import your login screen

// class TeacherDashboard extends StatelessWidget {
//   const TeacherDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffF5F7FA),

//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         elevation: 0,
//         title: const Text(
//           "Teacher Dashboard",
//           style: TextStyle(color: Colors.white),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               // TODO: Notifications
//             },
//             icon: const Icon(Icons.notifications, color: Colors.white),
//           ),

//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) {
//               if (value == "logout") {
//                 _showLogoutDialog(context);
//               }
//             },
//             itemBuilder: (context) => const [
//               PopupMenuItem(
//                 value: "logout",
//                 child: Row(
//                   children: [
//                     Icon(Icons.logout, color: Colors.red),
//                     SizedBox(width: 10),
//                     Text("Logout"),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             /// Welcome Card
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: const Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 35,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.person,
//                       color: Colors.blue,
//                       size: 40,
//                     ),
//                   ),
//                   SizedBox(width: 15),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Welcome",
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 16,
//                         ),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         "",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),

//             const SizedBox(height: 25),

//             const Text(
//               "Overview",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 22,
//               ),
//             ),

//             const SizedBox(height: 15),

//             Row(
//               children: [
//                 Expanded(
//                   child: statCard(
//                     "Classes",
//                     "6",
//                     Icons.class_,
//                     Colors.orange,
//                   ),
//                 ),
//                 const SizedBox(width: 15),
//                 Expanded(
//                   child: statCard(
//                     "Students",
//                     "180",
//                     Icons.people,
//                     Colors.green,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 15),

//             Row(
//               children: [
//                 Expanded(
//                   child: statCard(
//                     "Assignments",
//                     "12",
//                     Icons.assignment,
//                     Colors.purple,
//                   ),
//                 ),
//                 const SizedBox(width: 15),
//                 Expanded(
//                   child: statCard(
//                     "Attendance",
//                     "95%",
//                     Icons.check_circle,
//                     Colors.red,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             const Text(
//               "Quick Access",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 22,
//               ),
//             ),

//             const SizedBox(height: 15),

//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 15,
//               mainAxisSpacing: 15,
//               childAspectRatio: 1.1,
//               children: [

//                 featureCard(
//                   Icons.calendar_today,
//                   "Attendance",
//                   Colors.blue,
//                 ),

//                 featureCard(
//                   Icons.assignment,
//                   "Assignments",
//                   Colors.green,
//                 ),

//                 featureCard(
//                   Icons.grade,
//                   "Grades",
//                   Colors.orange,
//                 ),

//                 featureCard(
//                   Icons.campaign,
//                   "Notices",
//                   Colors.deepPurple,
//                 ),

//                 featureCard(
//                   Icons.group,
//                   "Students",
//                   Colors.red,
//                 ),

//                 featureCard(
//                   Icons.chat,
//                   "Messages",
//                   Colors.teal,
//                 ),

//                 featureCard(
//                   Icons.schedule,
//                   "Routine",
//                   Colors.indigo,
//                 ),

//                 featureCard(
//                   Icons.person,
//                   "Profile",
//                   Colors.brown,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),

//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 0,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: "Home",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.class_),
//             label: "Classes",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: "Profile",
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------------- LOGOUT ----------------

//   Future<void> _showLogoutDialog(BuildContext context) async {
//     final logout = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Logout"),
//         content: const Text(
//           "Are you sure you want to logout?",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );

//     if (logout == true) {
//       await FirebaseAuth.instance.signOut();

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const LoginScreen(),
//         ),
//         (route) => false,
//       );
//     }
//   }
//     // ---------------- STAT CARD ----------------

//   Widget statCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 5,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 25,
//             backgroundColor: color.withOpacity(0.15),
//             child: Icon(
//               icon,
//               color: color,
//               size: 28,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.grey,
//               fontSize: 15,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------------- FEATURE CARD ----------------

//   Widget featureCard(
//     IconData icon,
//     String title,
//     Color color,
//   ) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(18),
//       onTap: () {
//         // TODO: Navigate to the corresponding screen
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 5,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: color.withOpacity(0.15),
//               child: Icon(
//                 icon,
//                 color: color,
//                 size: 30,
//               ),
//             ),
//             const SizedBox(height: 15),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// teacher_dashboard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/features/authentication/presentation/pages/login_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/screens/department_screen.dart';
//import 'package:nexcampus_app/features/teachers/teachers_features/classes/screens/student_list_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == "logout") {
                _logout(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            teacherWelcomeCard(),
            const SizedBox(height: 20),
            const Text(
              "Overview",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _stat("Classes", "6", Icons.class_, Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _stat("Students", "180", Icons.people, Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _stat(
                    "Assignments",
                    "12",
                    Icons.assignment,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _stat(
                    "Attendance",
                    "95%",
                    Icons.check_circle,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Quick Access",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                _feature(Icons.calendar_today, "Attendance", Colors.blue, () {
                  // TODO: Attendance Screen
                }),

                _feature(Icons.assignment, "Assignments", Colors.green, () {
                  // TODO: Assignment Screen
                }),

                _feature(Icons.grade, "Grades", Colors.orange, () {
                  // TODO: Grades Screen
                }),

                _feature(Icons.campaign, "Notices", Colors.deepPurple, () {
                  // TODO: Notice Screen
                }),

                _feature(Icons.class_, "Classes", Colors.red, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DepartmentScreen()),
                  );
                }),
                _feature(Icons.person, "Profile", Colors.teal, () {
                  // TODO: Profile Screen
                }),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: "Classes"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget teacherWelcomeCard() {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        String teacherName = "Teacher";

        // First try Firebase Authentication displayName
        if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
          teacherName = user.displayName!;
        }

        // If displayName is empty, use Firestore fullName
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;

          if (data['fullName'] != null &&
              data['fullName'].toString().isNotEmpty) {
            teacherName = data['fullName'];
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    teacherName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String t, String v, IconData i, Color c) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: [
        Icon(i, color: c),
        const SizedBox(height: 8),
        Text(
          v,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        Text(t),
      ],
    ),
  );

  Widget _feature(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false,
        );
      }
    }
  }
}
