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
  final size = MediaQuery.of(context).size;
  final width = size.width;
  final height = size.height;

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
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      title: Text(
        getTitle(),
        style: TextStyle(
          fontSize: width * 0.05,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.06,
          vertical: height * 0.025,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

         Text(
  "Select Academic Details",
  style: TextStyle(
    fontSize: width * 0.07,
    fontWeight: FontWeight.bold,
    color: AppTheme.primary,
  ),
),

SizedBox(height: height * 0.01),

Text(
  "Choose your department and semester to continue.",
  style: TextStyle(
    color: Colors.grey.shade600,
    fontSize: width * 0.038,
    height: 1.5,
  ),
),

SizedBox(height: height * 0.045),

Text(
  "Department",
  style: TextStyle(
    fontSize: width * 0.040,
    fontWeight: FontWeight.w600,
  ),
),

SizedBox(height: height * 0.012),

DropdownButtonFormField<String>(
  value: selectedDepartment,
  isExpanded: true,
  decoration: InputDecoration(
    hintText: "Select Department",
    hintStyle: TextStyle(
      fontSize: width * 0.038,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(
      horizontal: width * 0.045,
      vertical: height * 0.020,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(width * 0.035),
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(width * 0.035),
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(width * 0.035),
      borderSide: const BorderSide(
        color: AppTheme.primary,
        width: 1.5,
      ),
    ),
  ),
  items: departments.keys.map((department) {
    return DropdownMenuItem<String>(
      value: department,
      child: Text(
        department,
        style: TextStyle(
          fontSize: width * 0.038,
        ),
      ),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedDepartment = value;
      selectedSemester = null;
    });
  },
),

SizedBox(height: height * 0.03),

Text(
  "Semester",
  style: TextStyle(
    fontSize: width * 0.040,
    fontWeight: FontWeight.w600,
  ),
),

SizedBox(height: height * 0.012),

DropdownButtonFormField<String>(
  value: selectedSemester,
  isExpanded: true,
  decoration: InputDecoration(
    hintText: "Select Semester",
    hintStyle: TextStyle(
      fontSize: width * 0.038,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(
      horizontal: width * 0.045,
      vertical: height * 0.020,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(width * 0.035),
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(width * 0.035),
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(width * 0.035),
      borderSide: const BorderSide(
        color: AppTheme.primary,
        width: 1.5,
      ),
    ),
  ),
  items: semesters.map((semester) {
    return DropdownMenuItem<String>(
      value: semester,
      child: Text(
        "Semester $semester",
        style: TextStyle(
          fontSize: width * 0.038,
        ),
      ),
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

SizedBox(height: height * 0.06),

SizedBox(
  width: double.infinity,
  height: height * 0.07,
  child: ElevatedButton.icon(
    icon: Icon(
      Icons.arrow_forward,
      size: width * 0.05,
    ),
    label: Text(
      "Continue",
      style: TextStyle(
        fontSize: width * 0.043,
        fontWeight: FontWeight.w600,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.035),
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

SizedBox(height: height * 0.02),
          ],
        ),
      ),
    ),
  );
}

void _navigateToFeature() {
  late final Widget screen;

  switch (widget.feature) {
    case FeatureType.attendance:
     screen = AttendanceSubjectScreen(department: selectedDepartment!,semester: selectedSemester!);
     break;
    case FeatureType.assignments:
      screen = AssignmentSubjectScreen(department: selectedDepartment!, semester: selectedSemester!);
      break;
    case FeatureType.courses:
      screen = CourseListScreen(department: selectedDepartment!, semester: selectedSemester!);
      break;
    case FeatureType.classes:
      screen = StudentListScreen(
        department: selectedDepartment!,
        semester: selectedSemester!,
      );
      break;
    case FeatureType.schedules:
      screen = TeacherScheduleScreen(
        department: selectedDepartment!,
        semester: selectedSemester!,
      );
      break;
    case FeatureType.notices:
      screen = const NoticeScreen();
      break;
    case FeatureType.students:
      screen = StudentListScreen(
        department: selectedDepartment!,
        semester: selectedSemester!,
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
