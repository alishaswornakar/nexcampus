// lib/features/student/blocs/digital_queue/widgets/queue_service_card.dart

import 'package:flutter/material.dart';

import '../models/queue_service_model.dart';
import 'queue_icon_resolver.dart';

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
  final bool isJoinInProgress;
  final String? disabledReason;

  bool get _canJoin =>
      service.isOpen && !isJoinInProgress && disabledReason == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = resolveQueueIcon(service.icon);
    final isActiveToken =
        disabledReason != null &&
        disabledReason!.contains('already have an active token');
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon and status
            Row(
              children: [
                Container(
                  width: isSmallScreen ? 40 : (isTablet ? 56 : 48),
                  height: isSmallScreen ? 40 : (isTablet ? 56 : 48),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 10 : 12,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 20 : (isTablet ? 28 : 24),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 14 : (isTablet ? 18 : 16),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        service.counterName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: isSmallScreen ? 11 : (isTablet ? 14 : 12),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _OpenClosedChip(
                  isOpen: service.isOpen,
                  isSmallScreen: isSmallScreen,
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 10 : 14),
            // Stats row - Wrap to next line on small screens
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _StatPill(
                  icon: Icons.people_outline,
                  label: '${service.totalWaiting} waiting',
                  isSmallScreen: isSmallScreen,
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 10 : 12),
            // Action button
            if (disabledReason != null && !isActiveToken) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: isSmallScreen ? 14 : 16,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        disabledReason!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
            ],
            SizedBox(
              width: double.infinity,
              height: isSmallScreen ? 40 : (isTablet ? 48 : 44),
              child: FilledButton(
                onPressed: _canJoin ? onJoin : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _canJoin
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  foregroundColor: _canJoin
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 16,
                  ),
                ),
                child: isJoinInProgress
                    ? SizedBox(
                        height: isSmallScreen ? 18 : 20,
                        width: isSmallScreen ? 18 : 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        service.isOpen
                            ? (disabledReason != null && isActiveToken
                                  ? 'In Queue'
                                  : 'Join Queue')
                            : 'Closed',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : (isTablet ? 16 : 14),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
            // Show "Already in queue" badge for active token
            if (disabledReason != null && isActiveToken) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: isSmallScreen ? 12 : 14,
                      color: Colors.orange.shade700,
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 6),
                    Flexible(
                      child: Text(
                        'You already have an active token for this service',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 11,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OpenClosedChip extends StatelessWidget {
  const _OpenClosedChip({required this.isOpen, required this.isSmallScreen});

  final bool isOpen;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? Colors.green.shade600 : Colors.grey.shade600;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 10,
        vertical: isSmallScreen ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmallScreen ? 5 : 6,
            height: isSmallScreen ? 5 : 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: isSmallScreen ? 3 : 5),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 9 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.isSmallScreen,
  });

  final IconData icon;
  final String label;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 10,
        vertical: isSmallScreen ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 12 : 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: isSmallScreen ? 3 : 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: isSmallScreen ? 10 : 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
