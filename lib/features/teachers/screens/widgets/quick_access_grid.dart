import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/shared_screens/department_semester_selection_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/screens/notice_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/screens/teacher_profile_screen.dart';
import 'package:nexcampus_app/features/teachers/screens/widgets/qiuck_access_card.dart';

class QuickAccessGrid extends StatelessWidget {
  final VoidCallback onLogout;

  const QuickAccessGrid({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int crossAxisCount;

        if (width >= 1000) {
          crossAxisCount = 4; // Tablets/Landscape
        } else if (width >= 700) {
          crossAxisCount = 3; // Large tablets
        } else {
          crossAxisCount = 2; // Phones
        }

        final spacing = (width * 0.04).clamp(12.0, 24.0);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: width < 360
                ? 0.82
                : width < 600
                    ? 0.92
                    : 1.0,
          ),
          itemBuilder: (context, index) => _items[index](context, onLogout),
        );
      },
    );
  }

  static final List<Widget Function(BuildContext, VoidCallback)> _items = [
    (context, _) => QuickAccessCard(
          title: "Attendance",
          icon: Icons.fact_check_outlined,
          iconColor: AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DepartmentSemesterSelectionScreen(
                  feature: FeatureType.attendance,
                ),
              ),
            );
          },
        ),

    (context, _) => QuickAccessCard(
          title: "Courses",
          icon: Icons.menu_book_outlined,
          iconColor: AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DepartmentSemesterSelectionScreen(
                  feature: FeatureType.courses,
                ),
              ),
            );
          },
        ),

    (context, _) => QuickAccessCard(
          title: "Assignments",
          icon: Icons.assignment_outlined,
          iconColor: AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DepartmentSemesterSelectionScreen(
                  feature: FeatureType.assignments,
                ),
              ),
            );
          },
        ),

    (context, _) => QuickAccessCard(
          title: "Classes",
          icon: Icons.groups_outlined,
          iconColor: AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DepartmentSemesterSelectionScreen(
                  feature: FeatureType.classes,
                ),
              ),
            );
          },
        ),

    (context, _) => QuickAccessCard(
          title: "Schedule",
          icon: Icons.calendar_month_outlined,
          iconColor: AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DepartmentSemesterSelectionScreen(
                  feature: FeatureType.schedules,
                ),
              ),
            );
          },
        ),

    (context, _) => QuickAccessCard(
          title: "Notices",
          icon: Icons.campaign_outlined,
          iconColor: AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NoticeScreen(),
              ),
            );
          },
        ),

    // (context, _) => QuickAccessCard(
    //       title: "Profile",
    //       icon: Icons.person_outline,
    //       iconColor: AppTheme.primary,
    //       onTap: () {
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (_) => const TeacherProfileScreen(),
    //           ),
    //         );
    //       },
    //     ),

    // (context, onLogout) => QuickAccessCard(
    //       title: "Logout",
    //       icon: Icons.logout_rounded,
    //       iconColor: Colors.redAccent,
    //       onTap: onLogout,
    //     ),
  ];
}