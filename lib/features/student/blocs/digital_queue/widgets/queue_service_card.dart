// lib/features/student/blocs/digital_queue/widgets/queue_service_card.dart

import 'package:flutter/material.dart';

import '../models/queue_service_model.dart';
import 'queue_icon_resolver.dart';

/// Displays a single queue service (e.g. "Library Desk", "Accounts")
/// on the student's "choose a service" screen.
///
/// Shows live status (open/closed), how many students are currently
/// waiting, and a "Join Queue" action — disabled automatically when
/// the service is closed.
class QueueServiceCard extends StatelessWidget {
  const QueueServiceCard({
    super.key,
    required this.service,
    required this.onJoin,
    this.isJoinInProgress = false,
    this.disabledReason,
  });

  final QueueServiceModel service;
  final VoidCallback onJoin;

  /// True while a join request for ANY service is in flight — disables
  /// the button to prevent double-submits, and shows a spinner instead
  /// of the label on the service actually being joined.
  final bool isJoinInProgress;

  /// Optional reason shown instead of the button when the student
  /// already holds an active token elsewhere (e.g. "You already have
  /// an active token"). Passed down from the BLoC state.
  final String? disabledReason;

  bool get _canJoin =>
      service.isOpen && !isJoinInProgress && disabledReason == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = resolveQueueIcon(service.icon);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _OpenClosedChip(isOpen: service.isOpen),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.counterName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatPill(
                        icon: Icons.groups_outlined,
                        label: '${service.totalWaiting} waiting',
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        icon: Icons.timer_outlined,
                        label: '~${service.averageServiceTime} min/person',
                      ),
                    ],
                  ),
                  if (disabledReason != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      disabledReason!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _canJoin ? onJoin : null,
                      child: isJoinInProgress
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(service.isOpen ? 'Join Queue' : 'Closed'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenClosedChip extends StatelessWidget {
  const _OpenClosedChip({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
