import 'package:flutter/material.dart';
import '../model/user_profile_model.dart';
import 'profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ProfileAvatar(photoUrl: profile.photoUrl, fullName: profile.fullName),
        const SizedBox(height: 12),
        Text(
          profile.fullName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (profile.studentId != null) ...[
          const SizedBox(height: 4),
          Text(
            'ID: ${profile.studentId}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
