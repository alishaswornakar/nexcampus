import 'package:flutter/material.dart';

class QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const QuickAccessCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final cardRadius = (width * 0.05).clamp(16.0, 24.0);
    final iconContainerSize = (width * 0.14).clamp(48.0, 64.0);
    final iconSize = (width * 0.07).clamp(24.0, 32.0);
    final horizontalPadding = (width * 0.04).clamp(12.0, 20.0);
    final verticalPadding = (width * 0.05).clamp(16.0, 24.0);
    final spacing = (width * 0.04).clamp(12.0, 18.0);
    final fontSize = (width * 0.038).clamp(13.0, 16.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        splashColor: iconColor.withValues(alpha: .15),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(30, 238, 238, 238),
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(
              color: const Color.fromARGB(30, 238, 238, 238),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
              ),

              SizedBox(height: spacing),

              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}