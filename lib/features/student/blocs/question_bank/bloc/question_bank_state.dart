import 'package:equatable/equatable.dart';

abstract class QuestionBankState extends Equatable {
  const QuestionBankState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class QuestionBankInitial extends QuestionBankState {
  const QuestionBankInitial();
}

/// Loading state
class QuestionBankLoading extends QuestionBankState {
  const QuestionBankLoading();
}

/// Loaded state
class QuestionBankLoaded extends QuestionBankState {
  final int selectedSemester;
  final List<Map<String, String>> subjects;

  const QuestionBankLoaded({
    required this.selectedSemester,
    required this.subjects,
  });

  QuestionBankLoaded copyWith({
    int? selectedSemester,
    List<Map<String, String>>? subjects,
  }) {
    return QuestionBankLoaded(
      selectedSemester: selectedSemester ?? this.selectedSemester,
      subjects: subjects ?? this.subjects,
    );
  }

  @override
  List<Object?> get props => [selectedSemester, subjects];
}

/// Error state
class QuestionBankError extends QuestionBankState {
  final String message;

  const QuestionBankError(this.message);

  @override
  List<Object?> get props => [message];
}
