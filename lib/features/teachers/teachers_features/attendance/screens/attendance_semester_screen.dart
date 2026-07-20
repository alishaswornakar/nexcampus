import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/screens/attendance_subject_screen.dart';


class AttendanceSemesterScreen extends StatelessWidget {
  final String department;

  const AttendanceSemesterScreen({
    super.key,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(department),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) {

          final semester = index + 1;

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              leading: CircleAvatar(
                child: Text("$semester"),
              ),
              title: Text(
                "Semester $semester",
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
              onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AttendanceSubjectScreen(
        department: department,
        semester: semester.toString(),
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