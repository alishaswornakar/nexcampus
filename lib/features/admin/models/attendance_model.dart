import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/foundation.dart';

/// Represents ONE student's entry, flattened out of a class-session
/// document for admin viewing purposes.
///
/// IMPORTANT: This mirrors the real Firestore schema used by the
/// student/teacher side (see `attendance` collection):
///   attendance/{sessionId} {
///     date: Timestamp,
///     createdAt: Timestamp,
///     department: String,
///     semester: String,
///     subjectId: String,
///     subjectName: String,
///     teacherId: String,
///     students: [ { uid, fullName, roll, photoUrl, isPresent }, ... ]
///   }
///
/// `subjectId` / `subjectName` ARE written by the teacher side (see
/// AttendanceModel.toMap() in the teacher module) — they were simply
/// never read here before. There is still no `section`, `studentId`,
/// `studentName`, `studentRoll`, or `status` field anywhere in the
/// real data — those were placeholders from before this was wired up.
/// Do not reintroduce them.
class AttendanceModel {
  final String id; // session document id
  final DateTime date;
  final DateTime createdAt;
  final String department;
  final String semester;
  final String subjectId;
  final String subjectName;
  final String uid;
  final String fullName;
  final String roll;
  final String photoUrl;
  final bool isPresent;

  AttendanceModel({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.department,
    required this.semester,
    required this.subjectId,
    required this.subjectName,
    required this.uid,
    required this.fullName,
    required this.roll,
    required this.photoUrl,
    required this.isPresent,
  });

  /// Derived label, same convention as the student-side model.
  String get status => isPresent ? 'Present' : 'Absent';

  /// Flattens a single session document into one [AttendanceModel] per
  /// student in its `students` array. Admin needs to see every student in
  /// the session, unlike the student-side `fromSessionDoc` which only
  /// pulls out a single uid.
  static List<AttendanceModel> fromSessionDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) return [];

    final date = (data['date'] as Timestamp?)?.toDate();
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    if (date == null) return [];

    final department = data['department'] ?? '';
    final semester = data['semester'] ?? '';
    final subjectId = data['subjectId'] ?? '';
    final subjectName = data['subjectName'] ?? '';

    final students = ((data['students'] as List<dynamic>?) ?? [])
        .map((s) => Map<String, dynamic>.from(s as Map))
        .toList();

    return students.map((s) {
      return AttendanceModel(
        id: doc.id,
        date: date,
        createdAt: createdAt ?? date,
        department: department,
        semester: semester,
        subjectId: subjectId,
        subjectName: subjectName,
        uid: s['uid'] ?? '',
        fullName: s['fullName'] ?? 'Unknown',
        roll: s['roll'] ?? '',
        photoUrl: s['photoUrl'] ?? '',
        isPresent: s['isPresent'] ?? false,
      );
    }).toList();
  }
}
