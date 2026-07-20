import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/assignments/models/subject_model.dart';

import '../blocs/bloc/attendance_bloc.dart';
import '../repositories/attendance_repository.dart';
import '../screens/attendance_history_screen.dart';
import '../screens/attendance_mark_screen.dart';
import '../services/attendance_service.dart';

class AttendanceSubjectScreen extends StatelessWidget {
  final String department;
  final String semester;

  const AttendanceSubjectScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttendanceBloc(
        AttendanceRepository(
          AttendanceService(),
        ),
      )..add(
          LoadSubjectsEvent(
            department: department,
            semester: semester,
          ),
        ),
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text("Select Subject"),
        ),
        body: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is AttendanceError) {
              return Center(
                child: Text(state.message),
              );
            }

            if (state is AttendanceSubjectsLoaded) {
              if (state.subjects.isEmpty) {
                return const Center(
                  child: Text(
                    "No Subjects Found",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.subjects.length,
                itemBuilder: (context, index) {
                  final SubjectModel subject = state.subjects[index];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(
                          Icons.menu_book,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        subject.subject,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Semester $semester",
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == "mark") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MarkAttendanceScreen(
                                  department: department,
                                  semester: int.parse(semester),
                                  subjectId: subject.id,
                                  subjectName: subject.subject,
                                ),
                              ),
                            );
                          }

                          if (value == "history") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AttendanceHistoryScreen(
                                  department: department,
                                  semester: semester,
                                  subjectId: subject.id,
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: "mark",
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline),
                                SizedBox(width: 10),
                                Text("Mark Attendance"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: "history",
                            child: Row(
                              children: [
                                Icon(Icons.history),
                                SizedBox(width: 10),
                                Text("Attendance History"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}