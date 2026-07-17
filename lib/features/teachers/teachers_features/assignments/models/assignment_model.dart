import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String id;

  final String title;
  final String description;

  final String department;
  final String semester;
  final String subject;

  final String teacherId;
  final String teacherName;

  final DateTime dueDate;
  final DateTime createdAt;

  final String? pdfUrl;
  final String? pdfName;

  final int submissionCount;

  const AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.semester,
    required this.subject,
    required this.teacherId,
    required this.teacherName,
    required this.dueDate,
    required this.createdAt,
    this.pdfUrl,
    this.pdfName,
    this.submissionCount = 0,
  });

  factory AssignmentModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return AssignmentModel(
      id: id,
      title: map["title"] ?? "",
      description: map["description"] ?? "",
      department: map["department"] ?? "",
      semester: map["semester"] ?? "",
      subject: map["subject"] ?? "",
      teacherId: map["teacherId"] ?? "",
      teacherName: map["teacherName"] ?? "",
      dueDate: (map["dueDate"] as Timestamp).toDate(),
      createdAt: (map["createdAt"] as Timestamp).toDate(),
      pdfUrl: map["pdfUrl"],
      pdfName: map["pdfName"],
      submissionCount: map["submissionCount"] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "department": department,
      "semester": semester,
      "subject": subject,
      "teacherId": teacherId,
      "teacherName": teacherName,
      "dueDate": Timestamp.fromDate(dueDate),
      "createdAt": Timestamp.fromDate(createdAt),
      "pdfUrl": pdfUrl,
      "pdfName": pdfName,
      "submissionCount": submissionCount,
    };
  }
}