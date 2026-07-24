// lib/features/student/blocs/anonymous_issue_reporting/widgets/issue_post_card.dart
import 'package:flutter/material.dart';

import '../models/issue_post_model.dart';
import '../utils/anonymous_identity.dart';
import '../utils/issue_colors.dart';
import 'anonymous_avatar.dart';
import 'category_chip.dart';

/// Facebook/Quora-style feed card for a single anonymous post.
class IssuePostCard extends StatelessWidget {
  const IssuePostCard({
    super.key,
    required this.post,
    required this.currentStudentId,
    required this.onTap,
    required this.onUpvote,
    this.showManageBadge = false,
  });

  final IssuePostModel post;
  final String currentStudentId;
  final VoidCallback onTap;
  final VoidCallback onUpvote;

  /// Shown in "My Posts" so the owner knows this card is theirs, even
  /// though everyone else only ever sees [post.anonymousName].
  final bool showManageBadge;

  @override
  Widget build(BuildContext context) {
    final hasUpvoted = post.hasUpvoted(currentStudentId);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnonymousAvatar(
                  seed: AnonymousIdentity.postSeed(post.id),
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.anonymousName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (showManageBadge) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'You',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _relativeTime(post.createdAt),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.isResolved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Resolved',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              post.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.5, color: Colors.grey.shade800, height: 1.35),
            ),
            const SizedBox(height: 10),
            CategoryChip(label: post.category, dense: true),
            const Divider(height: 22),
            Row(
              children: [
                _ActionButton(
                  icon: hasUpvoted
                      ? Icons.thumb_up
                      : Icons.thumb_up_outlined,
                  label: '${post.upvoteCount}',
                  color: hasUpvoted ? IssueColors.skyBlue : Colors.grey.shade600,
                  onTap: onUpvote,
                ),
                const SizedBox(width: 18),
                _ActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: '${post.commentsCount}',
                  color: Colors.grey.shade600,
                  onTap: onTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
