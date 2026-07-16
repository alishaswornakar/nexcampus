import 'package:equatable/equatable.dart';

import 'package:nexcampus_app/features/student/models/attendance_model.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

/// Loading state
class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

/// Loaded successfully
class AttendanceLoaded extends AttendanceState {
  final List<AttendanceModel> attendanceList;

  const AttendanceLoaded(this.attendanceList);

  @override
  List<Object?> get props => [attendanceList];
}

/// Operation completed successfully
class AttendanceSuccess extends AttendanceState {
  final String message;

  const AttendanceSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}
