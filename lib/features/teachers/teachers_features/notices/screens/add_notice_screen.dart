// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/cloudinary_service.dart';


import '../blocs/bloc/notices_bloc.dart';
import '../blocs/bloc/notices_event.dart';
import '../blocs/bloc/notices_state.dart';
import '../models/notice_model.dart';

class AddNoticeScreen extends StatefulWidget {
  final TeacherNoticeModel? notice;

  const AddNoticeScreen({
    super.key,
    this.notice,
  });

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String teacherId = "";
  String teacherName = "";

  bool loadingTeacher = true;
  bool isPinned = false;

  File? selectedFile;

  String attachmentName = "";
  String? attachmentUrl;

  @override
  void initState() {
    super.initState();

    _loadTeacher();

    /// Edit Mode
    if (widget.notice != null) {
      _titleController.text =
          widget.notice!.title;

      _descriptionController.text =
          widget.notice!.description;

      attachmentName =
          widget.notice!.attachmentName ?? "";

      attachmentUrl =
          widget.notice!.attachmentUrl;

      isPinned =
          widget.notice!.isPinned;
    }
  }

  Future<void> _loadTeacher() async {
    final user = _auth.currentUser;

    if (user == null) return;

    teacherId = user.uid;

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

  Future<void> pickAttachment() async {
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

    attachmentName =
        result.files.single.name;

    setState(() {});
  }

  InputDecoration decoration({
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
            BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
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
    return BlocListener<NoticeBloc, NoticeState>(
      listener: (context, state) {
        if (state is NoticeAdded) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                  "Notice published successfully"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }

        if (state is NoticeUpdated) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                  "Notice updated successfully"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }

        if (state is NoticeError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

      child: Scaffold(
        backgroundColor:
            const Color(0xffF5F7FA),

        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            widget.notice == null
                ? "Add Notice"
                : "Edit Notice",
          ),
        ),

        body: loadingTeacher
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.all(20),

                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        widget.notice == null
                            ? "Create Notice"
                            : "Update Notice",
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Teacher : $teacherName",
                        style: TextStyle(
                          color:
                              Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Title
                      TextFormField(
                        controller:
                            _titleController,
                        decoration: decoration(
                          label: "Notice Title",
                          icon: Icons.title,
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

                      /// Description
                      TextFormField(
                        controller:
                            _descriptionController,
                        maxLines: 5,
                        decoration: decoration(
                          label: "Description",
                          icon:
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

                      /// Attachment
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
                        onPressed: pickAttachment,
                        icon: const Icon(
                          Icons.attach_file,
                        ),
                        label: Text(
                          attachmentName.isEmpty
                              ? "Choose Attachment (Optional)"
                              : attachmentName,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// Pin Notice
                      SwitchListTile(
                        value: isPinned,
                        activeThumbColor: Colors.blue,
                        title: const Text(
                          "Pin this Notice",
                        ),
                        subtitle: const Text(
                          "Pinned notices appear first",
                        ),
                        secondary: const Icon(
                          Icons.push_pin,
                        ),
                        onChanged: (value) {
                          setState(() {
                            isPinned = value;
                          });
                        },
                      ),

                      const SizedBox(height: 35),

                        BlocBuilder<NoticeBloc,
                          NoticeState>(
                        builder: (context, state) {
                          final loading =
                              state
                                  is NoticeLoading;

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
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          14),
                                ),
                              ),

                              onPressed: loading
                                  ? null
                                  : () async {
                                      if (!_formKey
                                          .currentState!
                                          .validate()) {
                                        return;
                                      }

                                      String?
                                          uploadedUrl =
                                          attachmentUrl;

                                      String?
                                          uploadedName =
                                          attachmentName;

                                      try {
                                        /// Upload file
                                        if (selectedFile !=
                                            null) {
                                          final cloudinary =
                                              CloudinaryService();

                                          final result =
                                              await cloudinary
                                                  .uploadFile(
                                            selectedFile!,
                                          );

                                          uploadedUrl =
                                              result[
                                                  "url"];

                                          uploadedName =
                                              result[
                                                  "name"];
                                        }

                                        /// Create Notice
                                        final notice =
                                            TeacherNoticeModel(
                                          id: widget
                                                  .notice
                                                  ?.id ??
                                              FirebaseFirestore
                                                  .instance
                                                  .collection(
                                                      "notices")
                                                  .doc()
                                                  .id,

                                          title:
                                              _titleController
                                                  .text
                                                  .trim(),

                                          description:
                                              _descriptionController
                                                  .text
                                                  .trim(),

                                          teacherId:
                                              teacherId,

                                          teacherName:
                                              teacherName,

                                          attachmentUrl:
                                              uploadedUrl,

                                          attachmentName:
                                              uploadedName,

                                          isPinned:
                                              isPinned,

                                          createdAt: widget
                                                  .notice
                                                  ?.createdAt ??
                                              DateTime
                                                  .now(),
                                        );

                                        /// Add / Update
                                        if (widget.notice ==
                                            null) {
                                          context
                                              .read<
                                                  NoticeBloc>()
                                              .add(
                                                AddNoticeEvent(
                                                    notice),
                                              );
                                        } else {
                                          context
                                              .read<
                                                  NoticeBloc>()
                                              .add(
                                                UpdateNoticeEvent(
                                                    notice),
                                              );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                Colors.red,
                                            content: Text(
                                              e.toString(),
                                            ),
                                          ),
                                        );
                                      }
                                    },

                              icon: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.save,
                                    ),

                              label: Text(
                                loading
                                    ? "Saving..."
                                    : widget.notice ==
                                            null
                                        ? "Publish Notice"
                                        : "Update Notice",
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 16,
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