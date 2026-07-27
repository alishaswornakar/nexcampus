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
      String id, Map<String, dynamic> data) async {
    await _db.collection('assignments').doc(id).update(data);
  }

  // 3. Delete Submission
  static Future<void> deleteSubmission(String id) async {
    await _db.collection('submissions').doc(id).delete();
  }

  // 4. Share Feature
  static void shareAssignmentDetails(String title, String dept, String sem, String deadline) {
    String text = "📚 *Assignment Details*\n\n"
        "Title: $title\n"
        "Department: $dept\n"
        "Semester: $sem\n"
        "Deadline: $deadline\n\n"
        "Please check the NexCampus app for full details.";
    Share.share(text);
  }
}