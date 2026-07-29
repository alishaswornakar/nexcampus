import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  final String id;
  final String title;
  final String description;
  final String targetAudience; // 'All', 'Students', 'Teachers'
  final String? attachmentUrl; // Cloudinary Link
  final String postedBy;
  final bool isPinned; // 📌 Pin Status
  final DateTime createdAt;

  NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAudience,
    this.attachmentUrl,
    required this.postedBy,
    this.isPinned = false,
    required this.createdAt,
  });

  factory NoticeModel.fromMap(Map<String, dynamic> map, String docId) {
    return NoticeModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      targetAudience: map['targetAudience'] ?? 'All',
      attachmentUrl: map['attachmentUrl'],
      postedBy: map['postedBy'] ?? 'Admin',
      isPinned: map['isPinned'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'targetAudience': targetAudience,
      'attachmentUrl': attachmentUrl,
      'postedBy': postedBy,
      'isPinned': isPinned,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}