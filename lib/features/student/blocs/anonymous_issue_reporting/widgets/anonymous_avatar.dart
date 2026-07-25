// lib/features/student/blocs/anonymous_issue_reporting/widgets/anonymous_avatar.dart
import 'package:flutter/material.dart';

import '../utils/anonymous_identity.dart';

/// Circle avatar used instead of a profile photo everywhere in this
/// feature. Uses a masked/incognito icon so no visual hint of identity is
/// ever given, colored deterministically from [seed] just for variety.
class AnonymousAvatar extends StatelessWidget {
  const AnonymousAvatar({super.key, required this.seed, this.radius = 18});

  final String seed;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = AnonymousIdentity.colorFor(seed);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.12),
      child: Icon(
        Icons.theater_comedy_outlined,
        size: radius,
        color: color,
      ),
    );
  }
}
