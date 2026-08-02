// lib/features/student/blocs/digital_queue/widgets/active_token_card.dart

import 'package:flutter/material.dart';

import '../models/queue_token_model.dart';
import 'cancel_token_card.dart';
import 'current_token_card.dart';
import 'estimated_wait_card.dart';
import 'queue_progress_indicator.dart';
import 'queue_status_card.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(isSmallScreen ? 16 : (isTablet ? 24 : 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha:0.06),
            theme.colorScheme.primary.withValues(alpha:0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha:0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha:0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CurrentTokenCard(
            tokenNumber: token.tokenNumber,
            serviceName: token.serviceName,
            counterName: token.counterName,
          ),
          SizedBox(height: isSmallScreen ? 12 : 14),
          QueueStatusCard(status: token.status),
          if (!_isServing) ...[
            SizedBox(height: isSmallScreen ? 12 : 14),
            EstimatedWaitCard(
              queuePosition: token.queuePosition,
              estimatedWaitMinutes: token.estimatedWaitMinutes,
            ),
            if (totalWaiting != null) ...[
              SizedBox(height: isSmallScreen ? 12 : 14),
              QueueProgressIndicator(
                queuePosition: token.queuePosition,
                totalWaiting: totalWaiting!,
              ),
            ],
          ],
          SizedBox(height: isSmallScreen ? 12 : 16),
          CancelTokenCard(
            serviceName: token.serviceName,
            queuePosition: token.queuePosition,
            isInProgress: isCancelInProgress,
            onConfirmedCancel: onCancel,
          ),
        ],
      ),
    );
  }
}
