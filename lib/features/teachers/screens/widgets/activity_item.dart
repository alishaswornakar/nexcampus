import 'package:flutter/material.dart';

/// Not a Firestore-backed model — just a UI-level wrapper used to merge
/// notices, assignments, and submissions into a single sorted feed for
/// the teacher dashboard "Recent Activity" section.
enum ActivityType { notice, assignment, submission }

class ActivityItem {
  final ActivityType type;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final DateTime time;

  const ActivityItem({
    required this.type,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  /// Human readable relative time, e.g. "15 min ago", "Yesterday".
  String get timeAgo {
    final diff = DateTime.now().difference(time);

    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    }
    if (diff.inHours < 24) {
      return "${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago";
    }
    if (diff.inDays == 1) return "Yesterday";
    if (diff.inDays < 7) return "${diff.inDays} days ago";

    return "${time.day}/${time.month}/${time.year}";
  }
}
