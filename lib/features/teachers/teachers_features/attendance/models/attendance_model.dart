import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/models/attendancestudent_model.dart';

class AttendanceModel {
  final String id;
  final String department;
  final String semester;
  final DateTime date;
  final List<AttendanceStudentModel> students;

  AttendanceModel({
    required this.id,
    required this.department,
    required this.semester,
    required this.date,
    required this.students,
  });

  factory AttendanceModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return AttendanceModel(
      id: id,
      department: map["department"] ?? "",
      semester: map["semester"] ?? "",
      date: (map["date"] as Timestamp).toDate(),
      students: (map["students"] as List<dynamic>? ?? [])
          .map(
            (e) => AttendanceStudentModel.fromMap(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "department": department,
      "semester": semester,
      "date": Timestamp.fromDate(date),
      "createdAt": FieldValue.serverTimestamp(),
      "students": students
          .map((e) => e.toMap())
          .toList(),
    };
  }
}