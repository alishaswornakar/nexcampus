import 'package:cloud_firestore/cloud_firestore.dart';

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
          (map["createdAt"] as Timestamp?)?.toDate() ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,

      "teacherId": teacherId,
      "teacherName": teacherName,

      "attachmentUrl": attachmentUrl,
      "attachmentName": attachmentName,

      "isPinned": isPinned,

      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  NoticeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? teacherId,
    String? teacherName,
    String? attachmentUrl,
    String? attachmentName,
    bool? isPinned,
    DateTime? createdAt,
  }) {
    return NoticeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,

      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,

      attachmentUrl:
          attachmentUrl ?? this.attachmentUrl,
      attachmentName:
          attachmentName ?? this.attachmentName,

      isPinned: isPinned ?? this.isPinned,

      createdAt: createdAt ?? this.createdAt,
    );
  }
}