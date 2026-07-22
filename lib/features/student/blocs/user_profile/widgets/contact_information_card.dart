import 'package:flutter/material.dart';
import '../model/user_profile_model.dart';
import 'profile_menu_tile.dart';

class ContactInformationCard extends StatelessWidget {
  final UserProfileModel profile;

  const ContactInformationCard({super.key, required this.profile});

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
                'Contact Information',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ProfileMenuTile(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: profile.email,
            ),
            ProfileMenuTile(
              icon: Icons.phone_outlined,
              title: 'Phone Number',
              subtitle: profile.phoneNumber ?? '-',
            ),
            ProfileMenuTile(
              icon: Icons.location_on_outlined,
              title: 'Address',
              subtitle: profile.address ?? '-',
            ),
            ProfileMenuTile(
              icon: Icons.family_restroom_outlined,
              title: 'Guardian Name',
              subtitle: profile.guardianName ?? '-',
            ),
            ProfileMenuTile(
              icon: Icons.contact_phone_outlined,
              title: 'Guardian Phone',
              subtitle: profile.guardianPhone ?? '-',
            ),
          ],
        ),
      ),
    );
  }
}
