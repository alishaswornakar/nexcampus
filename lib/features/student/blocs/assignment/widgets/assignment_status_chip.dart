import 'package:flutter/material.dart';

import '../models/assignment_model.dart';

/// A compact, pill-shaped status indicator used across the student
/// assignment module (task list, detail screen, dashboard cards).
///
/// Renders an icon + label pair whose colors and text are derived
/// from the given [StudentAssignmentStatus].
class AssignmentStatusChip extends StatelessWidget {
  const AssignmentStatusChip({
    super.key,
    required this.status,
  });

  final StudentAssignmentStatus status;

  @override
  Widget build(BuildContext context) {
    final _ChipStyle style = _styleFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style.icon,
            size: 16,
            color: style.foreground,
          ),
          const SizedBox(width: 6),
          Text(
            style.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: style.foreground,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  static _ChipStyle _styleFor(StudentAssignmentStatus status) {
    switch (status) {
      case StudentAssignmentStatus.pending:
        return const _ChipStyle(
          icon: Icons.schedule_rounded,
          background: Color(0xFFFFF3CD),
          foreground: Color(0xFF856404),
          label: 'Pending',
        );
      case StudentAssignmentStatus.overdue:
        return const _ChipStyle(
          icon: Icons.warning_amber_rounded,
          background: Color(0xFFF8D7DA),
          foreground: Color(0xFF721C24),
          label: 'Overdue',
        );
      case StudentAssignmentStatus.submitted:
        return const _ChipStyle(
          icon: Icons.cloud_done_rounded,
          background: Color(0xFFD1ECF1),
          foreground: Color(0xFF0C5460),
          label: 'Submitted',
        );
      case StudentAssignmentStatus.graded:
        return const _ChipStyle(
          icon: Icons.verified_rounded,
          background: Color(0xFFD4EDDA),
          foreground: Color(0xFF155724),
          label: 'Graded',
        );
    }
  }
}

/// Internal value holder describing how a given [AssignmentStatus]
/// should be rendered. Kept private to this file to avoid leaking
/// presentation details into the rest of the module.
class _ChipStyle {
  const _ChipStyle({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.label,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final String label;
}
