import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:nexcampus_app/features/authentication/services/auth_wrapper.dart';
import 'package:nexcampus_app/features/authentication/blocs/auth/auth_bloc.dart';

import 'package:nexcampus_app/features/student/blocs/assignment/bloc/assignment_bloc.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_submission_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_submission_service.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/attendance/blocs/bloc/attendance_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/repositories/attendance_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/services/attendance_service.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/courses/blocs/bloc/course_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/repository/course_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/services/course_service.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/repository/note_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/services/note_service.dart';
import 'package:nexcampus_app/features/authentication/presentation/pages/splash_screen.dart';

class NexCampusApp extends StatelessWidget {
  const NexCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),

        BlocProvider<CourseBloc>(
          create: (_) => CourseBloc(CourseRepository(CourseService())),
        ),

        BlocProvider<AttendanceBloc>(
          create: (_) =>
              AttendanceBloc(AttendanceRepository(AttendanceService())),
        ),

        BlocProvider<AssignmentBloc>(
          create: (_) => AssignmentBloc(
            AssignmentRepository(AssignmentService()),
            AssignmentSubmissionRepository(AssignmentSubmissionService()),
          ),
        ),

        BlocProvider<NoteBloc>(
          create: (_) => NoteBloc(NoteRepository(NoteService())),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "NexCampus",
        theme: ThemeData(useMaterial3: true),
        home: const SplashScreen(),
      ),
    );
  }
}
