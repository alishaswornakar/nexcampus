// lib/features/student/blocs/digital_queue/widgets/live_counter_card.dart

import 'package:flutter/material.dart';

/// Shows the service's live "now serving" token number — pulled from
/// `QueueServiceModel.currentToken` — so the student can compare it
/// against their own token number at a glance without doing math.
///
/// This is intentionally decoupled from [QueueServiceModel] itself
/// (takes raw values, not the model) so it can be driven by either the
/// services-list stream or a dedicated single-service stream
/// (`DigitalQueueRepository` doesn't currently expose the latter to the
/// BLoC — see note below) without this widget caring which.
class LiveCounterCard extends StatelessWidget {
  const LiveCounterCard({
    super.key,
    required this.currentToken,
    required this.counterName,
  });

  final int currentToken;
  final String counterName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Now serving at $counterName',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            '#$currentToken',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
