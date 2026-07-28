import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore;

  AttendanceService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Top-level collection: one document per class session, each holding a
  /// `students` array. (Adjust the name if yours differs.)
  CollectionReference<Map<String, dynamic>> get _sessionsCollection =>
      _firestore.collection('attendance');

  Future<List<AttendanceModel>> getAttendanceRecords(String uid) async {
    final snapshot = await _sessionsCollection
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceModel.fromSessionDoc(doc, uid))
        .whereType<AttendanceModel>()
        .toList();
  }

  Stream<List<AttendanceModel>> attendanceStream(String uid) {
    return _sessionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceModel.fromSessionDoc(doc, uid))
              .whereType<AttendanceModel>()
              .toList(),
        );
  }

  Future<AttendanceModel?> getAttendanceById(
    String uid,
    String sessionId,
  ) async {
    final doc = await _sessionsCollection.doc(sessionId).get();
    if (!doc.exists) return null;
    return AttendanceModel.fromSessionDoc(doc, uid);
  }

  /// Adds this student to a session doc's `students` array. If the session
  /// doc doesn't exist yet, it's created with just this one student.
  Future<void> addAttendance(String uid, AttendanceModel attendance) async {
    final docRef = _sessionsCollection.doc(attendance.id);

    await _firestore.runTransaction((txn) async {
      final snapshot = await txn.get(docRef);

      final studentEntry = {
        'uid': attendance.uid,
        'fullName': attendance.fullName,
        'roll': attendance.roll,
        'photoUrl': attendance.photoUrl,
        'isPresent': attendance.isPresent,
      };

      if (!snapshot.exists) {
        txn.set(docRef, {
          'date': Timestamp.fromDate(attendance.date),
          'createdAt': Timestamp.fromDate(attendance.createdAt),
          'department': attendance.department,
          'semester': attendance.semester,
          'students': [studentEntry],
        });
        return;
      }

      final data = snapshot.data()!;
      final students = ((data['students'] as List<dynamic>?) ?? [])
          .map((s) => Map<String, dynamic>.from(s as Map))
          .toList();

      final index = students.indexWhere((s) => s['uid'] == attendance.uid);
      if (index == -1) {
        students.add(studentEntry);
      } else {
        students[index] = studentEntry;
      }

      txn.update(docRef, {'students': students});
    });
  }

  /// Toggles/updates this student's entry (e.g. isPresent) inside the
  /// session doc's `students` array.
  Future<void> updateAttendance(String uid, AttendanceModel attendance) async {
    final docRef = _sessionsCollection.doc(attendance.id);

    await _firestore.runTransaction((txn) async {
      final snapshot = await txn.get(docRef);
      final data = snapshot.data();
      if (data == null) return;

      final students = ((data['students'] as List<dynamic>?) ?? [])
          .map((s) => Map<String, dynamic>.from(s as Map))
          .toList();

      final index = students.indexWhere((s) => s['uid'] == attendance.uid);
      if (index == -1) return;

      students[index] = {
        ...students[index],
        'fullName': attendance.fullName,
        'roll': attendance.roll,
        'photoUrl': attendance.photoUrl,
        'isPresent': attendance.isPresent,
      };

      txn.update(docRef, {'students': students});
    });
  }

  /// Removes this student's entry from the session doc's `students` array.
  Future<void> deleteAttendance(String uid, String sessionId) async {
    final docRef = _sessionsCollection.doc(sessionId);

    await _firestore.runTransaction((txn) async {
      final snapshot = await txn.get(docRef);
      final data = snapshot.data();
      if (data == null) return;

      final students = ((data['students'] as List<dynamic>?) ?? [])
          .map((s) => Map<String, dynamic>.from(s as Map))
          .where((s) => s['uid'] != uid)
          .toList();

      txn.update(docRef, {'students': students});
    });
  }
}
