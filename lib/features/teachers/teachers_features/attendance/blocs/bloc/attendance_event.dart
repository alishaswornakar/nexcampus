part of 'attendance_bloc.dart';

abstract class AttendanceEvent {}

/// Load Students
class LoadStudents extends AttendanceEvent {
  final String department;
  final int semester;

  LoadStudents({
    required this.department,
    required this.semester,
  });
}

/// Load Subjects
class LoadSubjectsEvent extends AttendanceEvent {
  final String department;
  final String semester;

  LoadSubjectsEvent({
    required this.department,
    required this.semester,
  });
}

/// Save Attendance
class SaveAttendanceEvent extends AttendanceEvent {
  final AttendanceModel attendance;

  SaveAttendanceEvent(this.attendance);
}

/// Load Attendance History
class LoadAttendanceHistoryEvent extends AttendanceEvent {
  final String department;
  final String semester;
  final String subjectId;

  LoadAttendanceHistoryEvent({
    required this.department,
    required this.semester,
    required this.subjectId,
  });
}