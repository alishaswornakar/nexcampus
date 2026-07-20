part of 'attendance_bloc.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceSaved extends AttendanceState {}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError(this.message);
}

class AttendanceStudentsLoaded extends AttendanceState {
  final List<StudentModel> students;

  AttendanceStudentsLoaded(this.students);
}

class AttendanceSubjectsLoaded extends AttendanceState {
  final List<SubjectModel> subjects;

  AttendanceSubjectsLoaded(this.subjects);
}

class AttendanceHistoryLoaded extends AttendanceState {
  final List<AttendanceModel> attendance;

  AttendanceHistoryLoaded(this.attendance);
}