import 'package:equatable/equatable.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotesInitial extends NotesState {
  const NotesInitial();
}

/// Loading state
class NotesLoading extends NotesState {
  const NotesLoading();
}

/// Loaded state
class NotesLoaded extends NotesState {
  final int selectedSemester;
  final List<Map<String, String>> subjects;

  const NotesLoaded({required this.selectedSemester, required this.subjects});

  NotesLoaded copyWith({
    int? selectedSemester,
    List<Map<String, String>>? subjects,
  }) {
    return NotesLoaded(
      selectedSemester: selectedSemester ?? this.selectedSemester,
      subjects: subjects ?? this.subjects,
    );
  }

  @override
  List<Object?> get props => [selectedSemester, subjects];
}

/// Error state
class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
}
