import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';

class StudentDetailScreen extends StatelessWidget {
  final StudentModel student;

  const StudentDetailScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Student Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final bool isMobile = width < 600;
          final bool isTablet = width >= 600 && width < 1024;
          final bool isDesktop = width >= 1024;

          final horizontalPadding = isDesktop
              ? 50.0
              : isTablet
                  ? 35.0
                  : 18.0;

          final avatarRadius = isDesktop
              ? 75.0
              : isTablet
                  ? 65.0
                  : 55.0;

          final titleSize = isDesktop
              ? 32.0
              : isTablet
                  ? 28.0
                  : 24.0;

          final subtitleSize = isDesktop
              ? 18.0
              : isTablet
                  ? 17.0
                  : 15.0;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Hero(
                      tag: student.uid,
                      child: CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: student.photoUrl.isNotEmpty
                            ? NetworkImage(student.photoUrl)
                            : null,
                        child: student.photoUrl.isEmpty
                            ? Icon(
                                Icons.person,
                                size: avatarRadius,
                                color: AppTheme.primary,
                              )
                            : null,
                      ),
                    ),

                    SizedBox(height: isMobile ? 18 : 24),

                    Text(
                      student.fullName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${student.department} Student",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: isMobile ? 30 : 40),

                    _InfoCard(
                      icon: Icons.email_outlined,
                      title: "EMAIL ADDRESS",
                      value: student.email,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      onCopy: () {
                        Clipboard.setData(
                          ClipboardData(text: student.email),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Email copied"),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _InfoCard(
                      icon: Icons.school_outlined,
                      title: "DEPARTMENT",
                      value: student.department,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                    ),

                    const SizedBox(height: 16),

                    _InfoCard(
                      icon: Icons.calendar_month_outlined,
                      title: "CURRENT SEMESTER",
                      value: "Semester ${student.semester}",
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                    ),

                    const SizedBox(height: 16),

                    _InfoCard(
                      icon: Icons.badge_outlined,
                      title: "STUDENT ID",
                      value: "Roll: ${student.roll}",
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback? onCopy;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.isTablet,
    required this.isDesktop,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final iconBox = isDesktop
        ? 60.0
        : isTablet
            ? 56.0
            : 50.0;

    final titleSize = isDesktop
        ? 13.0
        : isTablet
            ? 12.5
            : 11.0;

    final valueSize = isDesktop
        ? 18.0
        : isTablet
            ? 17.0
            : 15.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isDesktop
            ? 22
            : isTablet
                ? 20
                : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffE9ECF8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: const Color(0xffD7DDF8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: isDesktop
                  ? 30
                  : isTablet
                      ? 28
                      : 24,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy_outlined),
              color: Colors.grey.shade700,
              tooltip: "Copy",
            ),
        ],
      ),
    );
  }
}