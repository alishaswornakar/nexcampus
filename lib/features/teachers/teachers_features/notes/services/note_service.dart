import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/model/note_model.dart';



class NoteService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference get notesCollection =>
      firestore.collection("notes");

  /// Add Note
 Future<void> addNote(NoteModel note) async {
  final docRef = notesCollection.doc();

  await docRef.set(
    note.toMap(),
  );
}

  /// Get Notes by Course
  Stream<List<NoteModel>> getNotes({
    required String courseId,
  }) {
    return notesCollection
        .where("courseId", isEqualTo: courseId)
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NoteModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Update Note
  Future<void> updateNote(
    NoteModel note,
  ) async {
    await notesCollection
        .doc(note.id)
        .update(note.toMap());
  }

  /// Delete Note
  Future<void> deleteNote(
    String noteId,
  ) async {
    await notesCollection
        .doc(noteId)
        .delete();
  }
}