import 'package:equatable/equatable.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

/// Load the Notes screen
class LoadNotes extends NotesEvent {
  const LoadNotes();
}

/// User selected a semester
class SelectNotesSemester extends NotesEvent {
  final int semester;

  const SelectNotesSemester(this.semester);

  @override
  List<Object?> get props => [semester];
}
