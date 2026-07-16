import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
<<<<<<< HEAD
import 'package:flutter/foundation.dart';
<<<<<<< HEAD
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/models/subject_model.dart';
=======
=======
>>>>>>> 1802040 (added attendance feature in teacher module)
>>>>>>> 84229ac (added attendance feature in teacher module)
=======
>>>>>>> 79eb623 (attendance student part 2)
import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';

import '../models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference get attendanceCollection =>
      firestore.collection("attendance");

  /// Save attendance
  Future<void> saveAttendance({
  required AttendanceModel attendance,
}) async {
  await firestore
      .collection("attendance")
      .doc(attendance.id)
      .set(attendance.toMap());
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
            .map(
              (doc) => StudentModel.fromMap(doc.data(),
                  doc.id),
            )
            .toList(),
      );
}

  /// Attendance history
  Stream<List<AttendanceModel>> attendanceHistory({
    required String department,
    required String semester,
    required String subjectId,

  }) {
    return attendanceCollection
        .where("department", isEqualTo: department)
<<<<<<< HEAD
.where("semester", isEqualTo: semester)
.where("subjectId", isEqualTo: subjectId)
=======
        .where("semester", isEqualTo: semester)
        .orderBy("createdAt", descending: true)
<<<<<<< HEAD
>>>>>>> 1802040 (added attendance feature in teacher module)
>>>>>>> 84229ac (added attendance feature in teacher module)
=======
>>>>>>> 79eb623 (attendance student part 2)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AttendanceModel.fromMap(
                   doc.id,
                  doc.data() as Map<String, dynamic>,
                 

                ),
              )
              .toList(),
        );
  }
<<<<<<< HEAD
<<<<<<< HEAD

  Stream<List<SubjectModel>> getSubjects({
  required String department,
  required String semester,
}) {
  return firestore
      .collection("subjects")
      .where("department", isEqualTo: department)
      .where("semester", isEqualTo: semester)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => SubjectModel.fromMap(
                doc.data(),
                doc.id,
              ),
            )
            .toList(),
      );
}
=======
<<<<<<< HEAD
>>>>>>> 84229ac (added attendance feature in teacher module)
=======
>>>>>>> 79eb623 (attendance student part 2)
}
