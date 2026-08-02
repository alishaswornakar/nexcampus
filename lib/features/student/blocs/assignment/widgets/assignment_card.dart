// assignment/widgets/assignment_card.dart
import 'package:flutter/material.dart';

import '../models/assignment_model.dart';
import 'assignment_status_chip.dart';

/// Assignment list row, styled to match the Figma "Assignments" list:
/// a lavender rounded card with the title, a due-countdown badge, a
/// short description line, and a "View Details" link.
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  final StudentAssignmentModel assignment;
  final VoidCallback onTap;

  static const Color _cardBg = Color(0xFFEEF0FB);
  static const Color _linkColor = Color(0xFF4C4FE0);

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime date) {
    final hour24 = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmall = width < 360;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16, vertical: 6),
      child: Material(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(isSmall ? 14 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        assignment.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmall ? 15 : 16.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF14142B),
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AssignmentStatusChip(assignment: assignment),
                        const SizedBox(height: 6),
                        Text(
                          '${_formatDate(assignment.dueDate)}, '
                          '${_formatTime(assignment.dueDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isSmall ? 10.5 : 11.5,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        assignment.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmall ? 12.5 : 13.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _linkColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
