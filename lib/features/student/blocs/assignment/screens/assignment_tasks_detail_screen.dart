// assignment/screens/assignment_tasks_detail_screen.dart
import 'package:flutter/material.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../models/assignment_model.dart';
import '../../../screens/pdf_viewer_screen.dart';
import 'submit_assignment_screen.dart';

/// Detail view for a single student assignment, matching the Figma
/// "Assignment Details" screen: one rounded card (title, instructor,
/// due date, description, reference file, instructor row) followed by
/// either a "Submit Assignment" button, the student's own submission,
/// or the grade + submission.
class AssignmentTasksDetailScreen extends StatelessWidget {
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

  static const Color _accent = Color(0xFF4C4FE0);
  static const Color _cardBg = Color(0xFFEEF0FB);

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

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${_months[date.month - 1]} ${date.year}';

  static String _formatTime(DateTime date) {
    final hour24 = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:$minute $period';
  }

  void _openPdf(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(pdfUrl: url, title: title),
      ),
    );
  }

  void _openSubmitScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubmitAssignmentScreen(
          assignment: assignment,
          studentId: studentId,
          studentName: studentName,
          roll: roll,
        ),
      ),
    );
  }

  void _messageInstructor(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Messaging is coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmall = width < 360;
    final bool isTablet = width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: AppBar(
        title: const Text(
          'Assignment Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppTheme.primary,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 640 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmall ? 14 : 18),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmall ? 16 : 22),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: TextStyle(
                        fontSize: isSmall ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF14142B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      assignment.teacherName,
                      style: TextStyle(
                        fontSize: isSmall ? 13 : 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Due ${_formatDate(assignment.dueDate)}, '
                            '${_formatTime(assignment.dueDate)}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isSmall ? 12.5 : 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade300, height: 1),
                    const SizedBox(height: 16),
                    Text(
                      assignment.description,
                      style: TextStyle(
                        fontSize: isSmall ? 13.5 : 14.5,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    if (assignment.hasAssignmentPdf) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'REFERENCE MATERIALS',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '1 file',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _FileRow(
                        fileName:
                            assignment.assignmentPdfName ?? 'Assignment.pdf',
                        onTap: () => _openPdf(
                          context,
                          assignment.assignmentPdfUrl!,
                          assignment.assignmentPdfName ?? 'Assignment PDF',
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey.shade300, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: isSmall ? 20 : 22,
                          backgroundColor: _accent.withValues(alpha: 0.15),
                          child: Text(
                            assignment.teacherName.isNotEmpty
                                ? assignment.teacherName[0].toUpperCase()
                                : 'T',
                            style: const TextStyle(
                              color: _accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                assignment.teacherName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isSmall ? 13 : 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Course Instructor',
                                style: TextStyle(
                                  fontSize: isSmall ? 11 : 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _messageInstructor(context),
                          icon: const Icon(
                            Icons.mail_outline_rounded,
                            size: 17,
                          ),
                          label: const Text('Message'),
                          style: TextButton.styleFrom(foregroundColor: _accent),
                        ),
                      ],
                    ),
                    if (assignment.isGraded) ...[
                      const SizedBox(height: 20),
                      _GradeSection(assignment: assignment),
                      const SizedBox(height: 14),
                      _SubmissionSection(
                        assignment: assignment,
                        onOpenPdf: (url, title) =>
                            _openPdf(context, url, title),
                      ),
                    ] else if (assignment.isSubmitted) ...[
                      const SizedBox(height: 20),
                      _SubmissionSection(
                        assignment: assignment,
                        onOpenPdf: (url, title) =>
                            _openPdf(context, url, title),
                      ),
                    ],
                    if (assignment.canSubmit) ...[
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: isSmall ? 50 : 56,
                        child: ElevatedButton(
                          onPressed: () => _openSubmitScreen(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Submit Assignment',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.fileName, required this.onTap});

  final String fileName;
  final VoidCallback onTap;

  bool get _isPdf => fileName.toLowerCase().endsWith('.pdf');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _isPdf ? Colors.red.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isPdf
                    ? Icons.picture_as_pdf_rounded
                    : Icons.insert_drive_file_rounded,
                color: _isPdf ? Colors.red.shade400 : Colors.blue.shade400,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
            Icon(Icons.download_rounded, size: 19, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}

class _GradeSection extends StatelessWidget {
  const _GradeSection({required this.assignment});

  final StudentAssignmentModel assignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.grade_rounded,
                color: Color(0xFF1E8E4F),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Grade: ${assignment.grade}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E8E4F),
                ),
              ),
            ],
          ),
          if (assignment.feedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              assignment.feedback,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubmissionSection extends StatelessWidget {
  const _SubmissionSection({required this.assignment, required this.onOpenPdf});

  final StudentAssignmentModel assignment;
  final void Function(String url, String title) onOpenPdf;

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

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${_months[date.month - 1]} ${date.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (assignment.hasSubmissionPdf)
          _FileRow(
            fileName: assignment.submissionPdfName ?? 'Your submission',
            onTap: () => onOpenPdf(
              assignment.submissionPdfUrl!,
              assignment.submissionPdfName ?? 'Submitted PDF',
            ),
          ),
        if (assignment.submittedAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Submitted on ${_formatDate(assignment.submittedAt!)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }
}
