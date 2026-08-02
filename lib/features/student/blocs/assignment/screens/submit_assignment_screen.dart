// assignment/screens/submit_assignment_screen.dart  (NEW FILE)
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../../../../teachers/teachers_features/assignments/models/assignment_submission_model.dart';
import '../../../../teachers/teachers_features/assignments/repository/assignment_submission_repository.dart';
import '../../../../teachers/teachers_features/assignments/services/assignment_submission_service.dart';
import '../../../../teachers/teachers_features/assignments/services/cloudinary_service.dart';
import '../models/assignment_model.dart';

/// Dedicated "Submit Assignment" screen matching the Figma upload flow:
/// status card, dashed drop-zone file picker, an optional comment to
/// the teacher, and a full-width submit button. On success shows a
/// confirmation dialog matching the "Assignment Submitted Successfully"
/// frame.
class SubmitAssignmentScreen extends StatefulWidget {
  const SubmitAssignmentScreen({
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
  State<SubmitAssignmentScreen> createState() => _SubmitAssignmentScreenState();
}

class _SubmitAssignmentScreenState extends State<SubmitAssignmentScreen> {
  final AssignmentSubmissionRepository _repository =
      AssignmentSubmissionRepository(AssignmentSubmissionService());
  final TextEditingController _commentsController = TextEditingController();

  static const Color _accent = Color(0xFF4C4FE0);

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

  String _formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime date) {
    final hour24 = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:$minute $period';
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _uploading = true);
    try {
      final pickResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
        withData: false,
      );

      if (pickResult == null || pickResult.files.isEmpty) return;

      final path = pickResult.files.first.path;
      if (path == null) return;

      final file = File(path);
      final cloudinary = CloudinaryService();
      final result = await cloudinary.uploadFile(file);

      if (mounted) setState(() => _pickedFile = result);
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
        const SnackBar(
          content: Text('Please attach a file before submitting.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
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
          // Fall back to widget-provided values.
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
        remarks: _commentsController.text.trim(),
        submittedAt: DateTime.now(),
      );

      await _repository.submitAssignment(submission);

      if (mounted) _showSuccessDialog();
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

  void _showSuccessDialog() {
    // Captured before the dialog opens so "Back to Dashboard" / "View
    // Submission" can pop *through* this screen and the detail screen
    // beneath it, not just close the dialog itself.
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Assignment Submitted\nSuccessfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your work has been safely uploaded and timestamped.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      navigator.popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Dashboard',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      navigator.pop(); // this screen
                      navigator.pop(); // back to the Tasks list
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accent,
                      side: const BorderSide(color: _accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Submission',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;
    final width = MediaQuery.of(context).size.width;
    final bool isSmall = width < 360;
    final bool isTablet = width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: AppBar(
        title: const Text(
          'Submit Assignment',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmall ? 14 : 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF0FB),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                assignment.canSubmit
                                    ? 'IN PROGRESS'
                                    : 'SUBMITTED',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: _accent,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 15,
                                    color: Colors.red.shade300,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Due ${_formatDate(assignment.dueDate)}, '
                                      '${_formatTime(assignment.dueDate)}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isSmall ? 10.5 : 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red.shade300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          assignment.title,
                          style: TextStyle(
                            fontSize: isSmall ? 16 : 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 15,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                assignment.teacherName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmall ? 18 : 24),
                  Text(
                    'Submission Details',
                    style: TextStyle(
                      fontSize: isSmall ? 15 : 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DottedUploadBox(
                    isUploading: _uploading,
                    fileName: _pickedFile?['name'] as String?,
                    onBrowse: _uploading ? null : _pickFile,
                    accent: _accent,
                    compact: isSmall,
                  ),
                  SizedBox(height: isSmall ? 18 : 24),
                  Text(
                    'Comments to Teacher',
                    style: TextStyle(
                      fontSize: isSmall ? 15 : 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add a note about your submission...',
                      filled: true,
                      fillColor: const Color(0xFFEEF0FB),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmall ? 20 : 26),
                  SizedBox(
                    height: isSmall ? 50 : 56,
                    child: ElevatedButton.icon(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        _submitting ? 'Submitting...' : 'Submit Assignment',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashed drop-zone from the Figma "Submission Details" section.
/// Implemented with a small [CustomPainter] instead of a package,
/// since your pubspec doesn't include a dotted-border dependency.
class DottedUploadBox extends StatelessWidget {
  const DottedUploadBox({
    super.key,
    required this.isUploading,
    required this.fileName,
    required this.onBrowse,
    required this.accent,
    required this.compact,
  });

  final bool isUploading;
  final String? fileName;
  final VoidCallback? onBrowse;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: accent.withValues(alpha: 0.5),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: compact ? 22 : 30,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF0FB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: compact ? 44 : 52,
              height: compact ? 44 : 52,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: accent,
                size: compact ? 22 : 26,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: onBrowse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Browse Files',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Supported formats: PDF, DOCX, PPTX (Max 10MB)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (fileName != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;

  static const double _radius = 16;
  static const double _strokeWidth = 1.4;
  static const double _dashWidth = 6;
  static const double _gapWidth = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(_radius),
    );

    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + _dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + _gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
