import 'package:equatable/equatable.dart';

import 'package:nexcampus_app/features/student/blocs/attendance/models/attendance_model.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

/// Load all attendance records
class LoadAttendance extends AttendanceEvent {
  final String studentId;

  const LoadAttendance(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

/// Listen to real-time attendance updates
class ListenAttendance extends AttendanceEvent {
  final String studentId;

  const ListenAttendance(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

/// Add attendance
class AddAttendance extends AttendanceEvent {
  final String studentId;
  final AttendanceModel attendance;

  const AddAttendance({required this.studentId, required this.attendance});

  @override
  List<Object?> get props => [studentId, attendance];
}

/// Update attendance
class UpdateAttendance extends AttendanceEvent {
  final String studentId;
  final AttendanceModel attendance;

  const UpdateAttendance({required this.studentId, required this.attendance});

  @override
  List<Object?> get props => [studentId, attendance];
}

/// Delete attendance
class DeleteAttendance extends AttendanceEvent {
  final String studentId;
  final String attendanceId;

  const DeleteAttendance({required this.studentId, required this.attendanceId});

  @override
  List<Object?> get props => [studentId, attendanceId];
}
