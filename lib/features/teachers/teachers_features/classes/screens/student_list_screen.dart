import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/widgets/student_card.dart';

import '../blocs/class/class_bloc.dart';
import '../blocs/class/class_event.dart';
import '../blocs/class/class_state.dart';
import '../repository/classes_repository.dart';
import '../screens/student_detail_screen.dart';
import '../services/classes_service.dart';

class StudentListScreen extends StatefulWidget {
  final String department;
  final String semester;

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
        backgroundColor: const Color(0xffF5F7FA),

        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: Text(
            "Semester ${widget.semester} Students",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final bool isTablet = width >= 600;
            final bool isDesktop = width >= 1000;

            final horizontalPadding = isDesktop
                ? 60.0
                : isTablet
                    ? 30.0
                    : 16.0;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 900 : double.infinity,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        18,
                        horizontalPadding,
                        10,
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchText = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search by student name",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchText.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {
                                      searchText = "";
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
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
                              child: Text(
                                state.message,
                                style: const TextStyle(fontSize: 16),
                              ),
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.group_off,
                                      size: 70,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "No students found",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
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
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: 10,
                                ),
                                children: [
                                  Text(
                                    "${students.length} Students",
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  ...students.map(
                                    (student) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 14),
                                      child: StudentCard(
                                        student: student,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  StudentDetailScreen(
                                                student: student,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
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
          },
        ),
      ),
    );
  }
}