import 'package:flutter/material.dart';

class RecentActivityCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const RecentActivityCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final margin = (width * 0.035).clamp(10.0, 18.0);
    final padding = (width * 0.04).clamp(12.0, 18.0);
    final radius = (width * 0.045).clamp(14.0, 20.0);

    final iconContainerSize = (width * 0.13).clamp(46.0, 58.0);
    final iconSize = (width * 0.065).clamp(24.0, 30.0);

    final titleSize = (width * 0.038).clamp(14.0, 16.0);
    final subtitleSize = (width * 0.032).clamp(12.0, 14.0);
    final timeSize = (width * 0.030).clamp(11.0, 13.0);

    return Container(
      margin: EdgeInsets.only(bottom: margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: iconSize,
            ),
          ),

          SizedBox(width: padding),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: titleSize,
                  ),
                ),

                SizedBox(height: padding * 0.25),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: subtitleSize,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: padding * 0.6),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: timeSize,
                ),
              ),

              SizedBox(height: padding * 0.4),

              Icon(
                Icons.arrow_forward_ios,
                size: iconSize * 0.5,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}