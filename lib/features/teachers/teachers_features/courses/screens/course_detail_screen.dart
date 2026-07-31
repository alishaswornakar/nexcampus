// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/assignments/screens/assignment_subject_screen.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/attendance/screens/attendance_subject_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/screens/student_list_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/screens/notes_screen.dart' ;

import '../models/course_model.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: Text(course.courseName),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// HEADER
            Card(
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [

                    const CircleAvatar(
                      radius: 38,
                      backgroundColor:
                          AppTheme.primary,

                      child: Icon(
                        Icons.menu_book,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      course.courseName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      course.courseCode,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Divider(),

                    ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      title:
                          const Text("Teacher"),
                      subtitle:
                          Text(course.teacherName),
                    ),

                    ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.school,
                        color: Colors.orange,
                      ),
                      title:
                          const Text("Department"),
                      subtitle:
                          Text(course.department),
                    ),

                    ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Colors.green,
                      ),
                      title:
                          const Text("Semester"),
                      subtitle: Text(
                        "Semester ${course.semester}",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Course Modules",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 18),
            GridView.count(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisCount: 2,
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  childAspectRatio: 0.78,

  children: [

    _buildModuleCard(
      context,
      title: "Notes",
      subtitle: "Upload & Manage",
      icon: Icons.description,
      color: Colors.blue,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteScreen(course:course
              
            ),
          ),
        );
      },
    ),

    _buildModuleCard(
      context,
      title: "Assignments",
      subtitle: "Manage Assignments",
      icon: Icons.assignment,
      color: Colors.orange,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AssignmentSubjectScreen(
              department: course.department,
              semester: course.semester,
            ),
          ),
        );
      },
    ),

    _buildModuleCard(
      context,
      title: "Attendance",
      subtitle: "Student Attendance",
      icon: Icons.fact_check,
      color: Colors.green,
      onTap: () {
       Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttendanceSubjectScreen(
              department: course.department,
              semester: course.semester,
            ),
          ),
        );
      },
    ),

    _buildModuleCard(
      context,
      title: "Students",
      subtitle: "Enrolled Students",
      icon: Icons.groups,
      color: Colors.deepPurple,
      onTap: () {
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentListScreen(department: course.department, semester: course.semester),
          ),
        );
      },
    ),
  ],
),

const SizedBox(height: 28),

const Text(
  "Course Information",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  ),

  child: Padding(
    padding: const EdgeInsets.all(18),

    child: Column(
      children: [

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.code,
            color: Colors.blue,
          ),
          title: const Text("Course Code"),
          subtitle: Text(course.courseCode),
        ),

        const Divider(),

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.description,
            color: Colors.orange,
          ),
          title: const Text("Description"),
          subtitle: Text(course.description),
        ),

        const Divider(),

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.access_time,
            color: Colors.green,
          ),
          title: const Text("Created"),
          subtitle: Text(
            "${course.createdAt.day}/${course.createdAt.month}/${course.createdAt.year}",
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(.12),
              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Open",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: color,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}