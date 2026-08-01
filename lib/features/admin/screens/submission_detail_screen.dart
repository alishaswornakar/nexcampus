import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/submission_model.dart';
import '../services/admin_assignment_service.dart';

/// Full detail view for one student's submission.
///
/// Lets admin open the submitted PDF, read remarks, and optionally
/// grade the submission (grade + feedback), which writes back to the
/// same `assignment_submissions` document the student's app is already
/// listening to (so grades appear live on the student side too).
class SubmissionDetailScreen extends StatefulWidget {
  final SubmissionModel submission;
  final String assignmentTitle;

  const SubmissionDetailScreen({
    super.key,
    required this.submission,
    required this.assignmentTitle,
  });

  @override
  State<SubmissionDetailScreen> createState() => _SubmissionDetailScreenState();
}

class _SubmissionDetailScreenState extends State<SubmissionDetailScreen> {
  late final TextEditingController _gradeController;
  late final TextEditingController _feedbackController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _gradeController = TextEditingController(text: widget.submission.grade);
    _feedbackController = TextEditingController(text: widget.submission.feedback);
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open the PDF.")));
    }
  }

  Future<void> _saveGrade() async {
    if (_gradeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a grade first.")));
      return;
    }

    setState(() => _saving = true);
    try {
      await AdminAssignmentService.gradeSubmission(
        widget.submission.id,
        grade: _gradeController.text.trim(),
        feedback: _feedbackController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Grade saved."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final submission = widget.submission;
    final submitTimeStr = DateFormat(
      'MMM dd, yyyy - hh:mm a',
    ).format(submission.submittedAt);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        title: const Text(
          "Submission Details",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              await AdminAssignmentService.deleteSubmission(submission.id);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${submission.studentName} (${submission.roll})",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Assignment: ${widget.assignmentTitle}"),
                    const SizedBox(height: 4),
                    Text(
                      "Dept: ${submission.department} | Sem: ${submission.semester}",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Submitted: $submitTimeStr",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (submission.pdfUrl.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openPdf(submission.pdfUrl),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(
                    submission.pdfName.isNotEmpty
                        ? submission.pdfName
                        : "View Submitted PDF",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            if (submission.remarks.isNotEmpty) ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Student Remarks",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Text(submission.remarks),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Grade Submission",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _gradeController,
                      decoration: const InputDecoration(
                        labelText: "Grade (e.g. A, 8/10)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Feedback (optional)",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveGrade,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Save Grade"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
