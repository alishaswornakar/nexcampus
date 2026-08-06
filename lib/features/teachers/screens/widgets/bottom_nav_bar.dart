import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DashboardBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color primaryColor = AppTheme.primary;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final iconSize = width * 0.065; // Responsive
    final fontSize = width * 0.030;
    final verticalPadding = width * 0.022;
    final radius = width * 0.045;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 15,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.02,
            vertical: width * 0.015,
          ),
          child: Row(
            children: [
              _navItem(
                context,
                index: 0,
                icon: Icons.home_rounded,
                label: "Home",
                iconSize: iconSize,
                fontSize: fontSize,
                radius: radius,
                padding: verticalPadding,
              ),
              _navItem(
                context,
                index: 1,
                icon: Icons.menu_book_rounded,
                label: "Courses",
                iconSize: iconSize,
                fontSize: fontSize,
                radius: radius,
                padding: verticalPadding,
              ),
              _navItem(
                context,
                index: 2,
                icon: Icons.calendar_month_rounded,
                label: "Schedule",
                iconSize: iconSize,
                fontSize: fontSize,
                radius: radius,
                padding: verticalPadding,
              ),
              _navItem(
                context,
                index: 3,
                icon: Icons.person_rounded,
                label: "Profile",
                iconSize: iconSize,
                fontSize: fontSize,
                radius: radius,
                padding: verticalPadding,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required double iconSize,
    required double fontSize,
    required double radius,
    required double padding,
  }) {
    final bool selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: padding),
          decoration: BoxDecoration(
            color: selected ? Colors.white24 : Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                child: Icon(
                  icon,
                  size: iconSize.clamp(22.0, 30.0),
                  color: selected ? Colors.white : Colors.white60,
                ),
              ),
              SizedBox(height: padding * 0.4),
              FittedBox(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize.clamp(10.0, 14.0),
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.white60,
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
