// lib/features/student/blocs/digital_queue/widgets/current_token_card.dart

import 'package:flutter/material.dart';

class CurrentTokenCard extends StatelessWidget {
  const CurrentTokenCard({
    super.key,
    required this.tokenNumber,
    required this.serviceName,
    required this.counterName,
  });

  final int tokenNumber;
  final String serviceName;
  final String counterName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    return Column(
      children: [
        Text(
          serviceName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: isSmallScreen ? 16 : (isTablet ? 20 : 18),
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          counterName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: isSmallScreen ? 12 : (isTablet ? 14 : 13),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 14 : (isTablet ? 28 : 20),
            vertical: isSmallScreen ? 6 : (isTablet ? 14 : 10),
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha:0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Your Token',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: isSmallScreen ? 10 : (isTablet ? 14 : 12),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '#$tokenNumber',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: isSmallScreen ? 34 : (isTablet ? 50 : 42),
                  color: theme.colorScheme.primary,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
