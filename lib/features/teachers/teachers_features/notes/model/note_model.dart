import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;

  final String courseId;
  final String courseName;

  final String title;
  final String description;

  final String fileName;
  final String fileUrl;

  final String uploadedBy;

  final DateTime createdAt;

  const NoteModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.description,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory NoteModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return NoteModel(
      id: id,
      courseId: map["courseId"] ?? "",
      courseName: map["courseName"] ?? "",
      title: map["title"] ?? "",
      description: map["description"] ?? "",
      fileName: map["fileName"] ?? "",
      fileUrl: map["fileUrl"] ?? "",
      uploadedBy: map["uploadedBy"] ?? "",
      createdAt:
          (map["createdAt"] as Timestamp)
              .toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "courseId": courseId,
      "courseName": courseName,
      "title": title,
      "description": description,
      "fileName": fileName,
      "fileUrl": fileUrl,
      "uploadedBy": uploadedBy,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }
}