import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents one student's attendance entry within a single class session
/// document (the session doc holds a `students` array for the whole class,
/// plus subject-level metadata used for subject-wise grouping).
class AttendanceModel extends Equatable {
  final String id; // session document id
  final DateTime date;
  final DateTime createdAt;
  final String department;
  final String semester;
  final String subjectId;
  final String subjectName;
  final String teacherName;
  final String uid;
  final String fullName;
  final String roll;
  final String photoUrl;
  final bool isPresent;
  final bool isHoliday;

  const AttendanceModel({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.department,
    required this.semester,
    this.subjectId = '',
    this.subjectName = '',
    this.teacherName = '',
    required this.uid,
    required this.fullName,
    required this.roll,
    required this.photoUrl,
    required this.isPresent,
    this.isHoliday = false,
  });

  /// Derived label used everywhere else in the UI (record card, calendar, summary).
  String get status => isPresent ? 'Present' : 'Absent';

  /// Builds this student's entry out of a session doc. Returns null if
  /// [uid] isn't in that session's `students` array.
  static AttendanceModel? fromSessionDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String uid,
  ) {
    final data = doc.data();
    if (data == null) return null;

    final students = ((data['students'] as List<dynamic>?) ?? [])
        .map((s) => Map<String, dynamic>.from(s as Map))
        .toList();

    final studentMap = students.firstWhere(
      (s) => s['uid'] == uid,
      orElse: () => <String, dynamic>{},
    );
    if (studentMap.isEmpty) return null;

    // Safe handling for date field to prevent type cast crashes if null
    DateTime parsedDate;
    final rawDate = data['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    // Safe handling for createdAt field to prevent type cast crashes if null
    DateTime parsedCreatedAt;
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return AttendanceModel(
      id: doc.id,
      date: parsedDate,
      createdAt: parsedCreatedAt,
      department: data['department'] ?? '',
      semester: data['semester']?.toString() ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      teacherName: data['teacherName'] ?? '',
      uid: studentMap['uid'] ?? '',
      fullName: studentMap['fullName'] ?? '',
      roll: studentMap['roll'] ?? '',
      photoUrl: studentMap['photoUrl'] ?? '',
      isPresent: studentMap['isPresent'] ?? false,
      isHoliday: data['isHoliday'] ?? false,
    );
  }

  AttendanceModel copyWith({
    String? id,
    DateTime? date,
    DateTime? createdAt,
    String? department,
    String? semester,
    String? subjectId,
    String? subjectName,
    String? teacherName,
    String? uid,
    String? fullName,
    String? roll,
    String? photoUrl,
    bool? isPresent,
    bool? isHoliday,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      teacherName: teacherName ?? this.teacherName,
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      roll: roll ?? this.roll,
      photoUrl: photoUrl ?? this.photoUrl,
      isPresent: isPresent ?? this.isPresent,
      isHoliday: isHoliday ?? this.isHoliday,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    createdAt,
    department,
    semester,
    subjectId,
    subjectName,
    teacherName,
    uid,
    fullName,
    roll,
    photoUrl,
    isPresent,
    isHoliday,
  ];
}
