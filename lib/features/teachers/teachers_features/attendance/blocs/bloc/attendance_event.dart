part of 'attendance_bloc.dart';

abstract class AttendanceEvent {}

/// Save attendance for one student
class SaveAttendance extends AttendanceEvent {
  final AttendanceModel attendance;

  SaveAttendance(this.attendance);
}
class LoadStudents extends AttendanceEvent {
  final String department;
  final int semester;

  LoadStudents({
    required this.department,
    required this.semester,
  });
}

/// Load attendance history
class LoadAttendanceHistory extends AttendanceEvent {
  final String department;
  final String semester;

  LoadAttendanceHistory({
    required this.department,
    required this.semester,
  });

  

}