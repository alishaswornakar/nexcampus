// lib/features/student/blocs/digital_queue/widgets/queue_status_badge.dart

import 'package:flutter/material.dart';

/// Small pill-shaped badge showing a queue/token status with a
/// status-appropriate color. Reused across the service card, active
/// token card, and history list so status colors stay consistent
/// everywhere in the Digital Queue feature.
class QueueStatusBadge extends StatelessWidget {
  const QueueStatusBadge({super.key, required this.status});

  final String status;

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: presentation.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: presentation.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        presentation.label,
        style: TextStyle(
          color: presentation.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
