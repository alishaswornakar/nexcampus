import 'package:flutter/material.dart';
import 'student_list_screen.dart';

class SemesterScreen extends StatelessWidget {
  final String department;

  const SemesterScreen({
    super.key,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    final semesters = List.generate(8, (index) => index + 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(department),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: semesters.length,
        itemBuilder: (context, index) {
          final semester = semesters[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text("$semester"),
              ),
              title: Text("Semester $semester"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentListScreen(
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