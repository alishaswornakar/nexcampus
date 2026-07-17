import 'package:flutter/material.dart';

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

      return SubmissionCard(
        submission: submission,

        onTap: () {

          // Next screen:
          // Grade Submission Screen

        },
      );
    },
  );
},
),
    );
  }
}