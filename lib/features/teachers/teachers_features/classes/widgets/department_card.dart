import 'package:flutter/material.dart';

class DepartmentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int totalStudents;
  final VoidCallback onTap;

  const DepartmentCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.totalStudents,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 30),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "$totalStudents Students",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),

                    const SizedBox(height: 4),

                    const Text("8 Semesters"),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
