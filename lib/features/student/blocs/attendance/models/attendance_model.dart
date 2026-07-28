import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents one student's attendance entry within a single class session
/// document (the session doc holds a `students` array for the whole class).
class AttendanceModel extends Equatable {
  final String id; // session document id
  final DateTime date;
  final DateTime createdAt;
  final String department;
  final String semester;
  final String uid;
  final String fullName;
  final String roll;
  final String photoUrl;
  final bool isPresent;

  const AttendanceModel({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.department,
    required this.semester,
    required this.uid,
    required this.fullName,
    required this.roll,
    required this.photoUrl,
    required this.isPresent,
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

    return AttendanceModel(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      department: data['department'] ?? '',
      semester: data['semester'] ?? '',
      uid: studentMap['uid'] ?? '',
      fullName: studentMap['fullName'] ?? '',
      roll: studentMap['roll'] ?? '',
      photoUrl: studentMap['photoUrl'] ?? '',
      isPresent: studentMap['isPresent'] ?? false,
    );
  }

  AttendanceModel copyWith({
    String? id,
    DateTime? date,
    DateTime? createdAt,
    String? department,
    String? semester,
    String? uid,
    String? fullName,
    String? roll,
    String? photoUrl,
    bool? isPresent,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      roll: roll ?? this.roll,
      photoUrl: photoUrl ?? this.photoUrl,
      isPresent: isPresent ?? this.isPresent,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    createdAt,
    department,
    semester,
    uid,
    fullName,
    roll,
    photoUrl,
    isPresent,
  ];
}
