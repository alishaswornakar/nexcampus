import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';


class StudentDetailScreen extends StatelessWidget {
  final StudentModel student;

  const StudentDetailScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: student.photoUrl.isNotEmpty
                  ? NetworkImage(student.photoUrl)
                  : null,
              child: student.photoUrl.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 50,
                    )
                  : null,
            ),
            const SizedBox(height: 20),

            Text(
              student.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            ListTile(
              leading: const Icon(Icons.email),
              title: Text(student.email),
            ),

            ListTile(
              leading: const Icon(Icons.school),
              title: Text(student.department),
            ),

            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text("Semester ${student.semester}"),
            ),

            ListTile(
              leading: const Icon(Icons.badge),
              title: Text("Roll: ${student.roll}"),
            ),
          ],
        ),
      ),
    );
  }
}