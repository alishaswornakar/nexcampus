import 'package:flutter/material.dart';
import '../model/user_profile_model.dart';
import 'profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileHeader({super.key, required this.profile});

  String? get _subtitle {
    final dept = profile.department?.trim();
    final sem = profile.semester?.trim();
    if (dept == null || dept.isEmpty) {
      return (sem != null && sem.isNotEmpty) ? 'SEMESTER $sem' : null;
    }
    if (sem == null || sem.isEmpty) return dept.toUpperCase();
    return '${dept.toUpperCase()} - SEMESTER $sem';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = _subtitle;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 32, bottom: 24, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4FC3F7), Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          ProfileAvatar(
            uid: profile.uid,
            photoUrl: profile.photoUrl,
            fullName: profile.fullName,
            radius: 52,
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              profile.fullName,
              key: ValueKey(profile.fullName),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
