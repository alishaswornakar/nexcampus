import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors the teacher-side [NoticeModel] field-for-field so that both
/// features read/write the exact same `notices` collection shape. This is
/// what makes the "connection" between teacher and student notices work:
/// a teacher publishes a document here, and the student side maps that same
/// document into this model with no translation step needed.
class NoticeModel {
  final String id;

  final String title;
  final String description;

  final String teacherId;
  final String teacherName;

  /// Optional Attachment
  final String? attachmentUrl;
  final String? attachmentName;

  final bool isPinned;

  final DateTime createdAt;

  const NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    this.attachmentUrl,
    this.attachmentName,
    this.isPinned = false,
    required this.createdAt,
  });

  factory NoticeModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return NoticeModel(
      id: id,
      title: map["title"] ?? "",
      description: map["description"] ?? "",

      teacherId: map["teacherId"] ?? "",
      teacherName: map["teacherName"] ?? "",

      attachmentUrl: map["attachmentUrl"],
      attachmentName: map["attachmentName"],

      isPinned: map["isPinned"] ?? false,

      createdAt:
          (map["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
