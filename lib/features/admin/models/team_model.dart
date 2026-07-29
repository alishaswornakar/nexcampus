import 'package:cloud_firestore/cloud_firestore.dart';

class TeamModel {
  final String id;
  final String title;
  final String description;
  final String projectType;
  final String department;
  final String semester;
  final String section;
  final String leaderName;
  final String status;
  final String? rejectReason;
  final int totalSlots;
  final int filledSlots;
  final DateTime createdAt;

  TeamModel({
    required this.id,
    required this.title,
    required this.description,
    required this.projectType,
    required this.department,
    required this.semester,
    required this.section,
    required this.leaderName,
    this.status = 'Pending',
    this.rejectReason,
    this.totalSlots = 4,
    this.filledSlots = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectType': projectType,
      'department': department,
      'semester': semester,
      'section': section,
      'leaderName': leaderName,
      'status': status,
      'rejectReason': rejectReason,
      'totalSlots': totalSlots,
      'filledSlots': filledSlots,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TeamModel.fromMap(Map<String, dynamic> map, String docId) {
    return TeamModel(
      id: docId,
      title: map['title'] ?? map['projectName'] ?? '',
      description: map['description'] ?? '',
      projectType: map['projectType'] ?? 'Major Project',
      department: map['department'] ?? 'Computer',
      semester: map['semester'] ?? 'Sem 1',
      section: map['section'] ?? 'Section A',
      leaderName: map['leaderName'] ?? '',
      status: map['status'] ?? 'Pending',
      rejectReason: map['rejectReason'],
      totalSlots: map['totalSlots'] ?? 4,
      filledSlots: map['filledSlots'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
