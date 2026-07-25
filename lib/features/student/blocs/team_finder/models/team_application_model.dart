// lib/features/student/blocs/team_finder/models/team_application_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamApplicationStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';
  static const String withdrawn = 'withdrawn';
}

class TeamApplicationModel {
  final String id;
  final String postId;
  final String postTitle;
  final String postOwnerId;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String rollNumber;
  final String department;
  final String semester;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const TeamApplicationModel({
    required this.id,
    required this.postId,
    required this.postTitle,
    required this.postOwnerId,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
    required this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory TeamApplicationModel.fromMap(Map<String, dynamic> map) {
    return TeamApplicationModel(
      id: map['id'] as String? ?? '',
      postId: map['postId'] as String? ?? '',
      postTitle: map['postTitle'] as String? ?? '',
      postOwnerId: map['postOwnerId'] as String? ?? '',
      applicantId: map['applicantId'] as String? ?? '',
      applicantName: map['applicantName'] as String? ?? '',
      applicantEmail: map['applicantEmail'] as String? ?? '',
      rollNumber: map['rollNumber'] as String? ?? '',
      department: map['department'] as String? ?? '',
      semester: map['semester'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: map['status'] as String? ?? TeamApplicationStatus.pending,
      createdAt: _asDateTime(map['createdAt']) ?? DateTime.now(),
      respondedAt: _asDateTime(map['respondedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'postTitle': postTitle,
      'postOwnerId': postOwnerId,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'rollNumber': rollNumber,
      'department': department,
      'semester': semester,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      if (respondedAt != null) 'respondedAt': Timestamp.fromDate(respondedAt!),
    };
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
