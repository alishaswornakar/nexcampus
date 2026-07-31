import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/recent_notices_section.dart';
import 'package:nexcampus_app/features/student/widgets/bottom_nav_bar.dart';
import '../widgets/greeting_card.dart';
import 'package:nexcampus_app/features/student/widgets/weekly_schedule_section.dart';

class StudentDashboardScreen extends StatelessWidget {
  final User user;

  const StudentDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: AppTheme.primary,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(0.0),
            child: Padding(padding: EdgeInsets.all(16.0)),
          ),
        ),
      ),
      body: Column(
        children: [
          GreetingCard(studentId: user.uid),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const QuickAccessGrid(studentId: ''),
                  const SizedBox(height: 20),
                  const _UpcomingDeadlinesSection(),
                  const SizedBox(height: 24),
                  WeeklyScheduleSection(studentId: user.uid),
                  const SizedBox(height: 10),
                  const RecentNoticesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _UpcomingDeadlinesSection extends StatelessWidget {
  const _UpcomingDeadlinesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Upcoming Deadlines",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "VIEW ALL",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const _DeadlineCard(
          title: "Digital Logic Design Lab",
          description:
              "Submit the circuit simulation files and the final lab report...",
          badgeText: "DUE TOMORROW",
          badgeColor: Color(0xFFE05263),
          dueDate: "Oct 24, 11:59 PM",
        ),
        const SizedBox(height: 10),
        const _DeadlineCard(
          title: "DBMS Project Phase 1",
          description: "ER Diagram and Schema normalization documentation for",
          badgeText: "IN 3 DAYS",
          badgeColor: Color(0xFFF0A73A),
          dueDate: "Oct 28, 05:00 PM",
        ),
      ],
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final String title;
  final String description;
  final String badgeText;
  final Color badgeColor;
  final String dueDate;

  const _DeadlineCard({
    required this.title,
    required this.description,
    required this.badgeText,
    required this.badgeColor,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              dueDate,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
