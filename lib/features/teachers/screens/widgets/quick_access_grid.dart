import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/screens/teacher_dashboard_screen.dart';

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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: .95,
      children: [

        QuickAccessCard(
          title: "Attendance",
          icon: Icons.fact_check_outlined,
          iconColor:  AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const DepartmentSemesterSelectionScreen(
                  feature: FeatureType.attendance,
                ),
              ),
            );
          },
        ),

        QuickAccessCard(
          title: "Courses",
          icon: Icons.menu_book_outlined,
          iconColor:  AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const DepartmentSemesterSelectionScreen(
                  feature: FeatureType.courses,
                ),
              ),
            );
          },
        ),

        QuickAccessCard(
          title: "Assignments",
          icon: Icons.assignment_outlined,
          iconColor:  AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const DepartmentSemesterSelectionScreen(
                  feature: FeatureType.assignments,
                ),
              ),
            );
          },
        ),

        QuickAccessCard(
          title: "Classes",
          icon: Icons.groups_outlined,
          iconColor:  AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const DepartmentSemesterSelectionScreen(
                  feature: FeatureType.classes,
                ),
              ),
            );
          },
        ),

        QuickAccessCard(
          title: "Schedule",
          icon: Icons.calendar_month_outlined,
          iconColor:  AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const DepartmentSemesterSelectionScreen(
                  feature: FeatureType.schedules,
                ),
              ),
            );
          },
        ),

        QuickAccessCard(
          title: "Notices",
          icon: Icons.campaign_outlined,
          iconColor:  AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NoticeScreen(),
              ),
            );
          },
        ),

        QuickAccessCard(
          title: "Profile",
          icon: Icons.person_outline,
          iconColor:  AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const TeacherProfileScreen(),
              ),
            );
          },
        ),

        QuickAccessCard(
          title: "Logout",
          icon: Icons.logout_rounded,
          iconColor: Colors.redAccent,
          onTap: onLogout,
        ),
      ],
    );
  }
}