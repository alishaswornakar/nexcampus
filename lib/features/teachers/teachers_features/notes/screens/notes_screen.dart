import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_event.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_state.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/repository/note_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/screens/add_note_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/widgets/note_tile.dart';

import '../../courses/models/course_model.dart';

import '../services/note_service.dart';


class NoteScreen extends StatelessWidget {
  final CourseModel course;

  const NoteScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoteBloc(
        NoteRepository(
          NoteService(),
        ),
      )..add(
          LoadNotesEvent(
            courseId: course.id,
          ),
        ),

      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FA),

        appBar: AppBar(
          title: Text(course.courseName),
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),

          onPressed: () {
            Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: context.read<NoteBloc>(),
      child: AddNoteScreen(
        course: course,
      ),
    ),
  ),
);
          },
        ),

        body: BlocBuilder<
            NoteBloc,
            NoteState>(
          builder: (context, state) {
            if (state is NoteLoading) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (state is NoteError) {
              return Center(
                child: Text(
                  state.message,
                ),
              );
            }

            if (state is NotesLoaded) {
                            if (state.notes.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 90,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No Notes Uploaded",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tap + to upload your first note",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NoteBloc>().add(
                        LoadNotesEvent(
                          courseId: course.id,
                        ),
                      );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.notes.length,
                  itemBuilder: (context, index) {
                    final note = state.notes[index];

                    return NoteTile(
                      note: note,

                      onTap: () {
                        // Next:
                        // Open PDF/Image
                      },

                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text(
                              "Delete Note",
                            ),
                            content: Text(
                              "Delete '${note.title}'?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(
                                        context),
                                child:
                                    const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Colors.red,
                                  foregroundColor:
                                      Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(
                                      context);

                                  context
                                      .read<
                                          NoteBloc>()
                                      .add(
                                        DeleteNoteEvent(
                                          note.id,
                                        ),
                                      );
                                },
                                child: const Text(
                                  "Delete",
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              );
                          }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}