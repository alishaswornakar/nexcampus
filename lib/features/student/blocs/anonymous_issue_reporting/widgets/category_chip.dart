// lib/features/student/blocs/anonymous_issue_reporting/widgets/category_chip.dart
import 'package:flutter/material.dart';

import '../utils/issue_colors.dart';

/// Small pill used to render a post's category, e.g. "Academic".
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.label, this.dense = false});

  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: IssueColors.skyBlueLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: IssueColors.skyBlue.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: dense ? 11 : 12,
          color: IssueColors.skyBlueDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
