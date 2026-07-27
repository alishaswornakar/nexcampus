import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.isRead,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.course:
        return Icons.menu_book_outlined;
      case NotificationType.assignment:
        return Icons.assignment_outlined;
      case NotificationType.notice:
        return Icons.campaign_outlined;
      case NotificationType.note:
        return Icons.description_outlined;
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.course:
        return Colors.blue;
      case NotificationType.assignment:
        return Colors.orange;
      case NotificationType.notice:
        return Colors.purple;
      case NotificationType.note:
        return Colors.teal;
      case NotificationType.general:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isRead ? Colors.white : const Color(0xFFEFF5FF),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: _iconColor.withValues(alpha: 0.12),
                child: Icon(_icon, color: _iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat(
                        'MMM d, h:mm a',
                      ).format(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
