import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/models/attendancestudent_model.dart';

class AttendanceModel {
  final String id;
  final String department;
  final String semester;

  final String subjectId;
  final String subjectName;
  final String teacherId;

  final DateTime date;
  final List<AttendanceStudentModel> students;

  AttendanceModel({
    required this.id,
    required this.department,
    required this.semester,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.date,
    required this.students,
  });

  factory AttendanceModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return AttendanceModel(
      id: id,
      department: map["department"] ?? "",
      semester: map["semester"] ?? "",
      subjectId: map["subjectId"] ?? "",
      subjectName: map["subjectName"] ?? "",
      teacherId: map["teacherId"] ?? "",
      date: (map["date"] as Timestamp).toDate(),
      students: (map["students"] as List)
          .map(
            (e) => AttendanceStudentModel.fromMap(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "department": department,
      "semester": semester,
      "subjectId": subjectId,
      "subjectName": subjectName,
      "teacherId": teacherId,
      "date": Timestamp.fromDate(date),
      "students": students.map((e) => e.toMap()).toList(),
    };
  }
}