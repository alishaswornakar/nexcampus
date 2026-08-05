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
class AdminSubmissionsListScreen extends StatefulWidget {
  final String assignmentId;
  final String assignmentTitle;

  const AdminSubmissionsListScreen({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
  });

  @override
  State<AdminSubmissionsListScreen> createState() => _AdminSubmissionsListScreenState();
}

class _AdminSubmissionsListScreenState extends State<AdminSubmissionsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Submissions · ${widget.assignmentTitle}",
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: AdminAssignmentService.getSubmissionsForAssignment(widget.assignmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 72, color: Colors.grey[300]),
                      const SizedBox(height: 18),
                      Text(
                        "No submissions yet",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Students will appear here once they submit the assignment.",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Refresh"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B52D4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: item.isGraded ? Colors.green.shade50 : Colors.orange.shade50,
                    child: Icon(
                      item.isGraded ? Icons.grading : Icons.hourglass_top,
                      color: item.isGraded ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${item.studentName} (${item.roll})",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (item.isGraded)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.grade,
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Submitted: $submitTimeStr"),
                      const SizedBox(height: 6),
                      Text(
                        item.isGraded ? "Graded" : "Not graded yet",
                        style: TextStyle(color: item.isGraded ? Colors.green : Colors.orange),
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
                              assignmentTitle: widget.assignmentTitle,
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
                          assignmentTitle: widget.assignmentTitle,
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
