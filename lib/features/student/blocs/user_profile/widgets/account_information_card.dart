import 'package:flutter/material.dart';
import '../model/user_profile_model.dart';
import 'profile_menu_tile.dart';

class AccountInformationCard extends StatelessWidget {
  final UserProfileModel profile;

  const AccountInformationCard({super.key, required this.profile});

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
                'Account Information',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ProfileMenuTile(
              icon: Icons.fingerprint,
              title: 'User ID',
              subtitle: profile.uid,
            ),
            ProfileMenuTile(
              icon: Icons.bloodtype_outlined,
              title: 'Blood Group',
              subtitle: profile.bloodGroup ?? '-',
            ),
            ProfileMenuTile(
              icon: Icons.cake_outlined,
              title: 'Date of Birth',
              subtitle: profile.dateOfBirth != null
                  ? '${profile.dateOfBirth!.day}/${profile.dateOfBirth!.month}/${profile.dateOfBirth!.year}'
                  : '-',
            ),
          ],
        ),
      ),
    );
  }
}