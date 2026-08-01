// lib/features/admin/team_finder/models/team_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors `TeamPostStatus` from the student-side team finder
/// (lib/features/student/blocs/team_finder/models/team_post_model.dart).
/// Kept as a local copy so the admin feature doesn't have to depend on the
/// student feature module, but the string values MUST stay in sync since
/// both sides read/write the same `team_posts` documents.
class TeamPostStatus {
  static const String open = 'open';
  static const String closed = 'closed';
}

/// Admin-side representation of a student's team-finder post.
///
/// This now maps 1:1 onto the `team_posts` collection written by
/// `TeamFinderFirestoreService` on the student side. Field names, the
/// collection name, and the status values ('open' / 'closed') all match the
/// student schema exactly so admin actions operate on the real documents
/// students see, instead of a separate/incompatible `project_teams` shape.
class TeamModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String rollNumber;
  final String department;
  final String semester;
  final String title;
  final String description;
  final String projectType;
  final List<String> skillsNeeded;
  final int slotsTotal;
  final int slotsFilled;
  final String status; // TeamPostStatus.open | TeamPostStatus.closed
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TeamModel({
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
  bool get isOpen => status == TeamPostStatus.open;

  factory TeamModel.fromMap(Map<String, dynamic> map, String docId) {
    return TeamModel(
      id: docId,
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

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

/// Lightweight, read-only view of a `team_applications` document, used by
/// the admin screen to show who applied to a given post without pulling in
/// the full student-side `TeamApplicationModel`.
class TeamApplicationSummary {
  final String id;
  final String applicantName;
  final String applicantEmail;
  final String rollNumber;
  final String status; // pending | accepted | rejected | withdrawn
  final DateTime createdAt;

  const TeamApplicationSummary({
    required this.id,
    required this.applicantName,
    required this.applicantEmail,
    required this.rollNumber,
    required this.status,
    required this.createdAt,
  });

  factory TeamApplicationSummary.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return TeamApplicationSummary(
      id: docId,
      applicantName: map['applicantName'] as String? ?? '',
      applicantEmail: map['applicantEmail'] as String? ?? '',
      rollNumber: map['rollNumber'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: TeamModel._asDateTime(map['createdAt']) ?? DateTime.now(),
    );
  }
}
