import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

class AdminAttendanceService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 📖 Fetch Attendance Stream for Admin (Read-Only)
  static Stream<List<AttendanceModel>> getAttendanceByFilter({
    required String department,
    required String semester,
    required String section,
  }) {
    return _db
        .collection('attendance')
        .where('department', isEqualTo: department)
        .where('semester', isEqualTo: semester)
        .where('section', isEqualTo: section)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AttendanceModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}