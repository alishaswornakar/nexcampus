import 'package:flutter/material.dart';

import 'assignment_subject_screen.dart';

class AssignmentSemesterScreen extends StatelessWidget {
  final String department;

  const AssignmentSemesterScreen({
    super.key,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: Text(department),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) {
          final semester = index + 1;

          return Card(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Colors.green.shade100,
                child: Text(
                  semester.toString(),
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                "Semester $semester",
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AssignmentSubjectScreen(
                      department: department,
                      semester: semester,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}