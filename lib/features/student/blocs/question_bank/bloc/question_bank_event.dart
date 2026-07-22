import 'package:equatable/equatable.dart';

abstract class QuestionBankEvent extends Equatable {
  const QuestionBankEvent();

  @override
  List<Object?> get props => [];
}

/// Load the Question Bank screen
class LoadQuestionBank extends QuestionBankEvent {
  const LoadQuestionBank();
}

/// User selected a semester
class SelectSemester extends QuestionBankEvent {
  final int semester;

  const SelectSemester(this.semester);

  @override
  List<Object?> get props => [semester];
}
