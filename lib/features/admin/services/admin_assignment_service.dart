import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class AdminAssignmentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Delete Assignment
  static Future<void> deleteAssignment(String id) async {
    await _db.collection('assignments').doc(id).delete();
  }

  // 2. Update Assignment
  static Future<void> updateAssignment(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('assignments').doc(id).update(data);
  }

  // 3. Delete Submission
  static Future<void> deleteSubmission(String id) async {
    // Note: Yedi submissions ko collection name assignment_submissions ho vane yeta pani change garna sakchau
    await _db.collection('assignment_submissions').doc(id).delete();
  }

  // 4. Get Submissions For Specific Assignment (Naya Method Added Here ✨)
  static Stream<QuerySnapshot> getSubmissionsForAssignment(
    String assignmentId,
  ) {
    return _db
        .collection(
          'assignment_submissions',
        ) // AssignmentDetailScreen sanga match gareko collection name
        .where('assignmentId', isEqualTo: assignmentId)
        .snapshots();
  }

  // 5. Share Feature
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

    // share_plus package ko updated syntax anusar
    SharePlus.instance.share(ShareParams(text: text));
  }
}
