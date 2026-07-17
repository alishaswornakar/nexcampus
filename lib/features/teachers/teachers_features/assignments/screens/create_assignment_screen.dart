// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/widgets/ssignment_form.dart';

import '../models/assignment_model.dart';
import '../repository/assignment_repository.dart';
import '../services/assignment_service.dart';
import '../services/cloudinary_service.dart';

import '../widgets/create_assignment_button.dart';
import '../widgets/pdf_upload_card.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final String department;
  final int semester;
  final String selectedSubject;

  const CreateAssignmentScreen({
    super.key,
    required this.department,
    required this.semester,
    required this.selectedSubject,
  });

  @override
  State<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState
    extends State<CreateAssignmentScreen> {
  final AssignmentRepository repository =
      AssignmentRepository(
    AssignmentService(),
  );

  final CloudinaryService cloudinaryService =
      CloudinaryService();

  final titleController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  DateTime? dueDate;

  bool isSaving = false;

  bool isUploadingPdf = false;

  String? pdfUrl;
  String? pdfName;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().add(
        const Duration(days: 7),
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        dueDate = picked;
      });
    }
  }

  Future<void> uploadPdf() async {
    setState(() {
      isUploadingPdf = true;
    });

    try {
      final result =
          await cloudinaryService.uploadPdf();

      if (result != null) {
        setState(() {
          pdfUrl = result["url"];
          pdfName = result["name"];
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "PDF uploaded successfully",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      isUploadingPdf = false;
    });
  }

  Future<void> saveAssignment() async {
    if (titleController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter assignment title.",
          ),
        ),
      );
      return;
    }

    if (descriptionController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter description.",
          ),
        ),
      );
      return;
    }

    if (dueDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please select due date.",
          ),
        ),
      );
      return;
    }

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "User not logged in.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final doc = FirebaseFirestore.instance
          .collection("assignments")
          .doc();

      final assignment =
          AssignmentModel(
        id: doc.id,
        title: titleController.text
            .trim(),
        description:
            descriptionController.text
                .trim(),
        department:
            widget.department,
        semester:
            widget.semester.toString(),
        subject:
            widget.selectedSubject,
        teacherId: user.uid,
        teacherName:
            user.displayName ??
                "Teacher",
        dueDate: dueDate!,
        createdAt: DateTime.now(),
        pdfUrl: pdfUrl,
        pdfName: pdfName,
        submissionCount: 0,
      );

      await repository
          .createAssignment(
        assignment,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.green,
          content: Text(
            "Assignment Created Successfully",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.red,
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Create Assignment",
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            AssignmentForm(
              titleController:
                  titleController,
              descriptionController:
                  descriptionController,
              department:
                  widget.department,
              semester:
                  widget.semester,
              subject:
                  widget.selectedSubject,
              dueDate:
                  dueDate,
              onSelectDate:
                  pickDueDate,
            ),

            const SizedBox(
              height: 20,
            ),

            PdfUploadCard(
              isUploading:
                  isUploadingPdf,
              pdfName:
                  pdfName,
              onTap:
                  uploadPdf,
            ),

            const SizedBox(
              height: 30,
            ),

            CreateAssignmentButton(
              isSaving:
                  isSaving,
              onPressed:
                  saveAssignment,
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}