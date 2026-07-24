import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/bloc/course_bloc.dart';
import 'add_course_screen.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  final String department;
  final String semester;

  const CourseListScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseBloc>().add(
            LoadCoursesEvent(
              department: widget.department,
              semester: widget.semester,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          "${widget.department} - Semester ${widget.semester}",
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CourseBloc>(),
                child: AddCourseScreen(
                  department: widget.department,
                  semester: widget.semester,
                ),
              ),
            ),
          );
        },
      ),

      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is CourseAdded ||
              state is CourseDeleted ||
              state is CourseUpdated) {
            context.read<CourseBloc>().add(
                  LoadCoursesEvent(
                    department: widget.department,
                    semester: widget.semester,
                  ),
                );
          }
        },
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is CourseError) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is CoursesLoaded) {
            if (state.courses.isEmpty) {
              return const Center(
                child: Text(
                  "No courses available",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                final course = state.courses[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseDetailScreen(
                            course: course,
                          ),
                        ),
                      );
                    },

                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    title: Text(
                      course.courseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Course Code : ${course.courseCode}"),
                          const SizedBox(height: 4),
                          Text("Department : ${course.department}"),
                          const SizedBox(height: 4),
                          Text("Semester : ${course.semester}"),
                        ],
                      ),
                    ),

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "delete") {
                          context.read<CourseBloc>().add(
                                DeleteCourseEvent(course.id),
                              );
                        }

                        if (value == "details") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseDetailScreen(
                                course: course,
                              ),
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: "details",
                          child: Row(
                            children: [
                              Icon(Icons.visibility),
                              SizedBox(width: 10),
                              Text("View Details"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "delete",
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 10),
                              Text("Delete"),
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

          return const Center(
            child: Text("No data found"),
          );
        },
      ),
    );
  }
}