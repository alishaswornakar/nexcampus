

import 'package:nexcampus_app/features/teachers/teachers_features/notes/model/note_model.dart';

abstract class NoteState {}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteAdded extends NoteState {}

class NoteUpdated extends NoteState {}

class NoteDeleted extends NoteState {}

class NoteError extends NoteState {
  final String message;

  NoteError(this.message);
}

class NotesLoaded extends NoteState {
  final List<NoteModel> notes;

  NotesLoaded(this.notes);
}