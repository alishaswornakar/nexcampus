import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionModel {
  final String id;
  final String assignmentId;
  final String assignmentTitle;
  final String studentName;
  final String studentRoll;
  final String department;
  final String semester;
  final String section;
  final DateTime submittedAt;
  final String? fileUrl;

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.studentName,
    required this.studentRoll,
    required this.department,
    required this.semester,
    required this.section,
    required this.submittedAt,
    this.fileUrl,
  });

  factory SubmissionModel.fromMap(Map<String, dynamic> map, String docId) {
    return SubmissionModel(
      id: docId,
      assignmentId: map['assignmentId'] ?? '',
      assignmentTitle: map['assignmentTitle'] ?? 'Assignment',
      studentName: map['studentName'] ?? 'Unknown Student',
      studentRoll: map['studentRoll'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      section: map['section'] ?? '',
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fileUrl: map['fileUrl'],
    );
  }
}