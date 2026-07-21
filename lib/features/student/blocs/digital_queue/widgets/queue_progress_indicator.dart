// lib/features/student/blocs/digital_queue/widgets/queue_progress_indicator.dart

import 'package:flutter/material.dart';

/// Visual stepper showing how far along the student is in the line —
/// e.g. "3 of 12 waiting" as a filled progress bar. Purely visual sugar
/// on top of [EstimatedWaitCard]'s numbers; safe to omit from a screen
/// if space is tight.
class QueueProgressIndicator extends StatelessWidget {
  const QueueProgressIndicator({
    super.key,
    required this.queuePosition,
    required this.totalWaiting,
  });

  /// The student's own position in line (1 = next).
  final int queuePosition;

  /// Total number of students currently waiting for this service.
  final int totalWaiting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Guard divide-by-zero / nonsensical inputs defensively — Firestore
    // data could theoretically be momentarily inconsistent mid-update.
    final safeTotal = totalWaiting <= 0 ? 1 : totalWaiting;
    final safePosition = queuePosition.clamp(0, safeTotal);
    // Progress = how many people are ahead have been served, i.e.
    // closer to position 1 = higher progress.
    final progress = 1 - (safePosition / safeTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Queue progress',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '$queuePosition of $totalWaiting waiting',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
