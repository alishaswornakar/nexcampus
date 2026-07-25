import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final int totalClasses;
  final int present;
  final int absent;
  final int late;

  const AttendanceSummaryCard({
    super.key,
    required this.totalClasses,
    required this.present,
    required this.absent,
    required this.late,
  });

  static const Color _presentColor = Color(0xFF16A34A);
  static const Color _absentColor = Color(0xFFDC2626);
  static const Color _lateColor = Color(0xFFD97706);

  double get attendancePercentage {
    if (totalClasses == 0) return 0;
    return (present / totalClasses) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = attendancePercentage;
    final ringColor = percentage >= 75 ? _presentColor : _absentColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, size: 18, color: AppTheme.secondary),
              SizedBox(width: 8),
              Text(
                'Attendance Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 92,
                      height: 92,
                      child: CircularProgressIndicator(
                        value: (percentage / 100).clamp(0.0, 1.0),
                        strokeWidth: 8,
                        backgroundColor: AppTheme.border,
                        valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          percentage >= 75 ? 'Good' : 'Low',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ringColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _statRow(
                      icon: Icons.event_note_rounded,
                      label: 'Total Classes',
                      value: totalClasses,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 10),
                    _statRow(
                      icon: Icons.check_circle_rounded,
                      label: 'Present',
                      value: present,
                      color: _presentColor,
                    ),
                    const SizedBox(height: 10),
                    _statRow(
                      icon: Icons.cancel_rounded,
                      label: 'Absent',
                      value: absent,
                      color: _absentColor,
                    ),
                    const SizedBox(height: 10),
                    _statRow(
                      icon: Icons.schedule_rounded,
                      label: 'Late',
                      value: late,
                      color: _lateColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statRow({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
