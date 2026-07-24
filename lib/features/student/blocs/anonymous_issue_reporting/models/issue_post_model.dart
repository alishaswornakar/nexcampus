// lib/features/student/blocs/anonymous_issue_reporting/models/issue_post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Categories a student can tag their anonymous post with.
class IssueCategory {
  static const String question = 'Question';
  static const String academic = 'Academic';
  static const String facility = 'Facility';
  static const String facultyStaff = 'Faculty/Staff';
  static const String harassment = 'Harassment/Bullying';
  static const String mentalHealth = 'Mental Health';
  static const String other = 'Other';

  static const List<String> all = [
    question,
    academic,
    facility,
    facultyStaff,
    harassment,
    mentalHealth,
    other,
  ];
}

class IssuePostModel {
  final String id;

  /// Kept ONLY for permission checks (edit/delete/mark-resolved by the
  /// original author) and abuse moderation. This is NEVER shown in any UI.
  final String authorId;

  /// Pre-generated display label such as "Anonymous Curious Falcon".
  /// Never derived from the student's real name/email/roll number.
  final String anonymousName;

  final String title;
  final String body;
  final String category;
  final bool isResolved;
  final bool isAnswer; // true if this post is phrased as a question needing answers
  final int commentsCount;
  final int upvoteCount;
  final List<String> upvotedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const IssuePostModel({
    required this.id,
    required this.authorId,
    required this.anonymousName,
    required this.title,
    required this.body,
    required this.category,
    this.isResolved = false,
    this.isAnswer = false,
    this.commentsCount = 0,
    this.upvoteCount = 0,
    this.upvotedBy = const [],
    required this.createdAt,
    this.updatedAt,
  });

  bool hasUpvoted(String studentId) => upvotedBy.contains(studentId);

  factory IssuePostModel.fromMap(Map<String, dynamic> map) {
    return IssuePostModel(
      id: map['id'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      anonymousName: map['anonymousName'] as String? ?? 'Anonymous',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      category: map['category'] as String? ?? IssueCategory.other,
      isResolved: map['isResolved'] as bool? ?? false,
      isAnswer: map['isAnswer'] as bool? ?? false,
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
      upvoteCount: (map['upvoteCount'] as num?)?.toInt() ?? 0,
      upvotedBy: (map['upvotedBy'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt: _asDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _asDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'anonymousName': anonymousName,
      'title': title,
      'body': body,
      'category': category,
      'isResolved': isResolved,
      'isAnswer': isAnswer,
      'commentsCount': commentsCount,
      'upvoteCount': upvoteCount,
      'upvotedBy': upvotedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
