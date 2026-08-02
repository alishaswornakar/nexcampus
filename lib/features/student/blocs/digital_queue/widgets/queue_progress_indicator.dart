// lib/features/student/blocs/digital_queue/widgets/queue_progress_indicator.dart

import 'package:flutter/material.dart';

class QueueProgressIndicator extends StatelessWidget {
  const QueueProgressIndicator({
    super.key,
    required this.queuePosition,
    required this.totalWaiting,
  });

  final int queuePosition;
  final int totalWaiting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    final safeTotal = totalWaiting <= 0 ? 1 : totalWaiting;
    final safePosition = queuePosition.clamp(0, safeTotal);
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
                fontSize: isSmallScreen ? 10 : (isTablet ? 14 : 12),
                fontWeight: FontWeight.w500,
              ),
            ),
            Flexible(
              child: Text(
                '$queuePosition of $totalWaiting waiting',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: isSmallScreen ? 10 : (isTablet ? 14 : 12),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: isSmallScreen ? 4 : (isTablet ? 8 : 6),
            backgroundColor: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha:0.4),
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
