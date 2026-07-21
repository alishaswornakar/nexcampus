// lib/features/student/blocs/digital_queue/widgets/cancel_token_card.dart

import 'package:flutter/material.dart';

/// Standalone cancel-action card. Kept separate from [ActiveTokenCard]
/// so the confirmation dialog and button styling live in one place —
/// the screen only needs to supply the token's current queuePosition
/// (for the confirmation copy) and a callback for the actual cancel.
class CancelTokenCard extends StatelessWidget {
  const CancelTokenCard({
    super.key,
    required this.serviceName,
    required this.queuePosition,
    required this.onConfirmedCancel,
    this.isInProgress = false,
  });

  final String serviceName;
  final int queuePosition;
  final VoidCallback onConfirmedCancel;
  final bool isInProgress;

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel token?'),
        content: Text(
          'You will lose your position (#$queuePosition) in the queue for $serviceName.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep my place'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel token'),
          ),
        ],
      ),
    );

    if (confirmed == true) onConfirmedCancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isInProgress ? null : () => _confirm(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
          side: BorderSide(color: theme.colorScheme.error),
        ),
        child: isInProgress
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.error,
                ),
              )
            : const Text('Cancel Token'),
      ),
    );
  }
}
