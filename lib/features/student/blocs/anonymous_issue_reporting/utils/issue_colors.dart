// lib/features/student/blocs/anonymous_issue_reporting/utils/issue_colors.dart
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_theme.dart';

class IssueColors {
  IssueColors._();

  static const Color skyBlue = AppTheme.secondary;
  static const Color skyBlueDark = AppTheme.primary;
  static Color get skyBlueLight => AppTheme.secondary.withValues(alpha: 0.08);
  static const Color background = AppTheme.background;
}
