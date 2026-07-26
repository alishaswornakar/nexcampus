import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore;

  AttendanceService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to:
  /// students/{studentId}/attendance
  CollectionReference<Map<String, dynamic>> _attendanceCollection(
    String studentId,
  ) {
    return _firestore
        .collection('students')
        .doc(studentId)
        .collection('attendance');
  }

  /// Get all attendance records
  Future<List<AttendanceModel>> getAttendanceRecords(String studentId) async {
    final snapshot = await _attendanceCollection(
      studentId,
    ).orderBy('date', descending: true).get();

    return snapshot.docs
        .map((doc) => AttendanceModel.fromFirestore(doc))
        .toList();
  }

  /// Listen to attendance records in real time
  Stream<List<AttendanceModel>> attendanceStream(String studentId) {
    return _attendanceCollection(studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get a single attendance record
  Future<AttendanceModel?> getAttendanceById(
    String studentId,
    String attendanceId,
  ) async {
    final doc = await _attendanceCollection(studentId).doc(attendanceId).get();

    if (!doc.exists) {
      return null;
    }

    return AttendanceModel.fromFirestore(doc);
  }

  /// Add attendance
  Future<void> addAttendance(
    String studentId,
    AttendanceModel attendance,
  ) async {
    await _attendanceCollection(
      studentId,
    ).doc(attendance.id).set(attendance.toMap());
  }

  /// Update attendance
  Future<void> updateAttendance(
    String studentId,
    AttendanceModel attendance,
  ) async {
    await _attendanceCollection(
      studentId,
    ).doc(attendance.id).update(attendance.toMap());
  }

  /// Delete attendance
  Future<void> deleteAttendance(String studentId, String attendanceId) async {
    await _attendanceCollection(studentId).doc(attendanceId).delete();
  }
}
