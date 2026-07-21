// lib/features/student/blocs/digital_queue/widgets/active_token_card.dart

import 'package:flutter/material.dart';

import '../models/queue_token_model.dart';
import 'cancel_token_card.dart';
import 'current_token_card.dart';
import 'estimated_wait_card.dart';
import 'queue_progress_indicator.dart';
import 'queue_status_card.dart';

/// Composed card shown when the student holds an active token
/// (waiting/serving). Assembles [CurrentTokenCard], [QueueStatusCard],
/// [EstimatedWaitCard] + [QueueProgressIndicator] (hidden once
/// `serving`), and [CancelTokenCard] into one cohesive card — this is
/// the single widget the home screen actually places on-screen.
///
/// `totalWaiting` is optional: pass it (from the matching
/// `QueueServiceModel` in the services stream) to also render the
/// progress bar; omit it to show only the numeric position/ETA tiles.
class ActiveTokenCard extends StatelessWidget {
  const ActiveTokenCard({
    super.key,
    required this.token,
    required this.onCancel,
    this.isCancelInProgress = false,
    this.totalWaiting,
  });

  final QueueTokenModel token;
  final VoidCallback onCancel;
  final bool isCancelInProgress;
  final int? totalWaiting;

  bool get _isServing => token.status == 'serving';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: _isServing
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CurrentTokenCard(
              tokenNumber: token.tokenNumber,
              serviceName: token.serviceName,
              counterName: token.counterName,
            ),
            const SizedBox(height: 16),
            QueueStatusCard(status: token.status),
            if (!_isServing) ...[
              const SizedBox(height: 16),
              EstimatedWaitCard(
                queuePosition: token.queuePosition,
                estimatedWaitMinutes: token.estimatedWaitMinutes,
              ),
              if (totalWaiting != null) ...[
                const SizedBox(height: 14),
                QueueProgressIndicator(
                  queuePosition: token.queuePosition,
                  totalWaiting: totalWaiting!,
                ),
              ],
            ],
            const SizedBox(height: 20),
            CancelTokenCard(
              serviceName: token.serviceName,
              queuePosition: token.queuePosition,
              isInProgress: isCancelInProgress,
              onConfirmedCancel: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}