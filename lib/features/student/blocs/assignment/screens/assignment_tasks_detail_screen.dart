import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../teachers/teachers_features/assignments/models/assignment_submission_model.dart';
import '../../../../teachers/teachers_features/assignments/repository/assignment_submission_repository.dart';
import '../../../../teachers/teachers_features/assignments/services/assignment_submission_service.dart';
import '../../../../teachers/teachers_features/assignments/services/cloudinary_service.dart';
import '../models/assignment_model.dart';
import '../widgets/assignment_status_chip.dart';

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
class AssignmentTasksDetailScreen extends StatefulWidget {
  const AssignmentTasksDetailScreen({
    super.key,
    required this.assignment,
    required this.studentId,
    required this.studentName,
    required this.roll,
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

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the file.')));
    }
  }

  Future<void> _pickPdf() async {
    setState(() => _uploading = true);
    try {
      final result = await CloudinaryService().uploadPdf();
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
      final submission = AssignmentSubmissionModel(
        id: '${widget.assignment.id}_${widget.studentId}',
        assignmentId: widget.assignment.id,
        studentId: widget.studentId,
        studentName: widget.studentName,
        roll: widget.roll,
        department: widget.assignment.department,
        semester: widget.assignment.semester,
        pdfUrl: _pickedFile!['url'] as String,
        pdfName: _pickedFile!['name'] as String,
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
      appBar: AppBar(title: const Text('Assignment Details')),
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
                onPressed: () => _openUrl(assignment.assignmentPdfUrl!),
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
            onPressed: () => _openUrl(assignment.submissionPdfUrl!),
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
