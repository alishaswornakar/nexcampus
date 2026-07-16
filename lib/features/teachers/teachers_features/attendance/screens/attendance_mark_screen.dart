// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/attendance/models/attendance_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/models/attendancestudent_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/repositories/attendance_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/screens/attendance_history_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/services/attendance_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/widgets/attendance_search_bar.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/widgets/attendance_student_tile.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/widgets/attendance_summary_card.dart';
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

  final TextEditingController searchController =
      TextEditingController();

  final Map<String, bool> attendance = {};

  String search = "";

  bool isSaving = false;

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
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
  elevation: 0,
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
  centerTitle: true,

  title: Column(
    children: [
      Text(
        widget.department,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      Text(
        "Semester ${widget.semester}",
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    ],
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
              ),
            );
          }

          final students = snapshot.data!;
          // Initialize attendance map for new students
for (final student in students) {
  attendance.putIfAbsent(student.uid, () => false);
}

final filteredStudents = students.where((student) {
  return student.fullName
          .toLowerCase()
          .contains(search.toLowerCase()) ||
      student.roll
          .toLowerCase()
          .contains(search.toLowerCase());
}).toList();

final presentStudents = getPresentCount();
final absentStudents = getAbsentCount(students.length);

return Column(
  children: [

    Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [

          Text(
            DateFormat(
              "EEEE, dd MMMM yyyy",
            ).format(DateTime.now()),
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 15),

          AttendanceSummaryCard(
            totalStudents: students.length,
            presentStudents: presentStudents,
            absentStudents: absentStudents,
          ),
        ],
      ),
    ),

    AttendanceSearchBar(
  controller: searchController,
  onChanged: (value) {
    setState(() {
      search = value;
    });
  },
  onClear: () {
    searchController.clear();
    setState(() {
      search = "";
    });
  },
),
    Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 16,
  ),
  child: Row(
    children: [

      Expanded(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
          ),
          icon: const Icon(Icons.done_all),
          label: const Text("All Present"),
          onPressed: () {

            for (final student in students) {
              attendance[student.uid] = true;
            }

            setState(() {});
          },
        ),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
          ),
          icon: const Icon(Icons.close),
          label: const Text("All Absent"),
          onPressed: () {

            for (final student in students) {
              attendance[student.uid] = false;
            }

            setState(() {});
          },
        ),
      ),

    ],
  ),
),

const SizedBox(height: 10),
Expanded(
  child: ListView.builder(
    padding: const EdgeInsets.only(
      bottom: 100,
    ),
    itemCount: filteredStudents.length,
    itemBuilder: (context, index) {

      final student = filteredStudents[index];

      return AttendanceStudentTile(
        student: student,
        present:
            attendance[student.uid] ?? false,
        onChanged: (value) {
          setState(() {
            attendance[student.uid] = value;
          });
        },
      );
    },
  ),
),

],
);
},
),
floatingActionButton:
    FloatingActionButton.extended(
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
  icon: isSaving
      ? const SizedBox(
          width: 18,
          height: 18,
          child:
              CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
      : const Icon(Icons.save),
  label: Text(
    isSaving
        ? "Saving..."
        : "Save Attendance",
  ),
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
            date: DateTime.now(),
            students: attendanceStudents,
          );

          final save = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Save Attendance"),
                  content: const Text(
                    "Are you sure you want to save today's attendance?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
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

          ScaffoldMessenger.of(context).showSnackBar(
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
} // ← closes build()

} // ← closes _MarkAttendanceScreenState

 // ← closes MarkAttendanceScreen
