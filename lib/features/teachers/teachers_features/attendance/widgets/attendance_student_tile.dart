import 'package:flutter/material.dart';
import '../../classes/models/student_model.dart';

class AttendanceStudentTile extends StatelessWidget {
  final StudentModel student;
  final bool present;
  final ValueChanged<bool> onChanged;

  const AttendanceStudentTile({
    super.key,
    required this.student,
    required this.present,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            student.fullName[0],
          ),
        ),
        title: Text(student.fullName),
        subtitle: Text(
          "Roll: ${student.roll}",
        ),
        trailing: Switch(
          value: present,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
