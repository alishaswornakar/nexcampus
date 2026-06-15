import 'package:flutter/material.dart';

class AnnouncementsSection extends StatelessWidget {
  const AnnouncementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Announcements",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            children: [
              _AnnouncementTile(
                icon: Icons.info,
                iconColor: Colors.blue,
                title: "Mid-Semester Exams start from Nov 15th",
              ),

              Divider(height: 1),

              _AnnouncementTile(
                icon: Icons.warning,
                iconColor: Colors.red,
                title: "Hostel Fees due by Oct 31st",
              ),

              Divider(height: 1),

              _AnnouncementTile(
                icon: Icons.campaign,
                iconColor: Colors.orange,
                title: "College fest registration closes this Friday",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _AnnouncementTile({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
