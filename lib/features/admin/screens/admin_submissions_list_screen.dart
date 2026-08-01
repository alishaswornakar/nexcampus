import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/submission_model.dart';
import '../services/admin_assignment_service.dart';
import 'submission_detail_screen.dart';

/// Shows every student submission for a single assignment.
///
/// Reached from [AssignmentDetailScreen] via the
/// "View Student Submissions" button. Pulls live from
/// `AdminAssignmentService.getSubmissionsForAssignment`, which queries the
/// `assignment_submissions` collection filtered by assignmentId — the same
/// collection the student module writes into, so this now reflects real
/// submissions instead of an empty/mismatched collection.
class AdminSubmissionsListScreen extends StatelessWidget {
  final String assignmentId;
  final String assignmentTitle;

  const AdminSubmissionsListScreen({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        title: Text(
          "Submissions · $assignmentTitle",
          style: const TextStyle(color: Colors.black, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: AdminAssignmentService.getSubmissionsForAssignment(assignmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No students have submitted this assignment yet."),
            );
          }

          final submissions = snapshot.data!.docs.map((doc) {
            return SubmissionModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          // Most recent submission first.
          submissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final item = submissions[index];
              final submitTimeStr = DateFormat(
                'MMM dd, yyyy - hh:mm a',
              ).format(item.submittedAt);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: item.isGraded
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    child: Icon(
                      item.isGraded ? Icons.grading : Icons.hourglass_top,
                      color: item.isGraded ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(
                    "${item.studentName} (${item.roll})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Submitted: $submitTimeStr"),
                      if (item.isGraded)
                        Text(
                          "Grade: ${item.grade}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        const Text(
                          "Not graded yet",
                          style: TextStyle(color: Colors.orange),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'view') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubmissionDetailScreen(
                              submission: item,
                              assignmentTitle: assignmentTitle,
                            ),
                          ),
                        );
                      } else if (val == 'delete') {
                        AdminAssignmentService.deleteSubmission(item.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, color: Colors.blue),
                            SizedBox(width: 8),
                            Text("View Details"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Delete"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmissionDetailScreen(
                          submission: item,
                          assignmentTitle: assignmentTitle,
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
