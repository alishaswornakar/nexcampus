import 'package:flutter/material.dart';
import 'student_management_screen.dart';
import 'teacher_management_screen.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class ManageUsersSelectionScreen extends StatelessWidget {
  const ManageUsersSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("ManageUsersSelectionScreen Opened");

    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F6FB,
      ), // Second image jastai background
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text(
          "Manage Users",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0.5,
        automaticallyImplyLeading:
            false, // Tab vitra hune bhayera back button hatauna ramro
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Students Card (Image 2 ko card design anusar)
            _buildSelectionCard(
              context: context,
              title: "Students",
              subtitle: "Add, view, edit, and manage student accounts.",
              icon: Icons.school_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentManagementScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Teachers Card
            _buildSelectionCard(
              context: context,
              title: "Teachers",
              subtitle: "Add, view, edit, and manage teacher accounts.",
              icon: Icons.person_outline_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherManagementScreen(),
                  ),
                );
              },
            ),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          // Image 2 ko jastai card ko soft light greyish-blue background
          color: const Color(0xFFEBF1F6), 
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
            // Icon kolagi White Container Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon, 
                color: const Color(0xFF4F46E5), // Professional Blue/Indigo Shade
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
