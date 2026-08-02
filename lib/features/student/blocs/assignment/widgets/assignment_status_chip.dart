// assignment/widgets/assignment_status_chip.dart
import 'package:flutter/material.dart';

import '../models/assignment_model.dart';

/// Small pill-shaped badge shown on assignment cards. For pending
/// assignments it shows a live countdown to the deadline ("DUE TODAY",
/// "DUE TOMORROW", "IN 3 DAYS"); for overdue/submitted/graded it shows
/// a plain status label. Matches the Figma badge style: no icon, bold
/// small caps text on a tinted background.
class AssignmentStatusChip extends StatelessWidget {
  const AssignmentStatusChip({super.key, required this.assignment});

  final StudentAssignmentModel assignment;

  _ChipStyle _style() {
    switch (assignment.status) {
      case StudentAssignmentStatus.overdue:
        return const _ChipStyle(
          label: 'OVERDUE',
          background: Color(0xFFFCE4E6),
          foreground: Color(0xFFD8232A),
        );
      case StudentAssignmentStatus.submitted:
        return const _ChipStyle(
          label: 'SUBMITTED',
          background: Color(0xFFDCEAFB),
          foreground: Color(0xFF1B63C8),
        );
      case StudentAssignmentStatus.graded:
        return const _ChipStyle(
          label: 'GRADED',
          background: Color(0xFFDDF2E3),
          foreground: Color(0xFF1E8E4F),
        );
      case StudentAssignmentStatus.pending:
        final days = assignment.remainingTime.inDays;
        final bool urgent = assignment.isDueToday || days <= 1;
        final String label = assignment.isDueToday
            ? 'DUE TODAY'
            : days <= 1
            ? 'DUE TOMORROW'
            : 'IN $days DAYS';
        return _ChipStyle(
          label: label,
          background: urgent
              ? const Color(0xFFFCE4E6)
              : const Color(0xFFFDEACB),
          foreground: urgent
              ? const Color(0xFFD8232A)
              : const Color(0xFFB4720A),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        style.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: style.foreground,
          height: 1.1,
        ),
      ),
    );
  }
}

class _ChipStyle {
  const _ChipStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}
