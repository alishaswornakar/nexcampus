import 'package:flutter/material.dart';
import '../model/user_profile_model.dart';
import 'profile_menu_tile.dart';

class AcademicInformationCard extends StatelessWidget {
  final UserProfileModel profile;

  const AcademicInformationCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Academic Information',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ProfileMenuTile(
              icon: Icons.badge_outlined,
              title: 'Roll Number',
              subtitle: profile.rollNumber ?? '-',
            ),
            ProfileMenuTile(
              icon: Icons.account_balance_outlined,
              title: 'Department',
              subtitle: profile.department ?? '-',
            ),
            ProfileMenuTile(
              icon: Icons.calendar_month_outlined,
              title: 'Semester',
              subtitle: profile.semester ?? '-',
            ),
            ProfileMenuTile(
              icon: Icons.class_outlined,
              title: 'Section',
              subtitle: profile.section ?? '-',
            ),
            ProfileMenuTile(
              icon: Icons.event_available_outlined,
              title: 'Joined Date',
              subtitle: profile.joinedDate != null
                  ? '${profile.joinedDate!.day}/${profile.joinedDate!.month}/${profile.joinedDate!.year}'
                  : '-',
            ),
          ],
        ),
      ),
    );
  }
}