

import 'package:nexcampus_app/features/teachers/teachers_features/notes/model/note_model.dart';

abstract class NoteEvent {}

/// Load Notes
class LoadNotesEvent extends NoteEvent {
  final String courseId;

  LoadNotesEvent({
    required this.courseId,
  });
}

/// Add Note
class AddNoteEvent extends NoteEvent {
  final NoteModel note;

  AddNoteEvent(this.note);
}

/// Update Note
class UpdateNoteEvent extends NoteEvent {
  final NoteModel note;

  UpdateNoteEvent(this.note);
}

/// Delete Note
class DeleteNoteEvent extends NoteEvent {
  final String noteId;

  DeleteNoteEvent(this.noteId);
}