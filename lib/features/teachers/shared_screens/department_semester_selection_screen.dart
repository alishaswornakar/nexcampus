import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/student/screens/attendance_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/screens/assignment_subject_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/screens/attendance_subject_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/screens/student_list_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/screens/courselist.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/screens/notes_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/screens/notice_screen.dart';


enum FeatureType {
  attendance,
  assignments,
  courses,
  classes,
  notes,
  notices,
  grades,
  students,
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

    final total =
        departments[selectedDepartment] ?? 8;

    return List.generate(
      total,
      (index) => "${index + 1}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xffF5F7FA,
      ),

      appBar: AppBar(
        title: const Text(
          "Select Department",
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose Department",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Select department to continue.",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            ...departments.entries.map(
              (department) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 15,
                  ),
                  child: _departmentCard(
                    title: department.key,
                    semesters:
                        department.value,
                    icon: department.key
                            .contains(
                                "Computer")
                        ? Icons.computer
                        : department.key
                                .contains(
                                    "Civil")
                            ? Icons
                                .engineering
                            : Icons
                                .architecture,
                  ),
                );
              },
            ),

            const SizedBox(height: 25),
                        /// Semester Selection
            if (selectedDepartment != null) ...[
              const Divider(),

              const SizedBox(height: 25),

              const Text(
                "Choose Semester",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Select semester for $selectedDepartment",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: semesters.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 2.3,
                ),
                itemBuilder: (context, index) {
                  final semester =
                      semesters[index];

                  final selected =
                      selectedSemester ==
                          semester;

                  return InkWell(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    onTap: () {
                      setState(() {
                        selectedSemester =
                            semester;
                      });
                    },
                    child: AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds: 250,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.blue
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                        border: Border.all(
                          color: selected
                              ? Colors.blue
                              : Colors.grey
                                  .shade300,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors
                                .black12,
                            blurRadius: 5,
                            offset:
                                Offset(
                              0,
                              2,
                            ),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Semester $semester",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color: selected
                                ? Colors.white
                                : Colors
                                    .black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.arrow_forward,
                ),
                label: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
                onPressed: () {
                  if (selectedDepartment ==
                          null ||
                      selectedSemester ==
                          null) {
                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
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

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _departmentCard({
    required String title,
    required int semesters,
    required IconData icon,
  }) {
    final selected =
        selectedDepartment == title;

    return InkWell(
      borderRadius:
          BorderRadius.circular(18),
      onTap: () {
        setState(() {
          selectedDepartment = title;
          selectedSemester = null;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? Colors.blue
              : Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Colors.blue
                : Colors.grey.shade300,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: selected
                  ? Colors.white
                  : Colors.blue.shade50,
              child: Icon(
                icon,
                color: Colors.blue,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: selected
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    "$semesters Semesters",
                    style: TextStyle(
                      color: selected
                          ? Colors.white70
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
    void _navigateToFeature() {
    final department = selectedDepartment!;
    final semester = selectedSemester!;

    Widget screen;

    switch (widget.feature) {
      case FeatureType.attendance:
        screen = AttendanceSubjectScreen(department: department, semester: semester);
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

      // case FeatureType.notes:
      //   screen = NoteScreen(
      //     department: department,
      //     semester: semester,
      //   );
      //   break;

      case FeatureType.notices:
        screen = const NoticeScreen(
          
        );
        break;

      // case FeatureType.grades:
      //   screen = GradeScreen(
      //     department: department,
      //     semester: semester,
      //   );
      //   break;

      case FeatureType.students:
        screen = StudentListScreen(
          department: department,
          semester: semester ,
        );
        break;
      case FeatureType.notes:
        // TODO: Handle this case.
        throw UnimplementedError();
      case FeatureType.grades:
        // TODO: Handle this case.
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