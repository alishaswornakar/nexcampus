// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/models/attendance_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/models/attendancestudent_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/repositories/attendance_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/services/attendance_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/widgets/attendance_student_tile.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String department;
  final int semester;

  const MarkAttendanceScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  State<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState
    extends State<MarkAttendanceScreen> {

  final AttendanceRepository repository =
      AttendanceRepository(
        AttendanceService(),
      );

  final Map<String, bool> attendance = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "${widget.department}\nSemester ${widget.semester}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<List<StudentModel>>(
        stream: repository.getStudents(
          department: widget.department,
          semester: widget.semester,
        ),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No students found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final students = snapshot.data!;

          return Column(
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                color: Colors.white,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.done_all),
                  label: const Text(
                    "Mark All Present",
                  ),
                  onPressed: () {

                    for (final student in students) {
                      attendance[student.uid] = true;
                    }

                    setState(() {});
                  },
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: students.length,
                  itemBuilder: (_, index) {

                    final student = students[index];

                    return AttendanceStudentTile(
                      student: student,
                      present:
                          attendance[student.uid] ??
                              false,
                      onChanged: (value) {

                        attendance[student.uid] =
                            value;

                        setState(() {});
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
            floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save),
        label: const Text("Save Attendance"),
        onPressed: () async {
          try {
            final students = await repository
                .getStudents(
                  department: widget.department,
                  semester: widget.semester,
                )
                .first;

            final attendanceStudents =
                students.map((student) {
              return AttendanceStudentModel(
                uid: student.uid,
                fullName: student.fullName,
                roll: student.roll,
                photoUrl: student.photoUrl,
                isPresent:
                    attendance[student.uid] ?? false,
              );
            }).toList();

            final attendanceModel =
                AttendanceModel(
              id: DateTime.now()
                  .millisecondsSinceEpoch
                  .toString(),
              department: widget.department,
              semester: widget.semester.toString(),
              date: DateTime.now(),
              students: attendanceStudents,
            );

            await repository.saveAttendance(
              attendanceModel,
            );

            if (!mounted) return;

            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  "Attendance saved successfully!",
                ),
              ),
            );

            Navigator.pop(context);
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  e.toString(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
