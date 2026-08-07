// lib/features/student/blocs/digital_queue/widgets/estimated_wait_card.dart

import 'package:flutter/material.dart';

class EstimatedWaitCard extends StatelessWidget {
  const EstimatedWaitCard({
    super.key,
    required this.queuePosition,
  });

  final int queuePosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        return _InfoTile(
          icon: Icons.person_outline,
          label: 'Position',
          value: '$queuePosition',
          iconColor: theme.colorScheme.primary,
          isSmallScreen: isSmallScreen,
          isTablet: isTablet,
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    required this.isSmallScreen,
    required this.isTablet,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final bool isSmallScreen;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 10 : (isTablet ? 16 : 12),
        horizontal: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 16 : (isTablet ? 24 : 20),
            color: iconColor ?? theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : (isTablet ? 22 : 18),
              letterSpacing: -0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: isSmallScreen ? 10 : (isTablet ? 13 : 11),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
