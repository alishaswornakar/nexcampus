// lib/features/student/blocs/digital_queue/widgets/queue_status_card.dart

import 'package:flutter/material.dart';

import 'queue_status_badge.dart';

/// Shows the current token status prominently. When status is
/// `serving`, replaces the plain badge with a highlighted "your turn"
/// notice, since that's the single most actionable moment for the
/// student in the whole feature.
class QueueStatusCard extends StatelessWidget {
  const QueueStatusCard({super.key, required this.status});

  final String status;

  bool get _isServing => status == 'serving';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isServing) {
      return Align(
        alignment: Alignment.centerLeft,
        child: QueueStatusBadge(status: status),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            "It's your turn — please proceed to the counter",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
