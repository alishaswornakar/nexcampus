// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/assignments/screens/assignment_subject_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/screens/attendance_subject_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/screens/student_list_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/screens/notes_screen.dart';

import '../models/course_model.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:AppTheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Course Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width * .05,
          vertical: height * .015,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            ///========================
            /// HEADER CARD
            ///========================

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(width * .06),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  CircleAvatar(
                    radius: width * .08,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: width * .09,
                    ),
                  ),

                  SizedBox(height: height * .02),

                  Text(
                    course.courseName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * .065,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: height * .012),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: Text(
                          course.courseCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: Text(
                          "Semester ${course.semester}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: height * .02),
                                    /// Live Student Count
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .where("role", isEqualTo: "student")
                        .where(
                          "department",
                          isEqualTo: course.department,
                        )
                        .where(
                          "semester",
                          isEqualTo: course.semester.toString(),
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      final studentCount =
                          snapshot.hasData
                              ? snapshot.data!.docs.length
                              : 0;
                      return Center(
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.groups_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),

                          Text(
                            "$studentCount Students",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            
                            child: Text(
                              course.department,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: height * .035),

            const Text(
              "Course Toolkit",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            _buildToolkitCard(
              context,
              title: "Attendance",
              subtitle: "Manage student attendance",
              icon: Icons.fact_check_rounded,
              color: AppTheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AttendanceSubjectScreen(
                      department: course.department,
                      semester: course.semester,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _buildToolkitCard(
              context,
              title: "Assignments",
              subtitle:
                  "Create and review assignments",
              icon: Icons.assignment_rounded,
              color: AppTheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AssignmentSubjectScreen(
                      department: course.department,
                      semester: course.semester,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _buildToolkitCard(
              context,
              title: "Course Files",
              subtitle: "Upload and manage notes",
              icon: Icons.description_rounded,
              color: AppTheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        NoteScreen(course: course),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _buildToolkitCard(
              context,
              title: "Students",
              subtitle: "View enrolled students",
              icon: Icons.groups_rounded,
              color:AppTheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StudentListScreen(
                      department: course.department,
                      semester: course.semester,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: height * .035),
                        ///========================
            /// COURSE INFORMATION
            ///========================

            const Text(
              "Course Information",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [

                  _buildInfoTile(
                    icon: Icons.code_rounded,
                    iconColor: AppTheme.primary,
                    title: "Course Code",
                    value: course.courseCode,
                  ),

                  const Divider(height: 28),

                  _buildInfoTile(
                    icon: Icons.school_rounded,
                    iconColor: AppTheme.primary,
                    title: "Department",
                    value: course.department,
                  ),

                  const Divider(height: 28),

                  _buildInfoTile(
                    icon: Icons.calendar_month_rounded,
                    iconColor: AppTheme.primary,
                    title: "Semester",
                    value: "Semester ${course.semester}",
                  ),

                  const Divider(height: 28),

                  _buildInfoTile(
                    icon: Icons.description_rounded,
                    iconColor:AppTheme.primary,
                    title: "Description",
                    value: course.description.isEmpty
                        ? "No description available"
                        : course.description,
                  ),

                  const Divider(height: 28),

                  _buildInfoTile(
                    icon: Icons.schedule_rounded,
                    iconColor: AppTheme.primary,
                    title: "Created On",
                    value:
                        "${course.createdAt.day}/${course.createdAt.month}/${course.createdAt.year}",
                  ),
                ],
              ),
            ),

            SizedBox(height: height * .04),
          ],
        ),
      ),
    );
  }
  Widget _buildToolkitCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  final width = MediaQuery.of(context).size.width;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: width * .045,
        vertical: width * .04,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: width * .14,
            height: width * .14,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: width * .075,
            ),
          ),

          SizedBox(width: width * .04),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff222222),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: width * .034,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildInfoTile({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String value,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),

      const SizedBox(width: 16),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff222222),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
}