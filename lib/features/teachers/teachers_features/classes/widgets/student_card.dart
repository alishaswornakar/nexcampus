import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/student_model.dart';

class StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isTablet = width >= 600;
    final bool isDesktop = width >= 1000;

    final double avatarRadius = isDesktop
        ? 34
        : isTablet
            ? 30
            : 26;

    final double titleSize = isDesktop
        ? 20
        : isTablet
            ? 18
            : 16;

    final double subtitleSize = isDesktop
        ? 15
        : isTablet
            ? 14
            : 13;

    final double padding = isDesktop
        ? 20
        : isTablet
            ? 18
            : 14;

    return Card(
      margin: EdgeInsets.only(
        bottom: isTablet ? 16 : 12,
      ),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha:.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.blue.shade100,
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

              SizedBox(width: isTablet ? 18 : 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            student.department,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: subtitleSize,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Semester ${student.semester}",
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Roll: ${student.roll}",
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: isTablet ? 12 : 8),

              Container(
                width: isTablet ? 42 : 36,
                height: isTablet ? 42 : 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha:.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}