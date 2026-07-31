// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';

class AttendanceStudentTile extends StatelessWidget {
  final StudentModel student;
  final bool present;
  final ValueChanged<bool> onChanged;

  const AttendanceStudentTile({
    super.key,
    required this.student,
    required this.present,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * .04,
          vertical: width * .035,
        ),

        child: Row(
          children: [

            /// Avatar
            CircleAvatar(
              radius: width * .07,
              backgroundColor:
                  AppTheme.primary.withOpacity(.12),

              backgroundImage:
                  student.photoUrl.isNotEmpty
                      ? NetworkImage(student.photoUrl)
                      : null,

              child: student.photoUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      color: AppTheme.primary,
                      size: width * .075,
                    )
                  : null,
            ),

            SizedBox(width: width * .04),

            /// Student Details
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    student.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * .043,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    student.roll,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: width * .033,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: width * .03),

            /// Present Button
            GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 200),

                width: width * .12,
                height: width * .12,

                decoration: BoxDecoration(
                  color: present
                      ? Colors.green
                      : Colors.green.withOpacity(.10),

                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: Center(
                  child: Text(
                    "P",
                    style: TextStyle(
                      color: present
                          ? Colors.white
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: width * .042,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: width * .025),

            /// Absent Button
            GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 200),

                width: width * .12,
                height: width * .12,

                decoration: BoxDecoration(
                  color: !present
                      ? Colors.red
                      : Colors.red.withOpacity(.10),

                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: Center(
                  child: Text(
                    "A",
                    style: TextStyle(
                      color: !present
                          ? Colors.white
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: width * .042,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}