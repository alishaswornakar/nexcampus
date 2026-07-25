import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/authentication/blocs/auth/auth_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_repository.dart';
import 'package:nexcampus_app/features/student/blocs/assignment/bloc/assignment_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/blocs/bloc/attendance_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/repositories/attendance_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/services/attendance_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/blocs/bloc/course_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/repository/course_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/services/course_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/blocs/bloc/notes_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/repository/note_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/services/note_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_submission_repository.dart';
import 'firebase_options.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_submission_service.dart';
import 'package:nexcampus_app/features/authentication/services/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const NexCampusApp());
}

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
        title: 'NexCampus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),

        // ✅ This handles login / role routing
        home: const AuthWrapper(),
      ),
    );
  }
}
