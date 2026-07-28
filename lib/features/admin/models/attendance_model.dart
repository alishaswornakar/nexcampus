import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String studentRoll;
  final String department;
  final String semester;
  final String section;
  final String status; // 'Present', 'Absent', 'Leave'
  final DateTime date;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentRoll,
    required this.department,
    required this.semester,
    required this.section,
    required this.status,
    required this.date,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String docId) {
    return AttendanceModel(
      id: docId,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? 'Unknown',
      studentRoll: map['studentRoll'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      section: map['section'] ?? '',
      status: map['status'] ?? 'Absent',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}