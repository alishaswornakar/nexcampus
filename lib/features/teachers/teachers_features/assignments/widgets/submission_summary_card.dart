import 'package:flutter/material.dart';

import '../models/assignment_model.dart';

class SubmissionSummaryCard extends StatelessWidget {
  final AssignmentModel assignment;

  const SubmissionSummaryCard({
    super.key,
    required this.assignment,
  });

  Widget buildTile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(
          icon,
          color: Colors.blue,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: Column(
          children: [

            buildTile(
              Icons.assignment,
              "Assignment",
              assignment.title,
            ),

            buildTile(
              Icons.school,
              "Department",
              assignment.department,
            ),

            buildTile(
              Icons.layers,
              "Semester",
              assignment.semester,
            ),

            buildTile(
              Icons.menu_book,
              "Subject",
              assignment.subject,
            ),

            buildTile(
              Icons.calendar_today,
              "Due Date",
              "${assignment.dueDate.day}/${assignment.dueDate.month}/${assignment.dueDate.year}",
            ),
          ],
        ),
      ),
    );
  }
}