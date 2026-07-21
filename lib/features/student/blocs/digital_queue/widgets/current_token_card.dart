// lib/features/student/blocs/digital_queue/widgets/current_token_card.dart

import 'package:flutter/material.dart';

/// Displays the student's token number, big and centered — the single
/// most important piece of information on the active-queue screen.
/// Kept deliberately minimal (no status/actions) so it can be reused
/// standalone or embedded inside [ActiveTokenCard].
class CurrentTokenCard extends StatelessWidget {
  const CurrentTokenCard({
    super.key,
    required this.tokenNumber,
    required this.serviceName,
    required this.counterName,
  });

  final int tokenNumber;
  final String serviceName;
  final String counterName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          serviceName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          counterName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your Token',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '#$tokenNumber',
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
