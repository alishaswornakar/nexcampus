import 'package:nexcampus_app/features/teachers/teachers_features/assignments/models/subject_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';

import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceRepository {
  final AttendanceService service;

  AttendanceRepository(this.service);

  /// Save Attendance
  Future<void> saveAttendance(
    AttendanceModel attendance,
  ) {
    return service.saveAttendance(
      attendance: attendance,
    );
  }

  /// Get Students
  Stream<List<StudentModel>> getStudents({
    required String department,
    required int semester,
  }) {
    return service.getStudents(
      department: department,
      semester: semester,
    );
  }

  /// Get Subjects
  Stream<List<SubjectModel>> getSubjects({
    required String department,
    required String semester,
  }) {
    return service.getSubjects(
      department: department,
      semester: semester,
    );
  }

  /// Attendance History
  Stream<List<AttendanceModel>> attendanceHistory({
    required String department,
    required String semester,
    required String subjectId,
  }) {
    return service.attendanceHistory(
      department: department,
      semester: semester,
      subjectId: subjectId,
    );
  }
}