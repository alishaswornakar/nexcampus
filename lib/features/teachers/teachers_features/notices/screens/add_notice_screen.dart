// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
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

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    if (widget.notice != null) {
      _titleController.text = widget.notice!.title;
      _descriptionController.text = widget.notice!.description;

      attachmentName = widget.notice!.attachmentName ?? "";
      attachmentUrl = widget.notice!.attachmentUrl;

      isPinned = widget.notice!.isPinned;
    }
  }

  Future<void> _loadTeacher() async {
    final user = _auth.currentUser;

    if (user == null) return;

    teacherId = user.uid;

    final doc =
        await _firestore.collection("users").doc(user.uid).get();

    teacherName = doc.data()?["fullName"] ?? "";

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

    selectedFile = File(result.files.single.path!);

    attachmentName = result.files.single.name;

    setState(() {});
  }

  InputDecoration decoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(
        icon,
        color: AppTheme.primary,
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppTheme.primary,
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
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;
    final bool isDesktop = width >= 1000;

    final double horizontalPadding = isMobile
        ? 16
        : isTablet
            ? 28
            : 40;

    final double maxWidth =
        isDesktop ? 720 : double.infinity;

    return BlocListener<NoticeBloc, NoticeState>(
      listener: (context, state) {
        if (state is NoticeAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Notice published successfully",
              ),
            ),
          );

          Navigator.pop(context);
        }

        if (state is NoticeUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Notice updated successfully",
              ),
            ),
          );

          Navigator.pop(context);
        }

        if (state is NoticeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(state.message),
            ),
          );
        }
      },

      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FA),

        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            widget.notice == null
                ? "Add Notice"
                : "Edit Notice",
            style: TextStyle(
              fontSize: isMobile ? 20 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: loadingTeacher
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          horizontalPadding,
                      vertical: 20,
                    ),
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
                            style: TextStyle(
                              fontSize: isMobile ? 22 : 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Teacher: $teacherName",
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          SizedBox(
                            height: isMobile ? 24 : 32,
                          ),

                          /// Notice Title
                          TextFormField(
                            controller: _titleController,
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 16,
                            ),
                            decoration: decoration(
                              label: "Notice Title",
                              icon: Icons.title,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return "Enter notice title";
                              }
                              return null;
                            },
                          ),

                          SizedBox(
                            height: isMobile ? 16 : 20,
                          ),

                          /// Description
                          TextFormField(
                            controller:
                                _descriptionController,
                            maxLines: isMobile ? 5 : 6,
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 16,
                            ),
                            decoration: decoration(
                              label: "Description",
                              icon:
                                  Icons.description_outlined,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return "Enter description";
                              }
                              return null;
                            },
                          ),

                          SizedBox(
                            height: isMobile ? 20 : 24,
                          ),

                          /// Attachment
                          OutlinedButton.icon(
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
                            style:
                                OutlinedButton.styleFrom(
                              minimumSize: Size(
                                double.infinity,
                                isMobile ? 52 : 58,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        14),
                              ),
                            ),
                          ),

                          if (attachmentName.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                      top: 8),
                              child: Text(
                                attachmentName,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                          SizedBox(
                            height: isMobile ? 18 : 22,
                          ),

                          /// Pin Notice
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      14),
                            ),
                            child: SwitchListTile(
                              value: isPinned,
                              activeColor:
                                  AppTheme.primary,
                              secondary: const Icon(
                                Icons.push_pin,
                                color:
                                    AppTheme.primary,
                              ),
                              title: Text(
                                "Pin this Notice",
                                style: TextStyle(
                                  fontSize: isMobile
                                      ? 15
                                      : 17,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                "Pinned notices appear first",
                                style: TextStyle(
                                  fontSize: isMobile
                                      ? 13
                                      : 14,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  isPinned = value;
                                });
                              },
                            ),
                          ),

                          SizedBox(
                            height: isMobile ? 28 : 36,
                          ),

                          BlocBuilder<NoticeBloc,
                              NoticeState>(
                            builder:
                                (context, state) {
                              final loading =
                                  state
                                      is NoticeLoading;

                              return SizedBox(
                                width:
                                    double.infinity,
                                height: isMobile
                                    ? 54
                                    : 58,
                                child:
                                    ElevatedButton.icon(
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    backgroundColor:
                                        AppTheme
                                            .primary,
                                    foregroundColor:
                                        Colors.white,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  14),
                                    ),
                                  ),
                                  onPressed:
                                      loading
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
                                                if (selectedFile !=
                                                    null) {
                                                  final result =
                                                      await CloudinaryService()
                                                          .uploadFile(
                                                              selectedFile!);

                                                  uploadedUrl =
                                                      result[
                                                          "url"];

                                                  uploadedName =
                                                      result[
                                                          "name"];
                                                }

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
                                          width: 20,
                                          height: 20,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                2,
                                            color: Colors
                                                .white,
                                          ),
                                        )
                                      : Icon(
                                          widget.notice ==
                                                  null
                                              ? Icons
                                                  .publish
                                              : Icons
                                                  .save,
                                        ),
                                  label: Text(
                                    loading
                                        ? "Saving..."
                                        : widget.notice ==
                                                null
                                            ? "Publish Notice"
                                            : "Update Notice",
                                    style: TextStyle(
                                      fontSize:
                                          isMobile
                                              ? 15
                                              : 17,
                                      fontWeight:
                                          FontWeight
                                              .bold,
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
              ),
      ),
    );
  }
}