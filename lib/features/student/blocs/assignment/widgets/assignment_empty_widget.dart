// assignment/widgets/assignment_empty_widget.dart
import 'package:flutter/material.dart';

/// Generic empty-state placeholder used across the student assignment
/// module. [filled] controls whether the icon sits inside a tinted
/// circle (most tabs) or renders as a plain outline (the Graded tab,
/// per Figma).
class AssignmentEmptyWidget extends StatelessWidget {
  const AssignmentEmptyWidget({
    super.key,
    this.title = 'No assignments yet',
    this.message = 'New assignments from your teachers will show up here.',
    this.icon = Icons.assignment_outlined,
    this.filled = true,
  });

  final String title;
  final String message;
  final IconData icon;
  final bool filled;

  static const Color _accent = Color(0xFF4C4FE0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final bool isSmall = width < 360;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 24 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (filled)
              Container(
                width: isSmall ? 76 : 92,
                height: isSmall ? 76 : 92,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: isSmall ? 34 : 42, color: _accent),
              )
            else
              Icon(icon, size: isSmall ? 56 : 68, color: _accent),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
