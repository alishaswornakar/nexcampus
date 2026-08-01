import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/repository/course_repository.dart';

import '../blocs/bloc/course_bloc.dart';
import '../models/course_model.dart';

import '../services/course_service.dart';
import 'add_course_screen.dart';

class CourseScreen extends StatelessWidget {
  final String department;
  final String semester;

  const CourseScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseBloc(
        CourseRepository(
          CourseService(),
        ),
      )..add(
          LoadCoursesEvent(
            department: department,
            semester: semester,
          ),
        ),

      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FA),

        appBar: AppBar(
          title: Text(
            "Semester $semester Courses",
          ),
          centerTitle: true,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),

        floatingActionButton: FloatingActionButton.extended(
          backgroundColor:AppTheme.primary,

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<CourseBloc>(),
                  child: AddCourseScreen(
                    department: department,
                    semester: semester,
                  ),
                ),
              ),
            );
          },

          icon: const Icon(Icons.add),

          label: const Text("Add Course"),
        ),

        body: BlocBuilder<CourseBloc, CourseState>(
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
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [

                      Icon(
                        Icons.menu_book_outlined,
                        size: 90,
                        color: Colors.grey,
                      ),

                      SizedBox(height: 15),

                      Text(
                        "No Courses Added",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final List<CourseModel> courses =
                  state.courses;
                                return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),

                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(18),

                      onTap: () {
                        // Next:
                        // Open Course Detail Screen
                      },

                      child: Padding(
                        padding: const EdgeInsets.all(18),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Row(
                              children: [

                                Container(
                                  padding:
                                      const EdgeInsets.all(12),

                                  decoration: BoxDecoration(
                                    color: Colors.blue
                                        // ignore: deprecated_member_use
                                        .withOpacity(.1),

                                    borderRadius:
                                        BorderRadius.circular(
                                            12),
                                  ),

                                  child: const Icon(
                                    Icons.menu_book,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Text(
                                        course.courseName,
                                        style:
                                            const TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        course.courseCode,
                                        style: TextStyle(
                                          color: Colors
                                              .grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                PopupMenuButton<String>(
                                  onSelected: (value) {

                                    if (value == "edit") {
                                      // Next
                                    }

                                    if (value ==
                                        "delete") {
                                      // Next
                                    }
                                  },

                                  itemBuilder: (_) => const [

                                    PopupMenuItem(
                                      value: "edit",
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 8),
                                          Text("Edit"),
                                        ],
                                      ),
                                    ),

                                    PopupMenuItem(
                                      value: "delete",
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete),
                                          SizedBox(width: 8),
                                          Text("Delete"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Row(
                              children: [

                                const Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Colors.blue,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    course.teacherName,
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [

                                const Icon(
                                  Icons.school,
                                  size: 18,
                                  color: Colors.orange,
                                ),

                                const SizedBox(width: 8),

                                Text(
                                  course.department,
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [

                                const Icon(
                                  Icons.calendar_month,
                                  size: 18,
                                  color: Colors.green,
                                ),

                                const SizedBox(width: 8),

                                Text(
                                  "Semester ${course.semester}",
                                ),
                              ],
                            ),

                            const Divider(
                              height: 28,
                            ),

                            Text(
                              course.description,
                              maxLines: 3,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    Colors.grey.shade700,
                              ),
                            ),

                            const SizedBox(height: 15),

                            Row(
                              children: [

                                const Spacer(),

                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Next:
                                    // Open Details Screen
                                  },

                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.blue,
                                    foregroundColor:
                                        Colors.white,
                                  ),

                                  icon: const Icon(
                                      Icons.visibility),

                                  label:
                                      const Text("View"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
                          }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ignore: unused_element
  void _showDeleteDialog(
    BuildContext context,
    CourseModel course,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Course"),
        content: Text(
          "Are you sure you want to delete '${course.courseName}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);

              context.read<CourseBloc>().add(
                    DeleteCourseEvent(course.id),
                  );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}