// lib/features/student/blocs/team_finder/models/team_post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamPostStatus {
  static const String open = 'open';
  static const String closed = 'closed';
}

class TeamPostModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String rollNumber;
  final String department;
  final String semester;
  final String title;
  final String description;
  final String
  projectType; // Minor Project, Major Project, Hackathon, Personal Project
  final List<String> skillsNeeded;
  final int slotsTotal;
  final int slotsFilled;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TeamPostModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
    required this.title,
    required this.description,
    required this.projectType,
    required this.skillsNeeded,
    required this.slotsTotal,
    required this.slotsFilled,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  int get slotsRemaining => (slotsTotal - slotsFilled).clamp(0, slotsTotal);
  bool get isOpen => status == TeamPostStatus.open && slotsRemaining > 0;

  factory TeamPostModel.fromMap(Map<String, dynamic> map) {
    return TeamPostModel(
      id: map['id'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      ownerEmail: map['ownerEmail'] as String? ?? '',
      rollNumber: map['rollNumber'] as String? ?? '',
      department: map['department'] as String? ?? '',
      semester: map['semester'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      projectType: map['projectType'] as String? ?? '',
      skillsNeeded: (map['skillsNeeded'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      slotsTotal: (map['slotsTotal'] as num?)?.toInt() ?? 1,
      slotsFilled: (map['slotsFilled'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? TeamPostStatus.open,
      createdAt: _asDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _asDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'rollNumber': rollNumber,
      'department': department,
      'semester': semester,
      'title': title,
      'description': description,
      'projectType': projectType,
      'skillsNeeded': skillsNeeded,
      'slotsTotal': slotsTotal,
      'slotsFilled': slotsFilled,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
