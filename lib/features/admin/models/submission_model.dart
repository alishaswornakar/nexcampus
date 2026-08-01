import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the document shape written by the STUDENT module's
/// `AssignmentSubmissionModel` (features/teachers/teachers_features/
/// assignments/models/assignment_submission_model.dart) into the
/// `assignment_submissions` Firestore collection.
///
/// IMPORTANT: field names here must match what the student side actually
/// writes (`roll`, not `studentRoll`; there is no stored `assignmentTitle`
/// — that has to be joined against the `assignments` collection using
/// [assignmentId]). Keeping this in sync with the student model is what
/// lets the admin panel read real submissions instead of silently
/// matching nothing.
class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final String roll;
  final String department;
  final String semester;
  final String pdfUrl;
  final String pdfName;
  final String remarks;
  final DateTime submittedAt;

  // Populated later by the teacher-grading flow; optional/blank until then.
  final String grade;
  final String feedback;
  final String status;
  final DateTime? gradedAt;

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.roll,
    required this.department,
    required this.semester,
    required this.pdfUrl,
    required this.pdfName,
    required this.remarks,
    required this.submittedAt,
    this.grade = '',
    this.feedback = '',
    this.status = '',
    this.gradedAt,
  });

  bool get isGraded => grade.isNotEmpty || gradedAt != null;

  factory SubmissionModel.fromMap(Map<String, dynamic> map, String docId) {
    return SubmissionModel(
      id: docId,
      assignmentId: map['assignmentId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? 'Unknown Student',
      roll: map['roll'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      pdfName: map['pdfName'] ?? '',
      remarks: map['remarks'] ?? '',
      submittedAt:
          (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      grade: map['grade'] ?? '',
      feedback: map['feedback'] ?? '',
      status: map['status'] ?? '',
      gradedAt: (map['gradedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'roll': roll,
      'department': department,
      'semester': semester,
      'pdfUrl': pdfUrl,
      'pdfName': pdfName,
      'remarks': remarks,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'grade': grade,
      'feedback': feedback,
      'status': status,
      'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
    };
  }
}
