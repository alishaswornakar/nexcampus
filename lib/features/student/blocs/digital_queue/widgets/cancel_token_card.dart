// lib/features/student/blocs/digital_queue/widgets/cancel_token_card.dart

import 'package:flutter/material.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600),
            const SizedBox(width: 10),
            const Text('Cancel token?'),
          ],
        ),
        content: Text(
          'You will lose your position (#$queuePosition) in the queue for $serviceName.\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep my place'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isInProgress ? null : () => _confirm(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
          side: BorderSide(color: theme.colorScheme.error.withValues(alpha:0.5)),
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 10 : (isTablet ? 14 : 12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isInProgress
            ? SizedBox(
                height: isSmallScreen ? 18 : 20,
                width: isSmallScreen ? 18 : 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.error,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.close_outlined,
                    size: isSmallScreen ? 16 : (isTablet ? 20 : 18),
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 8),
                  Text(
                    'Leave Queue',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : (isTablet ? 16 : 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
