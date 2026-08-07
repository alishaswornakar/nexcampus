import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/assignment_submission_model.dart';
import 'package:flutter/foundation.dart';

class AssignmentSubmissionService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference get submissionCollection =>
      firestore.collection("assignment_submissions");

  /// Submit Assignment
  Future<void> submitAssignment({
    required AssignmentSubmissionModel submission,
  }) async {
    try {
      await submissionCollection.doc(submission.id).set(submission.toMap());
    } catch (e) {
      throw Exception("Failed to submit assignment: $e");
    }
  }

  /// Update Submission
  Future<void> updateSubmission({
    required AssignmentSubmissionModel submission,
  }) async {
    try {
      await submissionCollection.doc(submission.id).update(submission.toMap());
    } catch (e) {
      throw Exception("Failed to update submission: $e");
    }
  }

  /// Delete Submission
  Future<void> deleteSubmission(String submissionId) async {
    try {
      await submissionCollection.doc(submissionId).delete();
    } catch (e) {
      throw Exception("Failed to delete submission: $e");
    }
  }

  /// Student: Get my submissions
  Stream<List<AssignmentSubmissionModel>> getStudentSubmissions({
    required String studentId,
  }) {
    return submissionCollection
        .where("studentId", isEqualTo: studentId)
        .orderBy("submittedAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AssignmentSubmissionModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Check if student already submitted
  Future<AssignmentSubmissionModel?> getStudentSubmission({
    required String assignmentId,
    required String studentId,
  }) async {
    final snapshot = await submissionCollection
        .where("assignmentId", isEqualTo: assignmentId)
        .where("studentId", isEqualTo: studentId)
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
      throw Exception("Failed to grade submission: $e");
    }
  }

  /// Teacher: Get all submissions for a single assignment
  Stream<List<AssignmentSubmissionModel>> getAssignmentSubmissions({
    required String assignmentId,
  }) {
    debugPrint("Searching assignmentId = $assignmentId");

    return submissionCollection
        .where("assignmentId", isEqualTo: assignmentId)
        .snapshots()
        .map((snapshot) {
          debugPrint("Documents found = ${snapshot.docs.length}");

          for (var doc in snapshot.docs) {
            debugPrint(doc.data().toString());
          }

          return snapshot.docs
              .map(
                (doc) => AssignmentSubmissionModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  /// Teacher: Get submissions across MULTIPLE assignments at once.
  /// Used for the dashboard "Recent Activity" feed so we don't need
  /// a teacherId field on the submission itself.
  /// Note: Firestore `whereIn` supports at most 30 values, so if a
  /// teacher has more than 30 assignments only the first 30 (by the
  /// order they were fetched) are included here.
  Stream<List<AssignmentSubmissionModel>> getSubmissionsForAssignments({
    required List<String> assignmentIds,
  }) {
    if (assignmentIds.isEmpty) {
      return Stream.value(const []);
    }

    final ids = assignmentIds.take(30).toList();

    return submissionCollection
        .where("assignmentId", whereIn: ids)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AssignmentSubmissionModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }
}
