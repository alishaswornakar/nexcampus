import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/models/subject_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/models/attendance_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/repositories/attendance_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc(this.repository) : super(AttendanceInitial()) {
    on<LoadStudents>(_loadStudents);
    on<LoadSubjectsEvent>(_loadSubjects);
    on<SaveAttendanceEvent>(_saveAttendance);
    on<LoadAttendanceHistoryEvent>(_loadHistory);
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

  Future<void> _loadSubjects(
    LoadSubjectsEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());

    await emit.forEach<List<SubjectModel>>(
      repository.getSubjects(
        department: event.department,
        semester: event.semester,
      ),
      onData: (subjects) => AttendanceSubjectsLoaded(subjects),
      onError: (error, _) => AttendanceError(error.toString()),
    );
  }

  Future<void> _saveAttendance(
    SaveAttendanceEvent event,
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
    LoadAttendanceHistoryEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());

    await emit.forEach<List<AttendanceModel>>(
      repository.attendanceHistory(
        department: event.department,
        semester: event.semester,
        subjectId: event.subjectId,
      ),
      onData: (history) => AttendanceHistoryLoaded(history),
      onError: (error, _) => AttendanceError(error.toString()),
    );
  }
}