import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String department;
  final String semester;
  final String section;
  final String teacherName;
  final DateTime createdDate;
  final DateTime deadline;
  final String? fileUrl;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.semester,
    required this.section,
    required this.teacherName,
    required this.createdDate,
    required this.deadline,
    this.fileUrl,
  });

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String docId) {
    return AssignmentModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      section: map['section'] ?? '',
      teacherName: map['teacherName'] ?? 'Unknown Teacher',
      createdDate: (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deadline: (map['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fileUrl: map['fileUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'department': department,
      'semester': semester,
      'section': section,
      'teacherName': teacherName,
      'createdDate': Timestamp.fromDate(createdDate),
      'deadline': Timestamp.fromDate(deadline),
      'fileUrl': fileUrl,
    };
  }
}