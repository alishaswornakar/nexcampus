import '../models/assignment_submission_model.dart';
import '../services/assignment_submission_service.dart';

class AssignmentSubmissionRepository {
  final AssignmentSubmissionService service;

  AssignmentSubmissionRepository(this.service);

  /// Submit Assignment
  Future<void> submitAssignment(
    AssignmentSubmissionModel submission,
  ) {
    return service.submitAssignment(
      submission: submission,
    );
  }

  /// Update Submission
  Future<void> updateSubmission(
    AssignmentSubmissionModel submission,
  ) {
    return service.updateSubmission(
      submission: submission,
    );
  }

  /// Delete Submission
  Future<void> deleteSubmission(
    String submissionId,
  ) {
    return service.deleteSubmission(
      submissionId,
    );
  }

  /// Teacher - Get submissions for an assignment
  Stream<List<AssignmentSubmissionModel>>
      getAssignmentSubmissions({
    required String assignmentId,
  }) {
    return service.getAssignmentSubmissions(
      assignmentId: assignmentId,
    );
  }

  /// Student - Get all my submissions
  Stream<List<AssignmentSubmissionModel>>
      getStudentSubmissions({
    required String studentId,
  }) {
    return service.getStudentSubmissions(
      studentId: studentId,
    );
  }

  /// Check whether student already submitted
  Future<AssignmentSubmissionModel?>
      getStudentSubmission({
    required String assignmentId,
    required String studentId,
  }) {
    return service.getStudentSubmission(
      assignmentId: assignmentId,
      studentId: studentId,
    );
  }

  /// Grade Submission
  Future<void> gradeSubmission({
    required String submissionId,
    required String grade,
    required String feedback,
  }) {
    return service.gradeSubmission(
      submissionId: submissionId,
      grade: grade,
      feedback: feedback,
    );
  }
}