import 'package:equatable/equatable.dart';

abstract class SyllabusState extends Equatable {
  const SyllabusState();

  @override
  List<Object?> get props => [];
}

class SyllabusInitial extends SyllabusState {
  const SyllabusInitial();
}

class SyllabusLoading extends SyllabusState {
  const SyllabusLoading();
}

class SyllabusLoaded extends SyllabusState {
  final int selectedSemester;
  final List<Map<String, String>> subjects;

  const SyllabusLoaded({
    required this.selectedSemester,
    required this.subjects,
  });

  SyllabusLoaded copyWith({
    int? selectedSemester,
    List<Map<String, String>>? subjects,
  }) {
    return SyllabusLoaded(
      selectedSemester: selectedSemester ?? this.selectedSemester,
      subjects: subjects ?? this.subjects,
    );
  }

  @override
  List<Object?> get props => [selectedSemester, subjects];
}

class SyllabusError extends SyllabusState {
  final String message;

  const SyllabusError(this.message);

  @override
  List<Object?> get props => [message];
}
