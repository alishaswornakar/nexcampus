import 'package:nexcampus_app/features/teachers/teachers_features/notes/model/note_model.dart';


import '../services/note_service.dart';

class NoteRepository {
  final NoteService service;

  NoteRepository(this.service);

  /// Add Note
  Future<void> addNote(
    NoteModel note,
  ) {
    return service.addNote(note);
  }

  /// Get Notes
  Stream<List<NoteModel>> getNotes({
    required String courseId,
  }) {
    return service.getNotes(
      courseId: courseId,
    );
  }

  /// Update Note
  Future<void> updateNote(
    NoteModel note,
  ) {
    return service.updateNote(note);
  }

  /// Delete Note
  Future<void> deleteNote(
    String noteId,
  ) {
    return service.deleteNote(noteId);
  }
}