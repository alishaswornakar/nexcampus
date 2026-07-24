import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String courseName;
  final String courseCode;
  final String department;
  final String semester;
  final String teacherId;
  final String teacherName;
  final String description;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.department,
    required this.semester,
    required this.teacherId,
    required this.teacherName,
    required this.description,
    required this.createdAt,
  });

  factory CourseModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return CourseModel(
      id: id,
      courseName: map["courseName"] ?? "",
      courseCode: map["courseCode"] ?? "",
      department: map["department"] ?? "",
      semester: map["semester"] ?? "",
      teacherId: map["teacherId"] ?? "",
      teacherName: map["teacherName"] ?? "",
      description: map["description"] ?? "",
      createdAt: (map["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "courseName": courseName,
      "courseCode": courseCode,
      "department": department,
      "semester": semester,
      "teacherId": teacherId,
      "teacherName": teacherName,
      "description": description,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }
}