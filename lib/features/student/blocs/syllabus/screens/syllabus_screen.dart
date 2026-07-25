import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../bloc/syllabus_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/syllabus/bloc/syllabus_event.dart';
import 'package:nexcampus_app/features/student/blocs/syllabus/bloc/syllabus_state.dart';
import 'syllabus_subject_screen.dart';

class SyllabusScreen extends StatelessWidget {
  const SyllabusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SyllabusBloc()..add(const LoadSyllabus()),
      child: const _SyllabusView(),
    );
  }
}

class _SyllabusView extends StatelessWidget {
  const _SyllabusView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syllabus', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppTheme.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<SyllabusBloc, SyllabusState>(
        builder: (context, state) {
          if (state is SyllabusLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SyllabusError) {
            return Center(child: Text(state.message));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 8,
            itemBuilder: (context, index) {
              final semester = index + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.secondary,
                      child: Text(
                        semester.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      "Semester $semester",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("View subjects and Syllabus"),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                    onTap: () {
                      context.read<SyllabusBloc>().add(
                        SelectSyllabusSemester(semester),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SyllabusSubjectScreen(semester: semester),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
