// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/attendance/models/attendance_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/models/attendancestudent_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/repositories/attendance_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/screens/attendance_history_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/services/attendance_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/widgets/attendance_student_tile.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String department;
  final int semester;
  final String subjectId;
  final String subjectName;

  const MarkAttendanceScreen({
    super.key,
    required this.department,
    required this.semester,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final AttendanceRepository repository = AttendanceRepository(
    AttendanceService(),
  );

  final TextEditingController searchController = TextEditingController();

  final Map<String, bool> attendance = {};

  String search = "";

  bool isSaving = false;

  bool selectAllPresent = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  int getPresentCount() {
    return attendance.values.where((e) => e).length;
  }

  int getAbsentCount(int total) {
    return total - getPresentCount();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        elevation: 0,

        backgroundColor: AppTheme.primary,

        foregroundColor: Colors.white,

        centerTitle: true,

        title: const Text(
          "Mark Attendance",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            tooltip: "Attendance History",
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendanceHistoryScreen(
                    department: widget.department,
                    semester: widget.semester.toString(),
                    subjectId: widget.subjectId,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<StudentModel>>(
        stream: repository.getStudents(
          department: widget.department,
          semester: widget.semester,
        ),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No students found"));
          }

          final students = snapshot.data!;

          for (final student in students) {
            attendance.putIfAbsent(student.uid, () => false);
          }

          final filteredStudents = students.where((student) {
            return student.fullName.toLowerCase().contains(
                  search.toLowerCase(),
                ) ||
                student.roll.toLowerCase().contains(search.toLowerCase());
          }).toList();

          //final presentStudents = getPresentCount();

          //final absentStudents = getAbsentCount(students.length);

          Widget summaryCard({
            required String title,
            required String value,
            required IconData icon,
            required Color color,
          }) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 24),

                  const SizedBox(height: 8),

                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * .045,
              vertical: height * .02,
            ),

            child: Column(
              children: [
                /// Subject Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.subjectName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        DateFormat("EEEE, dd MMM yyyy").format(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * .025),

                /// Search Student
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      search = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search student by name or roll",

                    prefixIcon: const Icon(Icons.search),

                    suffixIcon: search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();

                              setState(() {
                                search = "";
                              });
                            },
                          )
                        : null,

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),

                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      borderSide: BorderSide(
                        color: AppTheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                /// Attendance Summary Card
                SizedBox(height: height * .025),

                /// Students Header
                Row(
                  children: [
                    const Text(
                      "Students",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "${filteredStudents.length} Students",
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * .02),

                /// Students List
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.only(bottom: height * .13),
                    itemCount: filteredStudents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),

                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];

                      final present = attendance[student.uid] ?? false;

                      return AttendanceStudentTile(
                        student: student,
                        present: present,
                        onChanged: (value) {
                          setState(() {
                            attendance[student.uid] = value;

                            /// Update switch automatically
                            selectAllPresent = attendance.values.every(
                              (e) => e,
                            );
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,

        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save_rounded),

        label: Text(isSaving ? "Saving..." : "Save Attendance"),

        onPressed: isSaving
            ? null
            : () async {
                setState(() {
                  isSaving = true;
                });

                try {
                  final students = await repository
                      .getStudents(
                        department: widget.department,
                        semester: widget.semester,
                      )
                      .first;

                  final attendanceStudents = students.map((student) {
                    return AttendanceStudentModel(
                      uid: student.uid,
                      fullName: student.fullName,
                      roll: student.roll,
                      photoUrl: student.photoUrl,
                      isPresent: attendance[student.uid] ?? false,
                    );
                  }).toList();

                  final attendanceModel = AttendanceModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    department: widget.department,
                    semester: widget.semester.toString(),
                    subjectId: widget.subjectId,
                    subjectName: widget.subjectName,
                    teacherId: FirebaseAuth.instance.currentUser!.uid,
                    date: DateTime.now(),
                    students: attendanceStudents,
                  );

                  final save =
                      await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          title: const Text("Save Attendance"),
                          content: const Text(
                            "Are you sure you want to save today's attendance?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Save"),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (!save) {
                    setState(() {
                      isSaving = false;
                    });

                    return;
                  }

                 await repository.saveAttendance(attendanceModel);

if (!mounted) return;

/// Calculate actual attendance summary
final totalCount = attendanceStudents.length;

final presentCount = attendanceStudents
    .where((student) => student.isPresent)
    .length;

final absentCount = totalCount - presentCount;

/// Success Dialog
await showDialog(
  context: context,
  barrierDismissible: false,
  builder: (dialogContext) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Success Icon
            Container(
              height: 80,
              width: 80,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 42,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "Attendance Submitted",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Present: $presentCount/$totalCount",
              style: const TextStyle(
                fontSize: 20,
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Absent: $absentCount",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 28),

            /// View Details
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceHistoryScreen(
                        department: widget.department,
                        semester: widget.semester.toString(),
                        subjectId: widget.subjectId,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "View Details",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// Return to Dashboard
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Return to Dashboard",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
);
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(e.toString()),
                    ),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      isSaving = false;
                    });
                  }
                }
              },
      ),
    );
  }
}
