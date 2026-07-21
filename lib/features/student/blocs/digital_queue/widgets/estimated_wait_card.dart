// lib/features/student/blocs/digital_queue/widgets/estimated_wait_card.dart

import 'package:flutter/material.dart';

/// Shows queue position and estimated wait time side by side. Hidden
/// entirely once the token status is `serving` (there's no more
/// waiting left to estimate) — the parent decides whether to show it.
class EstimatedWaitCard extends StatelessWidget {
  const EstimatedWaitCard({
    super.key,
    required this.queuePosition,
    required this.estimatedWaitMinutes,
  });

  final int queuePosition;
  final int estimatedWaitMinutes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.people_outline,
            label: 'Position',
            value: '$queuePosition',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: Icons.hourglass_bottom_outlined,
            label: 'Est. wait',
            value: '$estimatedWaitMinutes min',
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
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
