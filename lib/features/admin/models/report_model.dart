import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String studentId;
  final String studentName;
  final String title;
  final String description;
  final String status; // 'Pending', 'Reviewed', 'Resolved'
  final String adminFeedback;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isAnonymous;
  final String? category;

  ReportModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.title,
    required this.description,
    required this.status,
    required this.adminFeedback,
    required this.createdAt,
    this.updatedAt,
    this.isAnonymous = true,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': isAnonymous ? 'Anonymous' : studentName,
      'title': title,
      'description': description,
      'status': status,
      'adminFeedback': adminFeedback,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isAnonymous': isAnonymous,
      'category': category ?? 'General',
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReportModel(
      id: docId,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? 'Anonymous',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Pending',
      adminFeedback: map['adminFeedback'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      isAnonymous: map['isAnonymous'] ?? true,
      category: map['category'] ?? 'General',
    );
  }

  // Firestore compatibility
  factory ReportModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReportModel(
      id: id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? 'Anonymous',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'Pending',
      adminFeedback: data['adminFeedback'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isAnonymous: data['isAnonymous'] ?? true,
      category: data['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': isAnonymous ? 'Anonymous' : studentName,
      'title': title,
      'description': description,
      'status': status,
      'adminFeedback': adminFeedback,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isAnonymous': isAnonymous,
      'category': category ?? 'General',
    };
  }
}
