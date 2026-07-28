// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/cloudinary_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_event.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_state.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/model/note_model.dart';

import '../../courses/models/course_model.dart';

class AddNoteScreen extends StatefulWidget {
  final CourseModel course;

  const AddNoteScreen({
    super.key,
    required this.course,
  });

  @override
  State<AddNoteScreen> createState() =>
      _AddNoteScreenState();
}

class _AddNoteScreenState
    extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

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

    if (user == null) {
      return;
    }

    final doc = await _firestore
        .collection("users")
        .doc(user.uid)
        .get();

    teacherName =
        doc.data()?["fullName"] ?? "";

    setState(() {
      loadingTeacher = false;
    });
  }

  Future<void> pickFile() async {
    final result =
        await FilePicker.platform.pickFiles(

      type: FileType.custom,
      allowedExtensions: [
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

    selectedFile = File(
      result.files.single.path!,
    );

    fileName =
        result.files.single.name;

    setState(() {});
  }
Future<String> uploadFileToCloudinary(
  File file,
) async {
  // Replace this with your existing
  // Cloudinary upload function.

  // Example:
  //
  // return await CloudinaryService.uploadFile(file);

  throw UnimplementedError(
    "Connect your Cloudinary upload method here.",
  );
}
  InputDecoration decoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      focusedBorder:
          const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.blue,
          width: 2,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
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
          title: const Text("Upload Note"),
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),

        body: loadingTeacher
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
                      const Text(
                        "Upload Course Material",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        widget.course.courseName,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 25),

                      TextFormField(
                        controller: _titleController,
                        decoration: decoration(
                          "Title",
                          Icons.title,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return "Enter title";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        controller:
                            _descriptionController,
                        maxLines: 4,
                        decoration: decoration(
                          "Description",
                          Icons.description,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return "Enter description";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      Card(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.book,
                            color: Colors.blue,
                          ),
                          title:
                              const Text("Course"),
                          subtitle: Text(
                            widget.course.courseName,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Card(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.school,
                            color: Colors.orange,
                          ),
                          title: const Text(
                              "Department"),
                          subtitle: Text(
                            widget.course.department,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Card(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.calendar_today,
                            color: Colors.green,
                          ),
                          title:
                              const Text("Semester"),
                          subtitle: Text(
                            widget.course.semester,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      OutlinedButton.icon(
                        style:
                            OutlinedButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(
                                  55),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    14),
                          ),
                        ),

                        onPressed: pickFile,

                        icon: const Icon(
                          Icons.attach_file,
                        ),

                        label: Text(
                          fileName.isEmpty
                              ? "Choose PDF / DOC / PPT / Image"
                              : fileName,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 35),

                      BlocBuilder<NoteBloc,
                          NoteState>(
                        builder: (context, state) {
                          final loading =
                              state is NoteLoading;

                          return SizedBox(
                            width: double.infinity,
                            height: 55,
                            child:
                                ElevatedButton.icon(
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    Colors.blue,
                                foregroundColor:
                                    Colors.white,
                              ),

                              onPressed: loading
                                  ? null
                                  : () async {
                                     if (!_formKey.currentState!.validate()) {
  return;
}

if (selectedFile == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Please select a file"),
      backgroundColor: Colors.red,
    ),
  );
  return;
}

try {
 final cloudinary = CloudinaryService();

final result = await cloudinary.uploadFile(
  selectedFile!,
);

final fileUrl = result["url"];
// ignore: unused_local_variable
final uploadedFileName = result["name"];

  final note = NoteModel(
    id: FirebaseFirestore.instance
        .collection("notes")
        .doc()
        .id,

    courseId: widget.course.id,
    courseName: widget.course.courseName,

    title: _titleController.text.trim(),
    description: _descriptionController.text.trim(),

    fileName: fileName,
    fileUrl: fileUrl,

    uploadedBy: teacherName,

    createdAt: DateTime.now(),
  );

  context.read<NoteBloc>().add(
        AddNoteEvent(note),
      );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(e.toString()),
      backgroundColor: Colors.red,
    ),
  );
} // Part 3
                                    },

                              icon: loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                        color: Colors
                                            .white,
                                        strokeWidth:
                                            2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.cloud_upload,
                                    ),

                              label: Text(
                                loading
                                    ? "Uploading..."
                                    : "Upload Note",
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