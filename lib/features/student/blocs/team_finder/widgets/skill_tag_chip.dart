// lib/features/student/blocs/team_finder/widgets/skill_tag_chip.dart
import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

/// Small pill used to render a single skill/tag.
/// Used inside [TeamPostCard], the detail screen, and the create-post form.
class SkillTagChip extends StatelessWidget {
  const SkillTagChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.dense = false,
  });

  final String label;
  final VoidCallback? onDeleted;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: dense ? 11 : 12,
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(
                Icons.close,
                size: dense ? 12 : 14,
                color: AppTheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
