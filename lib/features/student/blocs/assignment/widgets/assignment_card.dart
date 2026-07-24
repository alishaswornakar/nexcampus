import 'package:flutter/material.dart';

import '../models/assignment_model.dart';
import 'assignment_status_chip.dart';

/// A single assignment row shown in the student "Tasks" list.
///
/// Displays the assignment title, subject/teacher, due date and the
/// derived [StudentAssignmentStatus] as a pill chip. When the
/// assignment has been graded, the grade is also surfaced inline.
///
/// Tapping the card invokes [onTap], which the parent screen typically
/// wires to navigation into `AssignmentDetailScreen`.
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  final StudentAssignmentModel assignment;
  final VoidCallback onTap;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    return '$day $month ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour24 = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:$minute $period';
  }

  String _dueDateLabel() {
    final due = assignment.dueDate;
    return 'Due ${_formatDate(due)} · ${_formatTime(due)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool highlightOverdue = assignment.isOverdue;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highlightOverdue
              ? colorScheme.error.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${assignment.subject} · ${assignment.teacherName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AssignmentStatusChip(status: assignment.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 15,
                    color: highlightOverdue
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _dueDateLabel(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: highlightOverdue
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                        fontWeight:
                            highlightOverdue ? FontWeight.w600 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (assignment.hasAssignmentPdf) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.attach_file_rounded,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
              if (assignment.isGraded) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.grade_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Grade: ${assignment.grade}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (assignment.feedback.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            assignment.feedback,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else if (assignment.isSubmitted) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        assignment.submittedAt != null
                            ? 'Submitted on ${_formatDate(assignment.submittedAt!)}'
                            : 'Submitted',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
