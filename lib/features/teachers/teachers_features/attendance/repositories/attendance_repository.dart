import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';

import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceRepository {
  final AttendanceService service;

  AttendanceRepository(this.service);

  Future<void> saveAttendance(
  AttendanceModel attendance,
) {
  return service.saveAttendance(
    attendance: attendance,
  );
}

  Stream<List<StudentModel>> getStudents({
  required String department,
  required int semester,
}) {
  return service.getStudents(
    department: department,
    semester: semester,
  );
}

  Stream<List<AttendanceModel>> attendanceHistory({
    required String department,
    required String semester,
  }) {
    return service.attendanceHistory(
      department: department,
      semester: semester,
    );
  }
}