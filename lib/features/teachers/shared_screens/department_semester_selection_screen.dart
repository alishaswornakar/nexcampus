import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/assignments/screens/assignment_subject_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/screens/attendance_subject_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/screens/student_list_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/screens/courselist.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/screens/notice_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/schedule/screens/teacher_schedule_screen.dart';

enum FeatureType {
  attendance,
  assignments,
  courses,
  classes,
  notes,
  notices,
  students,
  schedules,
}

class DepartmentSemesterSelectionScreen extends StatefulWidget {
  final FeatureType feature;

  const DepartmentSemesterSelectionScreen({
    super.key,
    required this.feature,
  });

  @override
  State<DepartmentSemesterSelectionScreen> createState() =>
      _DepartmentSemesterSelectionScreenState();
}

class _DepartmentSemesterSelectionScreenState
    extends State<DepartmentSemesterSelectionScreen> {
  final Map<String, int> departments = {
    "Computer Engineering": 8,
    "Civil Engineering": 8,
    "Architecture Engineering": 10,
  };

  String? selectedDepartment;
  String? selectedSemester;

  List<String> get semesters {
    if (selectedDepartment == null) {
      return [];
    }

    final total = departments[selectedDepartment] ?? 8;

    return List.generate(
      total,
      (index) => "${index + 1}",
    );
  }

  @override
  Widget build(BuildContext context) {
    String getTitle() {
      switch (widget.feature) {
        case FeatureType.attendance:
          return "Attendance";
        case FeatureType.assignments:
          return "Assignments";
        case FeatureType.courses:
          return "Courses";
        case FeatureType.classes:
          return "Classes";
        case FeatureType.notices:
          return "Notices";
        case FeatureType.schedules:
          return "Schedule";
        case FeatureType.students:
          return "Students";
        case FeatureType.notes:
          return "Notes";
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(getTitle()),
      ),

      body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Select Academic Details",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Choose your department and semester to continue.",
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 35),

          const Text(
            "Department",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue: selectedDepartment,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: "Select Department",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            items: departments.keys.map((department) {
              return DropdownMenuItem(
                value: department,
                child: Text(department),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDepartment = value;
                selectedSemester = null;
              });
            },
          ),

          const SizedBox(height: 25),

          const Text(
            "Semester",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
            initialValue: selectedSemester,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: "Select Semester",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            items: semesters.map((semester) {
              return DropdownMenuItem<String>(
                value: semester,
                child: Text("Semester $semester"),
              );
            }).toList(),
            onChanged: selectedDepartment == null
                ? null
                : (value) {
                    setState(() {
                      selectedSemester = value;
                    });
                  },
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                "Continue",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                if (selectedDepartment == null ||
                    selectedSemester == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please select both department and semester.",
                      ),
                    ),
                  );
                  return;
                }

                _navigateToFeature();
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
  ),
);}
void _navigateToFeature() {
  final department = selectedDepartment!;
  final semester = selectedSemester!;

  Widget screen;

  switch (widget.feature) {
    case FeatureType.attendance:
      screen = AttendanceSubjectScreen(
        department: department,
        semester: semester,
      );
      break;

    case FeatureType.assignments:
      screen = AssignmentSubjectScreen(
        department: department,
        semester: semester,
      );
      break;

    case FeatureType.courses:
      screen = CourseListScreen(
        department: department,
        semester: semester,
      );
      break;

    case FeatureType.classes:
      screen = StudentListScreen(
        department: department,
        semester: semester,
      );
      break;

    case FeatureType.schedules:
      screen = TeacherScheduleScreen(
        department: department,
        semester: semester,
      );
      break;

    case FeatureType.notices:
      screen = const NoticeScreen();
      break;

    case FeatureType.students:
      screen = StudentListScreen(
        department: department,
        semester: semester,
      );
      break;

    case FeatureType.notes:
      throw UnimplementedError();
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => screen,
    ),
  );
}
  }