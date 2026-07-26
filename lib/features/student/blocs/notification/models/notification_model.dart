import 'package:cloud_firestore/cloud_firestore.dart';

/// The kind of notification, used to pick an icon/colour and let the
/// teacher side categorise what it's sending.
enum NotificationType { course, assignment, notice, general }

/// Who a notification is meant for.
/// - all      -> every student
/// - course   -> every student enrolled in [targetId] (a courseId)
/// - student  -> a single student, [targetId] is the studentId
enum NotificationTargetType { all, course, student }

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationTargetType targetType;
  final String? targetId;
  final String? courseId;
  final String? courseName;
  final String senderId;
  final String senderName;
  final DateTime createdAt;
  final List<String> readBy;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targetType,
    this.targetId,
    this.courseId,
    this.courseName,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    this.readBy = const [],
  });

  bool isReadBy(String studentId) => readBy.contains(studentId);

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      title: (map['title'] ?? '') as String,
      body: (map['body'] ?? '') as String,
      type: _typeFromString(map['type'] as String?),
      targetType: _targetTypeFromString(map['targetType'] as String?),
      targetId: map['targetId'] as String?,
      courseId: map['courseId'] as String?,
      courseName: map['courseName'] as String?,
      senderId: (map['senderId'] ?? '') as String,
      senderName: (map['senderName'] ?? 'Teacher') as String,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(map['readBy'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.name,
      'targetType': targetType.name,
      'targetId': targetId,
      'courseId': courseId,
      'courseName': courseName,
      'senderId': senderId,
      'senderName': senderName,
      'createdAt': Timestamp.fromDate(createdAt),
      'readBy': readBy,
    };
  }

  static NotificationType _typeFromString(String? value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.general,
    );
  }

  static NotificationTargetType _targetTypeFromString(String? value) {
    return NotificationTargetType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationTargetType.all,
    );
  }
}
