import 'package:cloud_firestore/cloud_firestore.dart';
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