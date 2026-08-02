// lib/features/student/blocs/digital_queue/widgets/queue_history_tile.dart

import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/queue_history_model.dart';
import 'queue_status_badge.dart';

/// A single row in the student's queue history list — one past token
/// (completed, cancelled, or missed). Renamed from queue_history_item.
class QueueHistoryTile extends StatelessWidget {
  const QueueHistoryTile({super.key, required this.history, this.index = 0});

  final QueueHistoryModel history;
  final int index;

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]} · $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    // Color mapping for status
    Color getStatusColor(String status) {
      switch (status) {
        case 'completed':
          return Colors.green.shade600;
        case 'cancelled':
          return Colors.grey.shade600;
        case 'missed':
          return Colors.red.shade600;
        default:
          return Colors.grey.shade600;
      }
    }

    Color getStatusBgColor(String status) {
      switch (status) {
        case 'completed':
          return Colors.green.shade50;
        case 'cancelled':
          return Colors.grey.shade50;
        case 'missed':
          return Colors.red.shade50;
        default:
          return Colors.grey.shade50;
      }
    }

    final statusColor = getStatusColor(history.status);
    final statusBgColor = getStatusBgColor(history.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha:0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            // Show token details on tap
            _showTokenDetails(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Row(
              children: [
                // Token number with status color
                Container(
                  width: isSmallScreen ? 40 : (isTablet ? 52 : 48),
                  height: isSmallScreen ? 40 : (isTablet ? 52 : 48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha:0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '#${history.tokenNumber}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: isSmallScreen ? 12 : (isTablet ? 16 : 14),
                      color: statusColor,
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 14),
                // Service details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.serviceName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 14 : (isTablet ? 17 : 15),
                          color: Colors.grey.shade800,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: isSmallScreen ? 12 : 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              history.counterName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: isSmallScreen
                                    ? 11
                                    : (isTablet ? 14 : 12),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time_outlined,
                            size: isSmallScreen ? 12 : 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _formatDate(history.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                                fontSize: isSmallScreen
                                    ? 10
                                    : (isTablet ? 13 : 11),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                QueueStatusBadge(
                  status: history.status,
                  compact: isSmallScreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTokenDetails(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha:0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${history.tokenNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.serviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        history.counterName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DetailChip(
                    icon: Icons.access_time_outlined,
                    label: 'Date & Time',
                    value: _formatDate(history.createdAt),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DetailChip(
                    icon: Icons.info_outline,
                    label: 'Status',
                    value: history.status.toUpperCase(),
                    valueColor: history.status == 'completed'
                        ? Colors.green
                        : history.status == 'cancelled'
                        ? Colors.grey
                        : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 380;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.grey.shade800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
