import 'package:flutter/material.dart';

import 'assignment_semester_screen.dart';

class AssignmentDepartmentScreen extends StatelessWidget {
  const AssignmentDepartmentScreen({super.key});

  final List<String> departments = const [
    "Computer Engineering",
    "Civil Engineering",
    "Architecture Engineering",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Select Department"),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: departments.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final department = departments[index];

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              leading: CircleAvatar(
                backgroundColor:
                    Colors.blue.shade100,
                child: const Icon(
                  Icons.school,
                  color: Colors.blue,
                ),
              ),
              title: Text(
                department,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
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
                        AssignmentSemesterScreen(
                      department: department,
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