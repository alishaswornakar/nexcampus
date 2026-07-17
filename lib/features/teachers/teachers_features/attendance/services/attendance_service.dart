import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';

import '../models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference get attendanceCollection =>
      firestore.collection("attendance");

  /// Save attendance
  /// Writes the class-level record (for teacher history screen)
  /// AND fans it out into each student's own subcollection (for student screen)
  Future<void> saveAttendance({required AttendanceModel attendance}) async {
    debugPrint('>>> NEW saveAttendance() is running <<<');

    final batch = firestore.batch();

    // 1. Class-level doc — used by AttendanceHistoryScreen (teacher side)
    final classDocRef = firestore.collection("attendance").doc(attendance.id);
    batch.set(classDocRef, attendance.toMap());

    // 2. One doc per student in students/{uid}/attendance
    //    This is what the student-side AttendanceService reads from.
    final dateKey =
        "${attendance.date.year}-${attendance.date.month}-${attendance.date.day}";

    debugPrint(
      'Fanning out attendance for ${attendance.students.length} students',
    );

    for (final student in attendance.students) {
      debugPrint('Writing attendance for uid: ${student.uid}');

      final studentDocRef = firestore
          .collection("students")
          .doc(student.uid)
          .collection("attendance")
          .doc("${dateKey}_${attendance.semester}");

      batch.set(studentDocRef, {
        "date": Timestamp.fromDate(attendance.date),
        "status": student.isPresent ? "Present" : "Absent",
        "remarks": "",
        "department": attendance.department,
        "semester": attendance.semester,
        "roll": student.roll,
        "fullName": student.fullName,
        "photoUrl": student.photoUrl,
      }, SetOptions(merge: true));
    }

    try {
      await batch.commit();
      debugPrint('Batch commit SUCCESS');
    } catch (e, stack) {
      debugPrint('Batch commit FAILED: $e');
      debugPrint('$stack');
      rethrow;
    }
  }

  Stream<List<StudentModel>> getStudents({
    required String department,
    required int semester,
  }) {
    return firestore
        .collection("users")
        .where("role", isEqualTo: "student")
        .where("department", isEqualTo: department)
        .where("semester", isEqualTo: semester.toString())
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StudentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Attendance history
  Stream<List<AttendanceModel>> attendanceHistory({
    required String department,
    required String semester,
  }) {
    return attendanceCollection
        .where("department", isEqualTo: department)
        .where("semester", isEqualTo: semester)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AttendanceModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }
}
