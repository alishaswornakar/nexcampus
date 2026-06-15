import 'package:flutter/material.dart';

import 'quick_tile.dart';

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Access",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: const [
            QuickTile(icon: Icons.calendar_today, label: "Attendance"),
            QuickTile(icon: Icons.assignment, label: "Pending"),
            QuickTile(icon: Icons.star, label: "GPA"),
            QuickTile(icon: Icons.notifications, label: "Alerts"),
            QuickTile(icon: Icons.menu_book, label: "Notes"),
            QuickTile(icon: Icons.book, label: "Syllabus"),
            QuickTile(icon: Icons.schedule, label: "Schedule"),
            QuickTile(icon: Icons.payment, label: "Fees"),
            QuickTile(icon: Icons.campaign, label: "Notices"),
            QuickTile(icon: Icons.support_agent, label: "Support"),
            QuickTile(icon: Icons.local_library, label: "Library"),
            QuickTile(icon: Icons.group, label: "Clubs"),
          ],
        ),
      ],
    );
  }
}
