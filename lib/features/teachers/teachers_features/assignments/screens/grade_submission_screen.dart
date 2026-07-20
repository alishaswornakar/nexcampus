// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/assignment_submission_model.dart';
import '../repository/assignment_submission_repository.dart';
import '../services/assignment_submission_service.dart';

class GradeSubmissionScreen extends StatefulWidget {
  final AssignmentSubmissionModel submission;

  const GradeSubmissionScreen({
    super.key,
    required this.submission,
  });

  @override
  State<GradeSubmissionScreen> createState() =>
      _GradeSubmissionScreenState();
}

class _GradeSubmissionScreenState
    extends State<GradeSubmissionScreen> {

  final repository =
      AssignmentSubmissionRepository(
    AssignmentSubmissionService(),
  );

  late TextEditingController gradeController;
  late TextEditingController feedbackController;

  bool isSaving = false;

  String status = "Reviewed";

  @override
  void initState() {
    super.initState();

    gradeController = TextEditingController(
      text: widget.submission.grade,
    );

    feedbackController =
        TextEditingController(
      text: widget.submission.feedback,
    );

    status = widget.submission.status.isEmpty
        ? "Reviewed"
        : widget.submission.status;
  }

  @override
  void dispose() {
    gradeController.dispose();
    feedbackController.dispose();
    super.dispose();
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xffF5F7FA),

    appBar: AppBar(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      title: const Text("Grade Submission"),
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(
                widget.submission.studentName,
              ),
              subtitle: Text(
                "Roll: ${widget.submission.roll}",
              ),
            ),
          ),

          const SizedBox(height: 15),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: Colors.blue,
              ),
              title: const Text(
                "Submitted On",
              ),
              subtitle: Text(
                DateFormat(
                  "dd MMM yyyy hh:mm a",
                ).format(
                  widget.submission.submittedAt,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Student Remarks",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Text(
              widget.submission.remarks.isEmpty
                  ? "No remarks"
                  : widget.submission.remarks,
            ),
          ),

          const SizedBox(height: 25),
                    const SizedBox(height: 25),

          const Text(
            "Marks",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: gradeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter marks (e.g. 85)",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Teacher Feedback",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: feedbackController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Write feedback...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Status",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: status,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: "Reviewed",
                child: Text("Reviewed"),
              ),
              DropdownMenuItem(
                value: "Needs Revision",
                child: Text("Needs Revision"),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  status = value;
                });
              }
            },
          ),

          const SizedBox(height: 30),
                    SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              icon: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),

              label: Text(
                isSaving
                    ? "Saving..."
                    : "Save Grade",
              ),

              onPressed: isSaving
                  ? null
                  : () async {

                      if (gradeController.text
                          .trim()
                          .isEmpty) {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please enter marks.",
                            ),
                          ),
                        );

                        return;
                      }

                      setState(() {
                        isSaving = true;
                      });

                      try {

                        await repository
                            .gradeSubmission(
                          submissionId:
                              widget.submission.id,
                          grade:
                              gradeController.text.trim(),
                          feedback:
                              feedbackController.text.trim(),
                          status: status,
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            backgroundColor:
                                Colors.green,
                            content: Text(
                              "Submission graded successfully!",
                            ),
                          ),
                        );

                        Navigator.pop(context);

                      } catch (e) {

                        if (!mounted) return;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            backgroundColor:
                                Colors.red,
                            content: Text(
                              e.toString(),
                            ),
                          ),
                        );

                      } finally {

                        if (mounted) {
                          setState(() {
                            isSaving = false;
                          });
                        }
                      }
                    },
            ),
          ),
                  ],
      ),
    ),
  );
}
}