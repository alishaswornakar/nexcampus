// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/assignment_model.dart';
import '../models/assignment_submission_model.dart';

import '../repository/assignment_submission_repository.dart';

import '../services/assignment_submission_service.dart';
import '../services/cloudinary_service.dart';
import '../widgets/remarks_field.dart';
import '../widgets/submission_summary_card.dart';

import '../widgets/pdf_upload_card.dart';
import '../widgets/submit_assignment_button.dart';

class SubmitAssignmentScreen extends StatefulWidget {
  final AssignmentModel assignment;

  const SubmitAssignmentScreen({
    super.key,
    required this.assignment,
  });

  @override
  State<SubmitAssignmentScreen> createState() =>
      _SubmitAssignmentScreenState();
}

class _SubmitAssignmentScreenState
    extends State<SubmitAssignmentScreen> {
  final remarksController =
      TextEditingController();

  final repository =
      AssignmentSubmissionRepository(
    AssignmentSubmissionService(),
  );

  final cloudinary =
      CloudinaryService();

  bool isUploadingPdf = false;
  bool isSubmitting = false;

  String? pdfUrl;
  String? pdfName;

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }
  Future<void> uploadPdf() async {
  setState(() {
    isUploadingPdf = true;
  });

  try {
    final result = await cloudinary.uploadPdf();

    if (result != null) {
      setState(() {
        pdfUrl = result["url"];
        pdfName = result["name"];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("PDF uploaded successfully."),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
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
Future<void> submitAssignment() async {
  if (pdfUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please upload your assignment PDF."),
      ),
    );
    return;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return;
  }

  setState(() {
    isSubmitting = true;
  });

  try {
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final userData =
        userDoc.data() as Map<String, dynamic>;

    final doc = FirebaseFirestore.instance
        .collection("assignment_submissions")
        .doc();

    final submission =
        AssignmentSubmissionModel(
      id: doc.id,
      assignmentId: widget.assignment.id,

      studentId: user.uid,
      studentName:
          userData["fullName"] ?? "",
      roll: userData["roll"] ?? "",

      department:
          userData["department"] ?? "",
      semester:
          userData["semester"] ?? "",

      pdfUrl: pdfUrl!,
      pdfName: pdfName ?? "",

      remarks:
          remarksController.text.trim(),

      submittedAt: DateTime.now(),
    );

    await repository.submitAssignment(
      submission,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Assignment submitted successfully!",
        ),
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(e.toString()),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isSubmitting = false;
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
        "Submit Assignment",
      ),
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Assignment Information
          SubmissionSummaryCard(
            assignment: widget.assignment,
          ),

          const SizedBox(height: 24),

          const Text(
            "Remarks",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          RemarksField(
            controller: remarksController,
          ),

          const SizedBox(height: 24),

          const Text(
            "Assignment PDF",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          PdfUploadCard(
            isUploading: isUploadingPdf,
            pdfName: pdfName,
            onTap: uploadPdf,
          ),

          const SizedBox(height: 30),

          SubmitAssignmentButton(
            isSubmitting: isSubmitting,
            onPressed: submitAssignment,
          ),
        ],
      ),
    ),
  );
}
    }