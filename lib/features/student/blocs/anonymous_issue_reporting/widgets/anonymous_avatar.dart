// lib/features/student/blocs/anonymous_issue_reporting/widgets/anonymous_avatar.dart
import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

/// Circle avatar used instead of a profile photo everywhere in this
/// feature. Always a plain, identity-free silhouette - no visual hint
/// of who the author is.
class AnonymousAvatar extends StatelessWidget {
  const AnonymousAvatar({super.key, required this.seed, this.radius = 18});

  final String seed;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.border,
      child: Icon(
        Icons.person_outline,
        size: radius,
        color: AppTheme.textSecondary,
      ),
    );
  }
}
