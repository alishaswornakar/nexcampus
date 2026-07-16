import 'package:flutter/material.dart';

import 'attendance_semester_screen.dart';

class AttendanceDepartmentScreen extends StatelessWidget {
  const AttendanceDepartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: const Text("Attendance"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
=======
      appBar: AppBar(
        title: const Text("Attendance"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

>>>>>>> 1802040 (added attendance feature in teacher module)
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
<<<<<<< HEAD
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
=======
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
>>>>>>> 1802040 (added attendance feature in teacher module)
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
<<<<<<< HEAD
              builder: (_) => AttendanceSemesterScreen(department: title),
=======
              builder: (_) => AttendanceSemesterScreen(
                department: title,
              ),
>>>>>>> 1802040 (added attendance feature in teacher module)
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
<<<<<<< HEAD
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withValues(alpha: .15),
                child: Icon(icon, color: color, size: 30),
=======

              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(.15),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
>>>>>>> 1802040 (added attendance feature in teacher module)
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
<<<<<<< HEAD
}
=======
}
>>>>>>> 1802040 (added attendance feature in teacher module)
