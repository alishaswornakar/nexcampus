import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/widgets/student_card.dart';

import '../blocs/class/class_bloc.dart';
import '../blocs/class/class_event.dart';
import '../blocs/class/class_state.dart';

import '../repository/classes_repository.dart';
import '../screens/student_detail_screen.dart';
import '../services/classes_service.dart';


class StudentListScreen extends StatefulWidget {
  final String department;
  final int semester;

  const StudentListScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClassesBloc(
        ClassesRepository(
          ClassesService(),
        ),
      )..add(
          LoadStudents(
            department: widget.department,
            semester: widget.semester,
          ),
        ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Semester ${widget.semester} Students",
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search student...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
              ),
            ),

            Expanded(
              child: BlocBuilder<ClassesBloc, ClassesState>(
                builder: (context, state) {
                  if (state is ClassesLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is ClassesError) {
                    return Center(
                      child: Text(state.message),
                    );
                  }

                  if (state is ClassesLoaded) {
                    final students = state.students.where((student) {
                      return student.fullName
                          .toLowerCase()
                          .contains(searchText);
                    }).toList();

                    if (students.isEmpty) {
                      return const Center(
                        child: Text("No students found"),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ClassesBloc>().add(
                              LoadStudents(
                                department: widget.department,
                                semester: widget.semester,
                              ),
                            );
                      },
                      child: ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          return StudentCard(
                            student: students[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentDetailScreen(
                                    student: students[index],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}