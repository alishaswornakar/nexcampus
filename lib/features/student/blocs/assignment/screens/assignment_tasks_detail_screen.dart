import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../../../../teachers/teachers_features/assignments/models/assignment_submission_model.dart';
import '../../../../teachers/teachers_features/assignments/repository/assignment_submission_repository.dart';
import '../../../../teachers/teachers_features/assignments/services/assignment_submission_service.dart';
import '../../../../teachers/teachers_features/assignments/services/cloudinary_service.dart';
import '../models/assignment_model.dart';
import '../widgets/assignment_status_chip.dart';
import '../../../screens/pdf_viewer_screen.dart';

/// Full detail view for a single student assignment.
///
/// - Shows assignment info + teacher-attached PDF (if any).
/// - If [StudentAssignmentModel.canSubmit] is true (pending/overdue),
///   shows a submission form: pick a PDF via [CloudinaryService], add
///   optional remarks, and submit.
/// - If already submitted, shows the submission (locked from editing).
/// - If graded, shows grade + feedback in addition to the submission.
///
/// NOTE: This screen writes directly through
/// [AssignmentSubmissionRepository] rather than dispatching a bloc event,
/// because the parent [TasksScreen]'s `AssignmentBloc` is scoped locally
/// and is not guaranteed to be an ancestor of this pushed route. The
/// existing live Firestore streams in the bloc (via `WatchAssignments`)
/// will automatically reflect the new submission once written.
///
/// [studentName] and [roll] are treated as a fallback only. Before writing
/// a submission, this screen looks up the signed-in user's `users/{uid}`
/// document (the same pattern used by the teacher-side
/// `SubmitAssignmentScreen`) and prefers `fullName`/`roll` from there, so
/// the teacher's grading screens always see a real name instead of a
/// blank one.
class AssignmentTasksDetailScreen extends StatefulWidget {
  const AssignmentTasksDetailScreen({
    super.key,
    required this.assignment,
    required this.studentId,
    this.studentName = '',
    this.roll = '',
  });

  final StudentAssignmentModel assignment;
  final String studentId;
  final String studentName;
  final String roll;

  @override
  State<AssignmentTasksDetailScreen> createState() =>
      _AssignmentTasksDetailScreenState();
}

class _AssignmentTasksDetailScreenState
    extends State<AssignmentTasksDetailScreen> {
  final AssignmentSubmissionRepository _repository =
      AssignmentSubmissionRepository(AssignmentSubmissionService());

  final TextEditingController _remarksController = TextEditingController();

  Map<String, dynamic>? _pickedFile;
  bool _uploading = false;
  bool _submitting = false;

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    return '$day $month ${date.year}';
  }

  void openPdf(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(pdfUrl: url, title: title),
      ),
    );
  }

  Future<void> _pickPdf() async {
    setState(() => _uploading = true);
    try {
      // Let user pick a PDF file
      final pickResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
      );

      if (pickResult == null || pickResult.files.isEmpty) return;

      final path = pickResult.files.first.path;
      if (path == null) return;

      final file = File(path);

      final cloudinary = CloudinaryService();
      final result = await cloudinary.uploadFile(file);

      // ignore: unnecessary_null_comparison
      if (result != null) {
        setState(() => _pickedFile = result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _submit() async {
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach a PDF before submitting.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      // Look up the signed-in student's profile so the submission carries
      // a real name/roll number. Falls back to whatever was passed into
      // this widget if the profile can't be read for any reason, so a
      // Firestore hiccup never blocks the submission itself.
      String studentName = widget.studentName;
      String roll = widget.roll;

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

          final userData = userDoc.data();
          if (userData != null) {
            studentName =
                (userData['fullName'] as String?)?.trim().isNotEmpty == true
                ? userData['fullName'] as String
                : studentName;
            roll = (userData['roll'] as String?)?.trim().isNotEmpty == true
                ? userData['roll'] as String
                : roll;
          }
        } catch (_) {
          // Ignore lookup failures and fall back to the widget-provided
          // values below.
        }
      }

      final submission = AssignmentSubmissionModel(
        id: '${widget.assignment.id}_${widget.studentId}',
        assignmentId: widget.assignment.id,
        studentId: widget.studentId,
        studentName: studentName,
        roll: roll,
        department: widget.assignment.department,
        semester: widget.assignment.semester,
        pdfUrl: _pickedFile!['url'] as String,
        title: _pickedFile!['name'] as String,
        remarks: _remarksController.text.trim(),
        submittedAt: DateTime.now(),
      );

      await _repository.submitAssignment(submission);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment submitted successfully.')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final assignment = widget.assignment;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assignment Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppTheme.secondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AssignmentStatusChip(status: assignment.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${assignment.subject} · ${assignment.teacherName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${assignment.department} · Semester ${assignment.semester}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: assignment.isOverdue
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Due ${_formatDate(assignment.dueDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: assignment.isOverdue
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                    fontWeight: assignment.isOverdue
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Description',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(assignment.description, style: theme.textTheme.bodyMedium),
            if (assignment.hasAssignmentPdf) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => openPdf(
                  assignment.assignmentPdfUrl!,
                  assignment.assignmentPdfName ?? "Assignment PDF",
                ),
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: Text(
                  assignment.assignmentPdfName ?? 'View Assignment PDF',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            if (assignment.isGraded) _buildGradedSection(theme, colorScheme),
            if (assignment.isSubmitted && !assignment.isGraded)
              _buildSubmittedSection(theme, colorScheme),
            if (assignment.canSubmit) _buildSubmissionForm(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildGradedSection(ThemeData theme, ColorScheme colorScheme) {
    final assignment = widget.assignment;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grade',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.grade_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    assignment.grade,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (assignment.feedback.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(assignment.feedback, style: theme.textTheme.bodyMedium),
              ],
              if (assignment.gradedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Graded on ${_formatDate(assignment.gradedAt!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSubmittedSection(theme, colorScheme, heading: 'Your Submission'),
      ],
    );
  }

  Widget _buildSubmittedSection(
    ThemeData theme,
    ColorScheme colorScheme, {
    String heading = 'Submission',
  }) {
    final assignment = widget.assignment;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),

        if (assignment.hasSubmissionPdf)
          OutlinedButton.icon(
            onPressed: () => openPdf(
              assignment.submissionPdfUrl!,
              assignment.submissionPdfName ?? "Submitted PDF",
            ),
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: Text(
              assignment.submissionPdfName ?? 'View Submitted PDF',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (assignment.remarks.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Remarks', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(assignment.remarks, style: theme.textTheme.bodyMedium),
        ],
        if (assignment.submittedAt != null) ...[
          const SizedBox(height: 10),
          Text(
            'Submitted on ${_formatDate(assignment.submittedAt!)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmissionForm(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Submit Your Work',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _remarksController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Remarks (optional)',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _uploading ? null : _pickPdf,
          icon: _uploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file_rounded),
          label: Text(
            _pickedFile == null ? 'Attach PDF' : _pickedFile!['name'] as String,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Submit Assignment'),
          ),
        ),
      ],
    );
  }
}
