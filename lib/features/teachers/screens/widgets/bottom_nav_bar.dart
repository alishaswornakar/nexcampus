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

  static const Color primaryColor =  AppTheme.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(134, 255, 255, 255),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
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
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              _navItem(
                index: 0,
                icon: Icons.home_rounded,
                label: "Home",
              ),

              _navItem(
                index: 1,
                icon: Icons.menu_book_rounded,
                label: "Courses",
              ),

              _navItem(
                index: 2,
                icon: Icons.calendar_month_rounded,
                label: "Schedule",
              ),

              _navItem(
                index: 3,
                icon: Icons.person_rounded,
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withOpacity(.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(
                icon,
                size: 26,
                color: selected
                    ?  AppTheme.primary
                    : const Color.fromARGB(33, 158, 158, 158),
              ),

              const SizedBox(height: 4),

              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ?  AppTheme.primary
                      : const Color.fromARGB(218, 158, 158, 158),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}