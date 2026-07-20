import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/screens/grade_submission_screen.dart';

import '../models/assignment_model.dart';
import '../models/assignment_submission_model.dart';

import '../repository/assignment_submission_repository.dart';
import '../services/assignment_submission_service.dart';

import '../widgets/submission_card.dart';

class TeacherSubmissionListScreen extends StatelessWidget {
  final AssignmentModel assignment;

  TeacherSubmissionListScreen({
    super.key,
    required this.assignment,
  });

  final repository =
      AssignmentSubmissionRepository(
    AssignmentSubmissionService(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          assignment.title,
        ),
      ),

      body: StreamBuilder<
          List<AssignmentSubmissionModel>>(
        stream: repository
            .getAssignmentSubmissions(
          assignmentId: assignment.id,
        ),
        builder: (context, snapshot) {

  if (snapshot.connectionState ==
      ConnectionState.waiting) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (snapshot.hasError) {
    return Center(
      child: Text(snapshot.error.toString()),
    );
  }

  if (!snapshot.hasData ||
      snapshot.data!.isEmpty) {
    return const Center(
      child: Text(
        "No submissions yet.",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  final submissions = snapshot.data!;

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: submissions.length,
    itemBuilder: (context, index) {

      final submission =
          submissions[index];

     Card(
  margin: const EdgeInsets.only(bottom: 14),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: ListTile(
    contentPadding: const EdgeInsets.all(16),

    leading: CircleAvatar(
      backgroundColor: Colors.blue.shade100,
      child: const Icon(
        Icons.person,
        color: Colors.blue,
      ),
    ),

    title: Text(
      submission.studentName,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    subtitle: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 6),

        Text(
          "Roll: ${submission.roll}",
        ),

        Text(
          "Status: ${submission.status}",
        ),

        if (submission.grade.isNotEmpty)
          Text(
            "Marks: ${submission.grade}",
          ),
      ],
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
              GradeSubmissionScreen(
            submission: submission,
          ),
        ),
      );
    },
  ),
);
    },
  );
},
),
    );
  }
}