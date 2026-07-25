import 'package:flutter/material.dart';
import '../../student/screens/student_dashboard_screen.dart';
import 'package:nexcampus_app/features/student/blocs/question_bank/screens/question_bank_screen.dart';
import 'package:nexcampus_app/features/student/blocs/courses/screens/courses_screen.dart';
import 'package:nexcampus_app/features/student/blocs/user_profile/screens/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex; // 0=Home 1=Courses 2=QNB 3=Profile
  const AppBottomNavBar({super.key, required this.currentIndex});

  static const _primary = Color(0xFF1B4F9B);

  void _onTap(BuildContext context, int index) {
    final user = FirebaseAuth.instance.currentUser;
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        if (user != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDashboardScreen(user: user),
            ),
            (r) => false,
          );
        }
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CoursesScreen()),
        );
        break;
      case 2:
        // PoU center button — goes home (acts as brand home button)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuestionBankScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── nav bar body ─────────────────────────────────────────────────
          Positioned.fill(
            child: Container(
              color: _primary,
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    active: currentIndex == 0,
                    onTap: () => _onTap(context, 0),
                  ),
                  _NavItem(
                    icon: Icons.library_books_outlined,
                    activeIcon: Icons.library_books,
                    label: 'Courses',
                    active: currentIndex == 1,
                    onTap: () => _onTap(context, 1),
                  ),
                  _NavItem(
                    icon: Icons.menu_book_outlined,
                    activeIcon: Icons.menu_book,
                    label: 'QNB',
                    active: currentIndex == 2,
                    onTap: () => _onTap(context, 2),
                  ),
                  // spacer for FAB
                  _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile',
                    active: currentIndex == 3,
                    onTap: () => _onTap(context, 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── individual nav item ───────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white12,
        highlightColor: Colors.white10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              size: 22,
              color: active ? Colors.white : Colors.white54,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: active ? Colors.white : Colors.white54,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
