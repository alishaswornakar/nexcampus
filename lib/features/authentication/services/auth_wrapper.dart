import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/authentication/presentation/pages/login_screen.dart';
import 'package:nexcampus_app/features/student/screen/student_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User logged in
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          return StudentDashboardScreen(user: user);
        }

        // User not logged in
        return const LoginScreen();
      },
    );
  }
}
