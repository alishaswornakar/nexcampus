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
    final width = MediaQuery.of(context).size.width;

    final bool isTablet = width >= 600;
    final bool isDesktop = width >= 1000;

    final double cardPadding = isDesktop
        ? 24
        : isTablet
            ? 20
            : 16;

    final double avatarRadius = isDesktop
        ? 36
        : isTablet
            ? 32
            : 28;

    final double iconSize = isDesktop
        ? 34
        : isTablet
            ? 30
            : 26;

    final double titleSize = isDesktop
        ? 22
        : isTablet
            ? 20
            : 17;

    final double subtitleSize = isDesktop
        ? 16
        : isTablet
            ? 15
            : 13;

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(
        bottom: isTablet ? 18 : 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: color.withValues(alpha:.15),
                child: Icon(
                  icon,
                  color: color,
                  size: iconSize,
                ),
              ),

              SizedBox(width: isTablet ? 20 : 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                      ),
                    ),

                    SizedBox(height: isTablet ? 8 : 6),

                    Text(
                      "$totalStudents Students",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: subtitleSize,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "8 Semesters",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: subtitleSize,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                size: isTablet ? 20 : 18,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}