import 'package:flutter/material.dart';
import '../model/user_profile_model.dart';

class ProfileCard extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(value: profile.semester ?? '-', label: 'Semester'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(value: profile.section ?? '-', label: 'Section'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            value: _shortDepartment(profile.department),
            label: 'Department',
          ),
        ),
      ],
    );
  }
}

String _shortDepartment(String? department) {
  if (department == null || department.trim().isEmpty) return '-';
  return department.trim().split(RegExp(r'\s+')).first;
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
