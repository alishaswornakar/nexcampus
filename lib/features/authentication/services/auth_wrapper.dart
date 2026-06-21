// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:nexcampus_app/features/authentication/presentation/pages/login_screen.dart';
// // import 'package:nexcampus_app/features/student/screens/student_dashboard_screen.dart';

// // class AuthWrapper extends StatelessWidget {
// //   const AuthWrapper({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return StreamBuilder<User?>(
// //       stream: FirebaseAuth.instance.authStateChanges(),
// //       builder: (context, snapshot) {
// //         // Loading state
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Scaffold(
// //             body: Center(child: CircularProgressIndicator()),
// //           );
// //         }

// //         // User logged in
// //         if (snapshot.hasData && snapshot.data != null) {
// //           final user = snapshot.data!;

// //           return StudentDashboardScreen(user: user);
// //         }

// //         // User not logged in
// //         return const LoginScreen();
// //       },
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:nexcampus_app/features/authentication/blocs/auth/auth_bloc.dart';
// import 'package:nexcampus_app/features/authentication/blocs/auth/auth_state.dart';
// import 'package:nexcampus_app/features/authentication/presentation/pages/login_screen.dart';
// import 'package:nexcampus_app/features/student/screens/student_dashboard_screen.dart';

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, state) {
//         if (state is AuthLoading) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // if (state is AuthAuthenticated) {
//         //   if (state.role == 'admin') {
//         //     return const AdminDashboardScreen();
//         //   } else if (state.role == 'teacher') {
//         //     return const TeacherDashboardScreen();
//         //   } else {
//         //     return const StudentDashboardScreen(user: ,);
//         //   }
//         // }

//         return const LoginScreen();
//       },
//     );
//   }
// }
 import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nexcampus_app/features/student/screens/student_dashboard_screen.dart';
import 'package:nexcampus_app/features/teacher/screens/teacher_dashboard_screen.dart';
import 'package:nexcampus_app/features/admin/screens/admin_dashboard_screen.dart';
import 'package:nexcampus_app/features/authentication/presentation/pages/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String?> _getRole(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!doc.exists) return null;
    return doc['role'];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = snapshot.data!;

        return FutureBuilder<String?>(
          future: _getRole(user.uid),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;

            if (role == 'admin') {
              return const AdminDashboardScreen();
            } else if (role == 'teacher') {
              return const TeacherDashboardScreen();
            } else {
              return const StudentDashboardScreen();
            }
          },
        );
      },
    );
  }
}