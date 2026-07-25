import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/bloc/course_bloc.dart';
import '../models/course_model.dart';

class AddCourseScreen extends StatefulWidget {
  final String department;
  final String semester;

  const AddCourseScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _courseNameController =
      TextEditingController();

  final TextEditingController _courseCodeController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String teacherId = "";
  String teacherName = "";

  bool isLoadingTeacher = true;

  @override
  void initState() {
    super.initState();
    _loadTeacher();
  }

  Future<void> _loadTeacher() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return;
      }

      teacherId = user.uid;

      final teacherDoc = await _firestore
          .collection("users")
          .doc(user.uid)
          .get();

      if (teacherDoc.exists) {
        teacherName = teacherDoc.data()?["fullName"] ?? "";
      }

      setState(() {
        isLoadingTeacher = false;
      });
    } catch (e) {
      setState(() {
        isLoadingTeacher = false;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load teacher: $e",
          ),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(icon),

      filled: true,

      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),

        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: Colors.blue,
          width: 2,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        return BlocListener<CourseBloc, CourseState>(
      listener: (context, state) {
        if (state is CourseAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Course added successfully"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }

        if (state is CourseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FA),

        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: const Text("Add Course"),
        ),

        body: isLoadingTeacher
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const SizedBox(height: 5),

                      const Text(
                        "Create New Course",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Teacher : $teacherName",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 30),

                      TextFormField(
                        controller:
                            _courseNameController,

                        decoration: _inputDecoration(
                          label: "Course Name",
                          icon: Icons.menu_book,
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return "Enter course name";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        controller:
                            _courseCodeController,

                        decoration: _inputDecoration(
                          label: "Course Code",
                          icon: Icons.code,
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return "Enter course code";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        controller:
                            _descriptionController,

                        maxLines: 5,

                        decoration: _inputDecoration(
                          label: "Description",
                          icon: Icons.description,
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return "Enter description";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),

                        child: ListTile(
                          leading: const Icon(
                            Icons.school,
                            color: Colors.blue,
                          ),

                          title: const Text(
                            "Department",
                          ),

                          subtitle: Text(
                            widget.department,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),

                        child: ListTile(
                          leading: const Icon(
                            Icons.calendar_today,
                            color: Colors.orange,
                          ),

                          title: const Text(
                            "Semester",
                          ),

                          subtitle: Text(
                            "Semester ${widget.semester}",
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      BlocBuilder<CourseBloc, CourseState>(
                        builder: (context, state) {
                          final loading = state is CourseLoading;

                          return SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: loading
                                  ? null
                                  : () {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      final course = CourseModel(
                                        id: FirebaseFirestore.instance
                                            .collection("courses")
                                            .doc()
                                            .id,
                                        courseName: _courseNameController.text.trim(),
                                        courseCode: _courseCodeController.text.trim(),
                                        description: _descriptionController.text.trim(),
                                        department: widget.department,
                                        semester: widget.semester,
                                        teacherId: teacherId,
                                        teacherName: teacherName,
                                        createdAt: DateTime.now(),
                                      );

                                      context.read<CourseBloc>().add(
                                            AddCourseEvent(course),
                                          );
                                    },
                              icon: loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(
                                loading ? "Saving..." : "Save Course",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
                      