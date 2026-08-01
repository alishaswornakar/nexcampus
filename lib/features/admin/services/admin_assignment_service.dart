import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

/// NOTE ON COLLECTION NAME:
/// The student module writes every submission into the
/// `assignment_submissions` collection (see
/// features/student/.../assignment_tasks_detail_screen.dart ->
/// AssignmentSubmissionRepository.submitAssignment). All admin reads/writes
/// below intentionally target that same collection name. Previously the
/// "Student Submitted" tab queried a different collection ('submissions'),
/// which is why admin could never see anything students actually sent in.
class AdminAssignmentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String assignmentsCollection = 'assignments';
  static const String submissionsCollection = 'assignment_submissions';

  // 1. Delete Assignment
  static Future<void> deleteAssignment(String id) async {
    await _db.collection(assignmentsCollection).doc(id).delete();
  }

  // 2. Update Assignment
  static Future<void> updateAssignment(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(assignmentsCollection).doc(id).update(data);
  }

  // 3. Delete Submission
  static Future<void> deleteSubmission(String id) async {
    await _db.collection(submissionsCollection).doc(id).delete();
  }

  // 4. Get Submissions For Specific Assignment
  static Stream<QuerySnapshot> getSubmissionsForAssignment(
    String assignmentId,
  ) {
    return _db
        .collection(submissionsCollection)
        .where('assignmentId', isEqualTo: assignmentId)
        .snapshots();
  }

  // 5. Get ALL Submissions (used by the "Student Submitted" tab)
  static Stream<QuerySnapshot> getAllSubmissions() {
    return _db.collection(submissionsCollection).snapshots();
  }

  // 6. Grade / update a submission (grade, feedback, gradedAt)
  static Future<void> gradeSubmission(
    String submissionId, {
    required String grade,
    required String feedback,
  }) async {
    await _db.collection(submissionsCollection).doc(submissionId).update({
      'grade': grade,
      'feedback': feedback,
      'status': 'graded',
      'gradedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // 7. Share Feature
  static void shareAssignmentDetails(
    String title,
    String dept,
    String sem,
    String deadline,
  ) {
    String text =
        "📚 *Assignment Details*\n\n"
        "Title: $title\n"
        "Department: $dept\n"
        "Semester: $sem\n"
        "Deadline: $deadline\n\n"
        "Please check the NexCampus app for full details.";

    SharePlus.instance.share(ShareParams(text: text));
  }
}
