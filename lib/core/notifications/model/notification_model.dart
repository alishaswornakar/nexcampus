import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;

  final String title;
  final String body;

  final String type;

  final String department;
  final String semester;

  final String receiverRole;

  final DateTime createdAt;

  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.department,
    required this.semester,
    required this.receiverRole,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return NotificationModel(
      id: id,
      title: map["title"] ?? "",
      body: map["body"] ?? "",
      type: map["type"] ?? "",
      department: map["department"] ?? "",
      semester: map["semester"] ?? "",
      receiverRole: map["receiverRole"] ?? "student",
      createdAt:
          (map["createdAt"] as Timestamp).toDate(),
      isRead: map["isRead"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "body": body,
      "type": type,
      "department": department,
      "semester": semester,
      "receiverRole": receiverRole,
      "createdAt": Timestamp.fromDate(createdAt),
      "isRead": isRead,
    };
  }
}