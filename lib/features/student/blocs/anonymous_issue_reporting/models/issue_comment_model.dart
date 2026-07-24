// lib/features/student/blocs/anonymous_issue_reporting/models/issue_comment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class IssueCommentModel {
  final String id;
  final String postId;

  /// Kept ONLY for permission checks (delete own comment) and moderation.
  /// NEVER shown in any UI.
  final String authorId;

  /// e.g. "Anonymous Bold Otter". Consistent within this post's thread
  /// only - see [AnonymousIdentity.commentSeed].
  final String anonymousName;

  final bool isFromOriginalPoster;
  final String body;
  final int upvoteCount;
  final List<String> upvotedBy;
  final DateTime createdAt;

  const IssueCommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.anonymousName,
    this.isFromOriginalPoster = false,
    required this.body,
    this.upvoteCount = 0,
    this.upvotedBy = const [],
    required this.createdAt,
  });

  bool hasUpvoted(String studentId) => upvotedBy.contains(studentId);

  factory IssueCommentModel.fromMap(Map<String, dynamic> map) {
    return IssueCommentModel(
      id: map['id'] as String? ?? '',
      postId: map['postId'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      anonymousName: map['anonymousName'] as String? ?? 'Anonymous',
      isFromOriginalPoster: map['isFromOriginalPoster'] as bool? ?? false,
      body: map['body'] as String? ?? '',
      upvoteCount: (map['upvoteCount'] as num?)?.toInt() ?? 0,
      upvotedBy: (map['upvotedBy'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt: _asDateTime(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'anonymousName': anonymousName,
      'isFromOriginalPoster': isFromOriginalPoster,
      'body': body,
      'upvoteCount': upvoteCount,
      'upvotedBy': upvotedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
