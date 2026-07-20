import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentSubmissionModel {
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

  // NEW
  final String grade;
  final String feedback;
  final String status;
  final DateTime? gradedAt;

  AssignmentSubmissionModel({
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

    this.grade = "",
    this.feedback = "",
    this.status = "Pending",
    this.gradedAt,
  });

  factory AssignmentSubmissionModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return AssignmentSubmissionModel(
      id: id,
      assignmentId: map["assignmentId"] ?? "",

      studentId: map["studentId"] ?? "",
      studentName: map["studentName"] ?? "",
      roll: map["roll"] ?? "",

      department: map["department"] ?? "",
      semester: map["semester"] ?? "",

      pdfUrl: map["pdfUrl"] ?? "",
      pdfName: map["pdfName"] ?? "",

      remarks: map["remarks"] ?? "",

      submittedAt:
          (map["submittedAt"] as Timestamp).toDate(),

      grade: map["grade"] ?? "",
      feedback: map["feedback"] ?? "",
      status: map["status"] ?? "Pending",

      gradedAt: map["gradedAt"] == null
          ? null
          : (map["gradedAt"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "assignmentId": assignmentId,

      "studentId": studentId,
      "studentName": studentName,
      "roll": roll,

      "department": department,
      "semester": semester,

      "pdfUrl": pdfUrl,
      "pdfName": pdfName,

      "remarks": remarks,

      "submittedAt": Timestamp.fromDate(submittedAt),

      "grade": grade,
      "feedback": feedback,
      "status": status,

      "gradedAt": gradedAt == null
          ? null
          : Timestamp.fromDate(gradedAt!),
    };
  }
}