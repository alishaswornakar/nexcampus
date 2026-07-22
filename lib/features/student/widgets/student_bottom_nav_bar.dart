// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../blocs/courses/screens/courses_screen.dart';
// import '../screens/results_screen.dart';
// import '../screens/student_dashboard_screen.dart';

// class StudentBottomNavBar extends StatefulWidget {
//   const StudentBottomNavBar({super.key});

//   @override
//   State<StudentBottomNavBar> createState() => _StudentBottomNavBarState();
// }

// class _StudentBottomNavBarState extends State<StudentBottomNavBar> {
//   int _currentIndex = 0;
//   final User? user = FirebaseAuth.instance.currentUser;
//   void _onTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });

//     switch (index) {
//       case 2:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const ResultsScreen()),
//         );
//         break;

//       case 0:
//         if (user == null) {
//           // Handle the case when the user is not logged in
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => StudentDashboardScreen(user: user!),
//             ),
//           );
//         }
//         // Home
//         break;

//       case 1:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const CoursesScreen()),
//         );
//         // MBCOE
//         break;

//       case 3:
//         // Profile
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: _currentIndex,
//       onTap: _onTap,
//       selectedItemColor: Colors.blue,
//       unselectedItemColor: Colors.grey,
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.library_books_outlined, color: Colors.blueAccent),
//           label: "Courses",
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.bar_chart, color: Colors.redAccent),
//           label: "Results",
//         ),

//         BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//       ],
//     );
//   }
// }
