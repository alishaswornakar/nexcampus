// lib/features/student/blocs/anonymous_issue_reporting/widgets/issue_comment_tile.dart
import 'package:flutter/material.dart';

import '../models/issue_comment_model.dart';
import 'anonymous_avatar.dart';

/// Facebook-style comment row: avatar + rounded grey bubble, with a
/// like/upvote action and (only for the comment's own author) a delete
/// action underneath.
class IssueCommentTile extends StatelessWidget {
  const IssueCommentTile({
    super.key,
    required this.comment,
    required this.currentStudentId,
    required this.onUpvote,
    this.onDelete,
  });

  final IssueCommentModel comment;
  final String currentStudentId;
  final VoidCallback onUpvote;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final hasUpvoted = comment.hasUpvoted(currentStudentId);
    final isOwn = comment.authorId == currentStudentId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnonymousAvatar(seed: 'comment::${comment.id}', radius: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              comment.anonymousName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (comment.isFromOriginalPoster) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF29B6F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'OP',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        comment.body,
                        style: const TextStyle(fontSize: 13.5, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: [
                      Text(
                        _relativeTime(comment.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: onUpvote,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasUpvoted
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              size: 13,
                              color: hasUpvoted
                                  ? const Color(0xFF29B6F6)
                                  : Colors.grey.shade500,
                            ),
                            if (comment.upvoteCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '${comment.upvoteCount}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: hasUpvoted
                                      ? const Color(0xFF29B6F6)
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isOwn && onDelete != null) ...[
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: onDelete,
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
