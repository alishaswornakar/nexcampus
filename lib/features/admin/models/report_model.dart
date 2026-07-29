import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String studentId;
  final String studentName;
  final String title;
  final String description;
  final String status; // 'Pending', 'In Progress', 'Resolved', 'Rejected'
  final String adminFeedback;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.title,
    required this.description,
    required this.status,
    required this.adminFeedback,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'title': title,
      'description': description,
      'status': status,
      'adminFeedback': adminFeedback,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReportModel(
      id: docId,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Pending',
      adminFeedback: map['adminFeedback'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}