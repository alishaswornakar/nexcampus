import 'package:flutter/foundation.dart';

import '../../../../teachers/teachers_features/assignments/models/assignment_model.dart';
import '../../../../teachers/teachers_features/assignments/models/assignment_submission_model.dart';

/// Status shown in the Student Assignment module.
enum StudentAssignmentStatus { pending, overdue, submitted, graded }

///
/// Wrapper model used only by the Student module.
///
/// It combines:
/// - Teacher AssignmentModel
/// - Student AssignmentSubmissionModel
///
/// No additional Firestore collection is created.
///
@immutable
class StudentAssignmentModel {
  final AssignmentModel assignment;

  /// Student submission.
  /// Null means the assignment hasn't been submitted yet.
  final AssignmentSubmissionModel? submission;

  /// Derived UI status.
  final StudentAssignmentStatus status;

  const StudentAssignmentModel({
    required this.assignment,
    required this.submission,
    required this.status,
  });

  factory StudentAssignmentModel.fromAssignment({
    required AssignmentModel assignment,
    AssignmentSubmissionModel? submission,
  }) {
    final now = DateTime.now();

    StudentAssignmentStatus status;

    if (submission == null) {
      status = assignment.dueDate.isBefore(now)
          ? StudentAssignmentStatus.overdue
          : StudentAssignmentStatus.pending;
    } else {
      status = submission.gradedAt != null
          ? StudentAssignmentStatus.graded
          : StudentAssignmentStatus.submitted;
    }

    return StudentAssignmentModel(
      assignment: assignment,
      submission: submission,
      status: status,
    );
  }

  // ---------------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------------

  bool get isPending => status == StudentAssignmentStatus.pending;

  bool get isOverdue => status == StudentAssignmentStatus.overdue;

  bool get isSubmitted => status == StudentAssignmentStatus.submitted;

  bool get isGraded => status == StudentAssignmentStatus.graded;

  bool get canSubmit => isPending || isOverdue;

  // ---------------------------------------------------------------------------
  // Assignment Information
  // ---------------------------------------------------------------------------

  String get id => assignment.id;

  String get title => assignment.title;

  String get description => assignment.description;

  String get subject => assignment.subject;

  String get department => assignment.department;

  String get semester => assignment.semester;

  String get teacherName => assignment.teacherName;

  DateTime get dueDate => assignment.dueDate;

  DateTime get createdAt => assignment.createdAt;

  // ---------------------------------------------------------------------------
  // Assignment PDF
  // ---------------------------------------------------------------------------

  bool get hasAssignmentPdf =>
      assignment.pdfUrl != null && assignment.pdfUrl!.isNotEmpty;

  String? get assignmentPdfUrl => assignment.pdfUrl;

  String? get assignmentPdfName => assignment.pdfName;

  // ---------------------------------------------------------------------------
  // Submission PDF
  // ---------------------------------------------------------------------------

  bool get hasSubmissionPdf =>
      submission != null && submission!.pdfUrl.isNotEmpty;

  String? get submissionPdfUrl => submission?.pdfUrl;

  String? get submissionPdfName => submission?.pdfName;

  // ---------------------------------------------------------------------------
  // Submission Details
  // ---------------------------------------------------------------------------

  String get remarks => submission?.remarks ?? "";

  DateTime? get submittedAt => submission?.submittedAt;

  // ---------------------------------------------------------------------------
  // Grade
  // ---------------------------------------------------------------------------

  String get grade => submission?.grade ?? "";

  String get feedback => submission?.feedback ?? "";

  String get reviewStatus => submission?.status ?? "";

  DateTime? get gradedAt => submission?.gradedAt;

  // ---------------------------------------------------------------------------
  // Time Helpers
  // ---------------------------------------------------------------------------

  bool get isDueToday {
    final now = DateTime.now();

    return assignment.dueDate.year == now.year &&
        assignment.dueDate.month == now.month &&
        assignment.dueDate.day == now.day;
  }

  bool get isExpired => assignment.dueDate.isBefore(DateTime.now());

  Duration get remainingTime => assignment.dueDate.difference(DateTime.now());

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  String get statusText {
    switch (status) {
      case StudentAssignmentStatus.pending:
        return "Pending";

      case StudentAssignmentStatus.overdue:
        return "Overdue";

      case StudentAssignmentStatus.submitted:
        return "Submitted";

      case StudentAssignmentStatus.graded:
        return "Graded";
    }
  }

  StudentAssignmentModel copyWith({
    AssignmentModel? assignment,
    AssignmentSubmissionModel? submission,
    StudentAssignmentStatus? status,
  }) {
    return StudentAssignmentModel(
      assignment: assignment ?? this.assignment,
      submission: submission ?? this.submission,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StudentAssignmentModel &&
            assignment.id == other.assignment.id &&
            submission?.id == other.submission?.id &&
            status == other.status;
  }

  @override
  int get hashCode => Object.hash(assignment.id, submission?.id, status);

  @override
  String toString() {
    return 'StudentAssignmentModel('
        'id: ${assignment.id}, '
        'title: ${assignment.title}, '
        'status: $status'
        ')';
  }
}
