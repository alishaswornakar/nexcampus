import 'package:cloud_firestore/cloud_firestore.dart';

class CourseFileModel {
  final String id;
  final String title;
  final String subject;
  final String department;
  final String semester;
  final String section;
  final String fileUrl;
  final String uploadedBy;
  final DateTime createdAt;

  CourseFileModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.department,
    required this.semester,
    required this.section,
    required this.fileUrl,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory CourseFileModel.fromMap(Map<String, dynamic> map, String docId) {
    return CourseFileModel(
      id: docId,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      section: map['section'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      uploadedBy: map['uploadedBy'] ?? 'Admin/Teacher',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'department': department,
      'semester': semester,
      'section': section,
      'fileUrl': fileUrl,
      'uploadedBy': uploadedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}