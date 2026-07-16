import 'package:flutter/material.dart';

import 'attendance_semester_screen.dart';

class AttendanceDepartmentScreen extends StatelessWidget {
  const AttendanceDepartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [


      appBar: AppBar(title: const Text("Attendance"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
 f923e1d (resolving merge between teacher and student attendance part)
          _departmentCard(
            context,
            title: "Computer Engineering",
            icon: Icons.computer,
            color: Colors.blue,
          ),

          _departmentCard(
            context,
            title: "Civil Engineering",
            icon: Icons.architecture,
            color: Colors.orange,
          ),

          _departmentCard(
            context,
            title: "Architecture Engineering",
            icon: Icons.apartment,
            color: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _departmentCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
 f923e1d (resolving merge between teacher and student attendance part)
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttendanceSemesterScreen(
                department: title,
              ),

              builder: (_) => AttendanceSemesterScreen(department: title),
 f923e1d (resolving merge between teacher and student attendance part)
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [

              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(.15),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),

              CircleAvatar(
                radius: 30,
                backgroundColor: color.withValues(alpha: .15),
                child: Icon(icon, color: color, size: 30),
 f923e1d (resolving merge between teacher and student attendance part)
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
}
 f923e1d (resolving merge between teacher and student attendance part)
