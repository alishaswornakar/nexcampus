import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';


import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_event.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_state.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notes/repository/note_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/screens/add_note_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/screens/note_detail_screen.dart';
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

          elevation: 0,

          centerTitle: true,

          backgroundColor: AppTheme.primary,

          foregroundColor: Colors.white,

          title: Text(

            course.courseName,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

          ),

        ),

        floatingActionButton: LayoutBuilder(

          builder: (context, constraints) {

            final isTablet =
                constraints.maxWidth >= 600;

            return FloatingActionButton.extended(

              backgroundColor: AppTheme.primary,

              foregroundColor: Colors.white,

              icon: const Icon(Icons.add),

              label: Text(

                isTablet
                    ? "Upload Note"
                    : "Add",

              ),

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

            );

          },

        ),
                body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final bool isTablet = width >= 600;
            final bool isDesktop = width >= 1000;

            return BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {

                if (state is NoteLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is NoteError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [

                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 70,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.primary,
                              foregroundColor:
                                  Colors.white,
                            ),
                            onPressed: () {
                              context.read<NoteBloc>().add(
                                    LoadNotesEvent(
                                      courseId: course.id,
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is NotesLoaded) {

                  if (state.notes.isEmpty) {

                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [

                            Icon(
                              Icons.menu_book_outlined,
                              size: isTablet ? 110 : 90,
                              color: Colors.grey,
                            ),

                            const SizedBox(height: 18),

                            Text(
                              "No Notes Uploaded",
                              style: TextStyle(
                                fontSize:
                                    isTablet ? 24 : 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Tap the + button to upload your first note.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize:
                                    isTablet ? 16 : 14,
                              ),
                            ),

                          ],
                        ),
                      ),
                    );

                  }

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            isDesktop ? 950 : double.infinity,
                      ),
                                            child: RefreshIndicator(

                        onRefresh: () async {

                          context.read<NoteBloc>().add(

                                LoadNotesEvent(
                                  courseId: course.id,
                                ),

                              );

                        },

                        child: ListView.builder(

                          physics:
                              const AlwaysScrollableScrollPhysics(),

                          padding: EdgeInsets.symmetric(

                            horizontal:
                                isDesktop
                                    ? 30
                                    : isTablet
                                        ? 24
                                        : 16,

                            vertical:
                                isTablet
                                    ? 24
                                    : 16,

                          ),

                          itemCount:
                              state.notes.length,

                          itemBuilder:
                              (context, index) {

                            final note =
                                state.notes[index];

                            return Padding(

                              padding:
                                  const EdgeInsets.only(
                                bottom: 16,
                              ),

                              child: NoteTile(

                                note: note,

                                onTap: () {

                                  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => NoteDetailScreen(
        note: note,
      ),
    ),
  );
                                  
                                },

                                onDelete: () {

                                  showDialog(

                                    context: context,

                                    builder: (_) => AlertDialog(

                                      shape:
                                          RoundedRectangleBorder(

                                        borderRadius:
                                            BorderRadius.circular(
                                                18),

                                      ),

                                      title: const Text(
                                        "Delete Note",
                                      ),

                                      content: Text(
                                        "Are you sure you want to delete '${note.title}'?",
                                      ),

                                      actions: [

                                        TextButton(

                                          onPressed: () {

                                            Navigator.pop(
                                                context);

                                          },

                                          child:
                                              const Text(
                                            "Cancel",
                                          ),

                                        ),

                                        ElevatedButton(

                                          style:
                                              ElevatedButton.styleFrom(

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

                                          child:
                                              const Text(
                                            "Delete",
                                          ),

                                        ),

                                      ],

                                    ),

                                  );

                                },

                              ),

                            );

                          },

                        ),

                      ),
                                          ),

                  );

                }

                return const SizedBox.shrink();

              },

            );

          },

        ),

      ),

    );

  }

}