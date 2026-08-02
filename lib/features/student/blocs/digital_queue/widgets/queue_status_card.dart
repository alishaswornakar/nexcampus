// lib/features/student/blocs/digital_queue/widgets/queue_status_card.dart

import 'package:flutter/material.dart';
import 'queue_status_badge.dart';

class QueueStatusCard extends StatelessWidget {
  const QueueStatusCard({super.key, required this.status});

  final String status;

  bool get _isServing => status == 'serving';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    if (!_isServing) {
      return Align(
        alignment: Alignment.centerLeft,
        child: QueueStatusBadge(status: status),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 10 : (isTablet ? 14 : 12),
        horizontal: isSmallScreen ? 10 : (isTablet ? 18 : 14),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: theme.colorScheme.primary,
            size: isSmallScreen ? 16 : (isTablet ? 20 : 18),
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Flexible(
            child: Text(
              "It's your turn — please proceed to the counter",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 12 : (isTablet ? 16 : 14),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
