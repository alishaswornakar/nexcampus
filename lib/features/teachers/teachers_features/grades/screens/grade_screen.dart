import 'package:flutter/material.dart';

class GradeScreen extends StatelessWidget {
  final String department;
  final String semester;

  const GradeScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grades"),
      ),
      body: Center(
        child: Text(
          "Department: $department\nSemester: $semester",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}