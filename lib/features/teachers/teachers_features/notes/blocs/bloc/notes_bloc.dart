import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_event.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_state.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/model/note_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/repository/note_repository.dart';
import 'package:nexcampus_app/features/student/blocs/notification/models/notification_model.dart';
import 'package:nexcampus_app/features/student/blocs/notification/services/notification_service.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository repository;

  NoteBloc(this.repository) : super(NoteInitial()) {
    on<LoadNotesEvent>(_loadNotes);
    on<AddNoteEvent>(_addNote);
    on<UpdateNoteEvent>(_updateNote);
    on<DeleteNoteEvent>(_deleteNote);
  }

  /// Load Notes
  Future<void> _loadNotes(LoadNotesEvent event, Emitter<NoteState> emit) async {
    emit(NoteLoading());

    await emit.forEach<List<NoteModel>>(
      repository.getNotes(courseId: event.courseId),
      onData: (notes) => NotesLoaded(notes),
      onError: (error, _) => NoteError(error.toString()),
    );
  }

  /// Add Note
  Future<void> _addNote(AddNoteEvent event, Emitter<NoteState> emit) async {
    emit(NoteLoading());

    try {
      await repository.addNote(event.note);

      try {
        await NotificationService().createNotification(
          NotificationModel(
            id: '',
            title: "New Note: ${event.note.title}",
            body: event.note.description,
            type: NotificationType.note,
            targetType: NotificationTargetType.course,
            targetId: event.note.courseId,
            courseId: event.note.courseId,
            courseName: event.note.courseName,
            senderId: '',
            senderName: event.note.uploadedBy,
            createdAt: DateTime.now(),
          ),
        );
      } catch (_) {}

      emit(NoteAdded());
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  /// Update Note
  Future<void> _updateNote(
    UpdateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoading());

    try {
      await repository.updateNote(event.note);

      emit(NoteUpdated());
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  /// Delete Note
  Future<void> _deleteNote(
    DeleteNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoading());

    try {
      await repository.deleteNote(event.noteId);

      emit(NoteDeleted());
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }
}
