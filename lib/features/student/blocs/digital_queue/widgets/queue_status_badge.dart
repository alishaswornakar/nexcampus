// lib/features/student/blocs/digital_queue/widgets/queue_status_badge.dart

import 'package:flutter/material.dart';

/// Small pill-shaped badge showing a queue/token status with a
/// status-appropriate color. Reused across the service card, active
/// token card, and history list so status colors stay consistent
/// everywhere in the Digital Queue feature.
class QueueStatusBadge extends StatelessWidget {
  const QueueStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final String status;
  final bool compact;

  /// Maps a raw status string (matching `QueueStatus` constants) to a
  /// display label and color. Falls back gracefully for any unknown
  /// value instead of throwing.
  ({String label, Color color}) _presentation(String status) {
    switch (status) {
      case 'waiting':
        return (label: 'Waiting', color: Colors.orange);
      case 'serving':
        return (label: 'Serving', color: Colors.blue);
      case 'completed':
        return (label: 'Completed', color: Colors.green);
      case 'cancelled':
        return (label: 'Cancelled', color: Colors.grey);
      case 'missed':
        return (label: 'Missed', color: Colors.red);
      default:
        return (label: status, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentation = _presentation(status);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    // If compact is true, use compact sizing
    final horizontalPadding = compact
        ? 6.0
        : (isSmallScreen ? 6.0 : (isTablet ? 12.0 : 10.0));
    final verticalPadding = compact
        ? 2.0
        : (isSmallScreen ? 2.0 : (isTablet ? 6.0 : 4.0));
    final fontSize = compact
        ? 10.0
        : (isSmallScreen ? 10.0 : (isTablet ? 14.0 : 12.0));
    final borderWidth = compact ? 0.5 : 1.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: presentation.color.withValues(alpha: compact ? 0.1 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: presentation.color.withValues(alpha: compact ? 0.3 : 0.4),
          width: borderWidth,
        ),
      ),
      child: Text(
        presentation.label,
        style: TextStyle(
          color: presentation.color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
