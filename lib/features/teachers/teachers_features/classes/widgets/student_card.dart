import 'package:flutter/material.dart';

import '../models/student_model.dart';

class StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue.shade100,
          backgroundImage: student.photoUrl.isNotEmpty
              ? NetworkImage(student.photoUrl)
              : null,
          child: student.photoUrl.isEmpty
              ? const Icon(Icons.person, color: Colors.blue)
              : null,
        ),
        title: Text(
          student.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.department),
            Text("Semester ${student.semester}"),
            Text("Roll: ${student.roll}"),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      ),
    );
  }
}