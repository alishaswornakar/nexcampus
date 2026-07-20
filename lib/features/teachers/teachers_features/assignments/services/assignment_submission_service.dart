import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/assignment_submission_model.dart';

class AssignmentSubmissionService {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  CollectionReference get submissionCollection =>
      firestore.collection("assignment_submissions");

  /// Submit Assignment
  Future<void> submitAssignment({
    required AssignmentSubmissionModel submission,
  }) async {
    try {
      await submissionCollection
          .doc(submission.id)
          .set(submission.toMap());
    } catch (e) {
      throw Exception(
        "Failed to submit assignment: $e",
      );
    }
  }

  /// Update Submission
  Future<void> updateSubmission({
    required AssignmentSubmissionModel submission,
  }) async {
    try {
      await submissionCollection
          .doc(submission.id)
          .update(submission.toMap());
    } catch (e) {
      throw Exception(
        "Failed to update submission: $e",
      );
    }
  }

  /// Delete Submission
  Future<void> deleteSubmission(
    String submissionId,
  ) async {
    try {
      await submissionCollection
          .doc(submissionId)
          .delete();
    } catch (e) {
      throw Exception(
        "Failed to delete submission: $e",
      );
    }
  }

  /// Teacher: Get all submissions for an assignment
  Stream<List<AssignmentSubmissionModel>>
      getAssignmentSubmissions({
    required String assignmentId,
  }) {
    return submissionCollection
        .where(
          "assignmentId",
          isEqualTo: assignmentId,
        )
        .orderBy(
          "submittedAt",
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    AssignmentSubmissionModel.fromMap(
                  doc.data()
                      as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Student: Get my submissions
  Stream<List<AssignmentSubmissionModel>>
      getStudentSubmissions({
    required String studentId,
  }) {
    return submissionCollection
        .where(
          "studentId",
          isEqualTo: studentId,
        )
        .orderBy(
          "submittedAt",
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    AssignmentSubmissionModel.fromMap(
                  doc.data()
                      as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Check if student already submitted
  Future<AssignmentSubmissionModel?>
      getStudentSubmission({
    required String assignmentId,
    required String studentId,
  }) async {
    final snapshot =
        await submissionCollection
            .where(
              "assignmentId",
              isEqualTo: assignmentId,
            )
            .where(
              "studentId",
              isEqualTo: studentId,
            )
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final doc = snapshot.docs.first;

    return AssignmentSubmissionModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  /// Teacher: Grade Submission
  /// Grade Assignment
Future<void> gradeSubmission({
  required String submissionId,
  required String grade,
  required String feedback,
  required String status,
}) async {
  try {
    await firestore
        .collection("assignment_submissions")
        .doc(submissionId)
        .update({
      "grade": grade,
      "feedback": feedback,
      "status": status,
      "gradedAt": Timestamp.now(),
    });
  } catch (e) {
    throw Exception(
      "Failed to grade submission: $e",
    );
  }
}
}