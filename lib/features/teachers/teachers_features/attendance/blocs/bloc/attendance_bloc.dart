import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/models/attendance_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/repositories/attendance_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc(this.repository) : super(AttendanceInitial()) {
    on<LoadStudents>(_loadStudents);
    on<SaveAttendance>(_saveAttendance);
    on<LoadAttendanceHistory>(_loadHistory);
  }

  Future<void> _loadStudents(
    LoadStudents event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());

    await emit.forEach<List<StudentModel>>(
      repository.getStudents(
        department: event.department,
        semester: event.semester,
      ),
      onData: (students) => AttendanceStudentsLoaded(students),
      onError: (error, _) => AttendanceError(error.toString()),
    );
  }

  Future<void> _saveAttendance(
    SaveAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());

    try {
      await repository.saveAttendance(event.attendance);

      emit(AttendanceSaved());
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _loadHistory(
    LoadAttendanceHistory event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());

    await emit.forEach<List<AttendanceModel>>(
      repository.attendanceHistory(
        department: event.department,
        semester: event.semester,
      ),
      onData: (attendance) =>
          AttendanceHistoryLoaded(attendance),
      onError: (error, _) =>
          AttendanceError(error.toString()),
    );
  }
}