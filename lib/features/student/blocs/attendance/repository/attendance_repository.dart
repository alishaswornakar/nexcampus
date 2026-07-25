import '../models/attendance_model.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/services/attendance_service.dart';

class AttendanceRepository {
  final AttendanceService _firestoreService;

  AttendanceRepository({AttendanceService? firestoreService})
    : _firestoreService = firestoreService ?? AttendanceService();

  /// Get all attendance records
  Future<List<AttendanceModel>> getAttendanceRecords(String studentId) {
    return _firestoreService.getAttendanceRecords(studentId);
  }

  /// Listen for real-time attendance updates
  Stream<List<AttendanceModel>> attendanceStream(String studentId) {
    return _firestoreService.attendanceStream(studentId);
  }

  /// Get attendance by document ID
  Future<AttendanceModel?> getAttendanceById(
    String studentId,
    String attendanceId,
  ) {
    return _firestoreService.getAttendanceById(studentId, attendanceId);
  }

  /// Add attendance
  Future<void> addAttendance(String studentId, AttendanceModel attendance) {
    return _firestoreService.addAttendance(studentId, attendance);
  }

  /// Update attendance
  Future<void> updateAttendance(String studentId, AttendanceModel attendance) {
    return _firestoreService.updateAttendance(studentId, attendance);
  }

  /// Delete attendance
  Future<void> deleteAttendance(String studentId, String attendanceId) {
    return _firestoreService.deleteAttendance(studentId, attendanceId);
  }
}
