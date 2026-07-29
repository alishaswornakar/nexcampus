import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nexcampus_app/features/admin/models/attendance_model.dart';
import '../../admin/models/admin_subject_model.dart';

class AdminAttendanceService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _sessionsCollection =>
      _db.collection('attendance');

  static CollectionReference<Map<String, dynamic>> get _subjectsCollection =>
      _db.collection('subjects');

  static Stream<List<AttendanceModel>> getAttendanceByFilter({
    required String department,
    required String semester,
    String? subjectId,
  }) {
    debugPrint("========== ADMIN ATTENDANCE QUERY ==========");
    debugPrint("Department : $department");
    debugPrint("Semester   : $semester");
    debugPrint("SubjectId  : ${subjectId ?? 'All Subjects'}");

    Query<Map<String, dynamic>> query = _sessionsCollection
        .where('department', isEqualTo: department)
        .where('semester', isEqualTo: semester);

    if (subjectId != null && subjectId.isNotEmpty) {
      debugPrint("Filtering by subjectId...");
      query = query.where('subjectId', isEqualTo: subjectId);
    }

    return query.orderBy('date', descending: true).snapshots().map((snapshot) {
      debugPrint("Documents Found : ${snapshot.docs.length}");

      for (final doc in snapshot.docs) {
        debugPrint("------------ DOCUMENT ------------");
        debugPrint("Document ID : ${doc.id}");
        debugPrint(doc.data().toString());
      }

      final records = snapshot.docs
          .expand((doc) => AttendanceModel.fromSessionDoc(doc))
          .toList();

      debugPrint("Flattened Records : ${records.length}");
      debugPrint("==================================");

      return records;
    });
  }

  static Stream<List<AdminSubjectModel>> getSubjects({
    required String department,
    required String semester,
  }) {
    debugPrint("========== SUBJECT QUERY ==========");
    debugPrint("Department : $department");
    debugPrint("Semester   : $semester");

    return _subjectsCollection
        .where('department', isEqualTo: department)
        .where('semester', isEqualTo: semester)
        .snapshots()
        .map((snapshot) {
      debugPrint("Subjects Found : ${snapshot.docs.length}");

      for (final doc in snapshot.docs) {
        debugPrint(doc.data().toString());
      }

      return snapshot.docs
          .map((doc) => AdminSubjectModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}