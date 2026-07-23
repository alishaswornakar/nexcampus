// lib/features/student/blocs/team_finder/widgets/team_post_card.dart
import 'package:flutter/material.dart';

import '../models/team_post_model.dart';
import 'skill_tag_chip.dart';

/// Card used in Browse / My Posts lists to summarize a [TeamPostModel].
class TeamPostCard extends StatelessWidget {
  const TeamPostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.showOwner = true,
  });

  final TeamPostModel post;
  final VoidCallback onTap;
  final bool showOwner;

  @override
  Widget build(BuildContext context) {
    final isOpen = post.isOpen;

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
              color: Colors.black.withValues(alpha:0.03),
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
                Expanded(
                  child: Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(isOpen: isOpen, status: post.status),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _MetaChip(icon: Icons.category_outlined, label: post.projectType),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${post.department} • Sem ${post.semester}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
            if (post.skillsNeeded.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: post.skillsNeeded
                    .take(4)
                    .map((s) => SkillTagChip(label: s, dense: true))
                    .toList(),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.people_outline, size: 15, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${post.slotsFilled}/${post.slotsTotal} filled',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),
                if (showOwner)
                  Flexible(
                    child: Text(
                      post.ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOpen, required this.status});
  final bool isOpen;
  final String status;

  @override
  Widget build(BuildContext context) {
    final MaterialColor color = isOpen ? Colors.green : Colors.grey;
    final label = isOpen ? 'Open' : (status == 'closed' ? 'Closed' : 'Full');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.shade700,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.blueGrey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade700),
          ),
        ],
      ),
    );
  }
}
