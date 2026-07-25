import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/core/data/semester_data1.dart';
import 'syllabus_event.dart';
import 'syllabus_state.dart';

class SyllabusBloc extends Bloc<SyllabusEvent, SyllabusState> {
  SyllabusBloc() : super(const SyllabusInitial()) {
    on<LoadSyllabus>(_onLoadSyllabus);
    on<SelectSyllabusSemester>(_onSelectSemester);
  }

  Future<void> _onLoadSyllabus(
    LoadSyllabus event,
    Emitter<SyllabusState> emit,
  ) async {
    emit(const SyllabusLoading());
    try {
      const defaultSemester = 1;
      emit(
        SyllabusLoaded(
          selectedSemester: defaultSemester,
          subjects: List<Map<String, String>>.from(
            semesterSubjects[defaultSemester] ?? [],
          ),
        ),
      );
    } catch (e) {
      emit(const SyllabusError('Failed to load Syllabus.'));
    }
  }

  Future<void> _onSelectSemester(
    SelectSyllabusSemester event,
    Emitter<SyllabusState> emit,
  ) async {
    try {
      emit(
        SyllabusLoaded(
          selectedSemester: event.semester,
          subjects: List<Map<String, String>>.from(
            semesterSubjects[event.semester] ?? [],
          ),
        ),
      );
    } catch (e) {
      emit(SyllabusError('Unable to load Semester ${event.semester}.'));
    }
  }
}
