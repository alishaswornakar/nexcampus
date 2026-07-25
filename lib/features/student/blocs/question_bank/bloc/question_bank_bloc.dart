import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/core/data/semester_data1.dart';
import 'question_bank_event.dart';
import 'question_bank_state.dart';

class QuestionBankBloc extends Bloc<QuestionBankEvent, QuestionBankState> {
  QuestionBankBloc() : super(const QuestionBankInitial()) {
    on<LoadQuestionBank>(_onLoadQuestionBank);
    on<SelectSemester>(_onSelectSemester);
  }

  Future<void> _onLoadQuestionBank(
    LoadQuestionBank event,
    Emitter<QuestionBankState> emit,
  ) async {
    emit(const QuestionBankLoading());

    try {
      const defaultSemester = 1;

      emit(
        QuestionBankLoaded(
          selectedSemester: defaultSemester,
          subjects: List<Map<String, String>>.from(
            semesterSubjects[defaultSemester] ?? [],
          ),
        ),
      );
    } catch (e) {
      emit(const QuestionBankError('Failed to load Question Bank.'));
    }
  }

  Future<void> _onSelectSemester(
    SelectSemester event,
    Emitter<QuestionBankState> emit,
  ) async {
    try {
      emit(
        QuestionBankLoaded(
          selectedSemester: event.semester,
          subjects: List<Map<String, String>>.from(
            semesterSubjects[event.semester] ?? [],
          ),
        ),
      );
    } catch (e) {
      emit(QuestionBankError('Unable to load Semester ${event.semester}.'));
    }
  }
}
