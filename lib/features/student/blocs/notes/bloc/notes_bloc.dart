import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/core/data/semester_data1.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc() : super(const NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<SelectNotesSemester>(_onSelectSemester);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());

    try {
      const defaultSemester = 1;

      emit(
        NotesLoaded(
          selectedSemester: defaultSemester,
          subjects: List<Map<String, String>>.from(
            semesterSubjects[defaultSemester] ?? [],
          ),
        ),
      );
    } catch (e) {
      emit(const NotesError('Failed to load Notes.'));
    }
  }

  Future<void> _onSelectSemester(
    SelectNotesSemester event,
    Emitter<NotesState> emit,
  ) async {
    try {
      emit(
        NotesLoaded(
          selectedSemester: event.semester,
          subjects: List<Map<String, String>>.from(
            semesterSubjects[event.semester] ?? [],
          ),
        ),
      );
    } catch (e) {
      emit(NotesError('Unable to load Semester ${event.semester}.'));
    }
  }
}
