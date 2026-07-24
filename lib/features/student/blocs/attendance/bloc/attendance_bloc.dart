import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/features/student/blocs/attendance/models/attendance_model.dart';
import 'package:nexcampus_app/features/student/blocs/attendance/repository/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  StreamSubscription<List<AttendanceModel>>? _attendanceSubscription;

  AttendanceBloc({required this.repository})
    : super(const AttendanceInitial()) {
    on<LoadAttendance>(_onLoadAttendance);
    on<ListenAttendance>(_onListenAttendance);
    on<AddAttendance>(_onAddAttendance);
    on<UpdateAttendance>(_onUpdateAttendance);
    on<DeleteAttendance>(_onDeleteAttendance);

    on<_AttendanceUpdated>((event, emit) {
      emit(AttendanceLoaded(event.attendance));
    });
  }

  /// Load attendance once
  Future<void> _onLoadAttendance(
    LoadAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());

    try {
      final attendance = await repository.getAttendanceRecords(event.studentId);

      emit(AttendanceLoaded(attendance));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  /// Listen to Firestore real-time updates
  Future<void> _onListenAttendance(
    ListenAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading()); // added const, fixes the lint too

    await emit.forEach<List<AttendanceModel>>(
      repository.attendanceStream(
        event.studentId,
      ), // fixed: was watchAttendance
      onData: (list) => AttendanceLoaded(list),
      onError: (error, stackTrace) => AttendanceError(error.toString()),
    );
  }

  /// Add attendance
  Future<void> _onAddAttendance(
    AddAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      await repository.addAttendance(event.studentId, event.attendance);

      emit(const AttendanceSuccess('Attendance added successfully.'));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  /// Update attendance
  Future<void> _onUpdateAttendance(
    UpdateAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      await repository.updateAttendance(event.studentId, event.attendance);

      emit(const AttendanceSuccess('Attendance updated successfully.'));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  /// Delete attendance
  Future<void> _onDeleteAttendance(
    DeleteAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      await repository.deleteAttendance(event.studentId, event.attendanceId);

      emit(const AttendanceSuccess('Attendance deleted successfully.'));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _attendanceSubscription?.cancel();
    return super.close();
  }
}

/// Internal event for stream updates
class _AttendanceUpdated extends AttendanceEvent {
  final List<AttendanceModel> attendance;

  const _AttendanceUpdated(this.attendance);

  @override
  List<Object?> get props => [attendance];
}
