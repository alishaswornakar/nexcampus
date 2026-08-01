// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/cloudinary_service.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_event.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_state.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/model/note_model.dart';

import '../../courses/models/course_model.dart';

class AddNoteScreen extends StatefulWidget {
  final CourseModel course;

  const AddNoteScreen({super.key, required this.course});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  final _descriptionController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? selectedFile;

  String fileName = "";

  String teacherName = "";

  bool loadingTeacher = true;

  @override
  void initState() {
    super.initState();
    _loadTeacher();
  }

  Future<void> _loadTeacher() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final doc = await _firestore.collection("users").doc(user.uid).get();

    teacherName = doc.data()?["fullName"] ?? "";

    setState(() {
      loadingTeacher = false;
    });
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,

      allowedExtensions: const [
        "pdf",
        "doc",
        "docx",
        "ppt",
        "pptx",
        "jpg",
        "jpeg",
        "png",
      ],
    );

    if (result == null) return;

    selectedFile = File(result.files.single.path!);

    fileName = result.files.single.name;

    setState(() {});
  }

  InputDecoration decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(icon, color: AppTheme.primary),

      filled: true,

      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  //==========================
  // PART 2 STARTS HERE
  //==========================

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Note uploaded successfully"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }

        if (state is NoteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },

      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FA),

        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: const Text("Upload Note"),
        ),

        body: loadingTeacher
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final bool isTablet = width >= 600;

                  final bool isDesktop = width >= 1000;

                  final horizontalPadding = isDesktop
                      ? 42.0
                      : isTablet
                      ? 30.0
                      : 18.0;

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 900 : 700,
                      ),

                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),

                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,

                          vertical: isTablet ? 28 : 20,
                        ),

                        child: Form(
                          key: _formKey,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                "Upload Course Material",

                                style: TextStyle(
                                  fontSize: isDesktop
                                      ? 30
                                      : isTablet
                                      ? 28
                                      : 24,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Upload PDFs, PPTs, DOC files and Images for students.",

                                style: TextStyle(
                                  color: Colors.grey.shade600,

                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),

                              SizedBox(height: isTablet ? 30 : 22),

                              Card(
                                elevation: 2,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),

                                child: Padding(
                                  padding: EdgeInsets.all(isTablet ? 20 : 16),

                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blue.shade100,

                                          child: const Icon(
                                            Icons.book,

                                            color: AppTheme.primary,
                                          ),
                                        ),

                                        title: const Text("Course"),

                                        subtitle: Text(
                                          widget.course.courseName,
                                        ),
                                      ),

                                      const Divider(),

                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blue.shade100,

                                          child: const Icon(
                                            Icons.school,

                                            color: AppTheme.primary,
                                          ),
                                        ),

                                        title: const Text("Department"),

                                        subtitle: Text(
                                          widget.course.department,
                                        ),
                                      ),

                                      const Divider(),

                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blue.shade100,

                                          child: const Icon(
                                            Icons.calendar_month,

                                            color: AppTheme.primary,
                                          ),
                                        ),

                                        title: const Text("Semester"),

                                        subtitle: Text(widget.course.semester),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: isTablet ? 30 : 24),
                              TextFormField(
                                controller: _titleController,

                                decoration: decoration("Title", Icons.title),

                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Enter title";
                                  }

                                  return null;
                                },
                              ),

                              SizedBox(height: isTablet ? 20 : 18),

                              TextFormField(
                                controller: _descriptionController,

                                maxLines: isTablet ? 5 : 4,

                                decoration: decoration(
                                  "Description",

                                  Icons.description,
                                ),

                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Enter description";
                                  }

                                  return null;
                                },
                              ),

                              SizedBox(height: isTablet ? 28 : 22),

                              Text(
                                "Attachment",

                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size.fromHeight(
                                    isTablet ? 60 : 55,
                                  ),

                                  side: BorderSide(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),

                                onPressed: pickFile,

                                icon: const Icon(
                                  Icons.attach_file,

                                  color: AppTheme.primary,
                                ),

                                label: Text(
                                  fileName.isEmpty
                                      ? "Choose PDF / DOC / PPT / Image"
                                      : fileName,

                                  overflow: TextOverflow.ellipsis,

                                  maxLines: 1,

                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,

                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              if (selectedFile != null) ...[
                                SizedBox(height: isTablet ? 18 : 14),

                                Container(
                                  width: double.infinity,

                                  padding: EdgeInsets.all(isTablet ? 18 : 14),

                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha:.08),

                                    borderRadius: BorderRadius.circular(14),

                                    border: Border.all(
                                      color: Colors.green.withValues(alpha:.25),
                                    ),
                                  ),

                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,

                                        color: Colors.green,
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: Text(
                                          fileName,

                                          maxLines: 2,

                                          overflow: TextOverflow.ellipsis,

                                          style: TextStyle(
                                            fontSize: isTablet ? 15 : 14,

                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              SizedBox(height: isTablet ? 36 : 30),
                              BlocBuilder<NoteBloc, NoteState>(
                                builder: (context, state) {
                                  final bool loading = state is NoteLoading;

                                  return SizedBox(
                                    width: double.infinity,

                                    height: isTablet ? 60 : 55,

                                    child: ElevatedButton.icon(
                                      onPressed: loading ? null : uploadNote,

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,

                                        foregroundColor: Colors.white,

                                        elevation: 2,

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),

                                      icon: loading
                                          ? const SizedBox(
                                              width: 22,

                                              height: 22,

                                              child: CircularProgressIndicator(
                                                color: Colors.white,

                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.cloud_upload),

                                      label: Text(
                                        loading
                                            ? "Uploading..."
                                            : "Upload Note",

                                        style: TextStyle(
                                          fontSize: isTablet ? 17 : 15,

                                          fontWeight: FontWeight.w600,
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
                },
              ),
      ),
    );
  }

  Future<void> uploadNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a file.")));

      return;
    }

    try {
      final cloudinary = CloudinaryService();

      final result = await cloudinary.uploadFile(selectedFile!);

      final fileUrl = result["url"];

      final note = NoteModel(
        id: "",

        title: _titleController.text.trim(),

        description: _descriptionController.text.trim(),

        // department:
        //     widget.course.department,

        // semester:
        //     widget.course.semester,
        courseId: widget.course.id,

        courseName: widget.course.courseName,

        uploadedBy: teacherName,

        fileUrl: fileUrl,

        fileName: fileName,

        createdAt: DateTime.now(),
      );

      context.read<NoteBloc>().add(AddNoteEvent(note));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }
  }
}
