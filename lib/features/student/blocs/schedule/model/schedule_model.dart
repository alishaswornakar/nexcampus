// lib/features/student/blocs/schedule/model/schedule_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Read-side mirror of the teacher's ScheduleModel
/// (features/teachers/teachers_features/schedule/model/schedule_model.dart).
///
/// Field names and Firestore mapping are kept identical on purpose —
/// both sides read/write the same top-level "schedule" collection.
/// Student side never writes, so this model only needs `fromMap`/
/// `fromJson`; `toMap`/`copyWith` are kept for parity and in case a
/// future feature (e.g. caching) needs them.
class ScheduleModel {
  final String id;

  final String department;
  final String semester;

  final String subject;
  final String teacherId;
  final String teacherName;

  final String day;
  final String room;

  final DateTime startTime;
  final DateTime endTime;

  final DateTime createdAt;

  const ScheduleModel({
    required this.id,
    required this.department,
    required this.semester,
    required this.subject,
    required this.teacherId,
    required this.teacherName,
    required this.day,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map, String id) {
    return ScheduleModel(
      id: id,

      department: map["department"] ?? "",
      semester: map["semester"] ?? "",

      subject: map["subject"] ?? "",

      teacherId: map["teacherId"] ?? "",
      teacherName: map["teacherName"] ?? "",

      day: map["day"] ?? "",
      room: map["room"] ?? "",

      startTime: map["startTime"] is Timestamp
          ? (map["startTime"] as Timestamp).toDate()
          : DateTime.now(),

      endTime: map["endTime"] is Timestamp
          ? (map["endTime"] as Timestamp).toDate()
          : DateTime.now(),

      createdAt: map["createdAt"] is Timestamp
          ? (map["createdAt"] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> data) {
    return ScheduleModel(
      id: data['id'] ?? "",

      department: data['department'] ?? "",
      semester: data['semester'] ?? "",

      subject: data['subject'] ?? "",

      teacherId: data['teacherId'] ?? "",
      teacherName: data['teacherName'] ?? "",

      day: data['day'] ?? "",
      room: data['room'] ?? "",

      startTime: data['startTime'] is Timestamp
          ? (data['startTime'] as Timestamp).toDate()
          : DateTime.parse(data['startTime']),

      endTime: data['endTime'] is Timestamp
          ? (data['endTime'] as Timestamp).toDate()
          : DateTime.parse(data['endTime']),

      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "department": department,
      "semester": semester,

      "subject": subject,

      "teacherId": teacherId,
      "teacherName": teacherName,

      "day": day,
      "room": room,

      "startTime": Timestamp.fromDate(startTime),
      "endTime": Timestamp.fromDate(endTime),

      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  ScheduleModel copyWith({
    String? department,
    String? semester,
    String? subject,
    String? teacherId,
    String? teacherName,
    String? day,
    String? room,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
  }) {
    return ScheduleModel(
      id: id,

      department: department ?? this.department,
      semester: semester ?? this.semester,

      subject: subject ?? this.subject,

      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,

      day: day ?? this.day,
      room: room ?? this.room,

      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,

      createdAt: createdAt ?? this.createdAt,
    );
  }
}
