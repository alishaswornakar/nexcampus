part of 'attendance_bloc.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}
class AttendanceStudentsLoaded extends AttendanceState {
  final List<StudentModel> students;

  AttendanceStudentsLoaded(this.students);
}

class AttendanceSaved extends AttendanceState {}

class AttendanceHistoryLoaded extends AttendanceState {
  final List<AttendanceModel> attendance;

  AttendanceHistoryLoaded(this.attendance);
}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError(this.message);
}