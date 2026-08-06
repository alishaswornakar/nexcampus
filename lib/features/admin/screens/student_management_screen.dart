import 'package:flutter/material.dart';
import 'student_list_screen.dart';
import 'add_student_screen.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class StudentManagementScreen extends StatelessWidget {
  const StudentManagementScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white, // Back button + title color
        elevation: 0,
        centerTitle: false,
        title: const Text("Student Management"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Directory Card
                _buildSelectionCard(
                  context: context,
                  title: "Student Directory",
                  subtitle: "Browse and manage registered students.",
                  icon: Icons.group_outlined,
                  //iconBgColor: const Color(0xFFE0F2FE),
                  //iconColor: const Color(0xFF0284C7),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentListScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Add New Student Card
                _buildSelectionCard(
                  context: context,
                  title: "Add New Student",
                  subtitle: "Register a new student account.",
                  icon: Icons.person_add_outlined,
                  //iconBgColor: const Color(0xFFFEF3C7),
                  //iconColor: const Color(0xFFD97706),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddStudentScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    //return Material(
    //   color: AppTheme.background, // Background color yeta rakhne

    // );
  }

  Widget _buildSelectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF1F6), // Soft greyish-blue card background
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // White Icon Container Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon, 
                color: const Color(0xFF4F46E5), // Professional Indigo Shade
                size: 28,
              ),
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
    );
  }
}
