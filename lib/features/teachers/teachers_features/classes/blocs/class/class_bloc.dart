
import 'package:nexcampus_app/features/teachers/teachers_features/classes/blocs/class/class_event.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/blocs/class/class_state.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/classes/repository/classes_repository.dart';





class ClassesBloc
    extends Bloc<ClassesEvent, ClassesState> {
  final ClassesRepository repository;

  ClassesBloc(this.repository)
      : super(ClassesInitial()) {
    on<LoadStudents>(_loadStudents);
  }

  Future<void> _loadStudents(
    LoadStudents event,
    Emitter<ClassesState> emit,
  ) async {
    emit(ClassesLoading());

    await emit.forEach<List<StudentModel>>(
      repository.students(
        event.department,
        event.semester,
      ),
      onData: (students) =>
          ClassesLoaded(students),
      onError: (error, stackTrace) =>
          ClassesError(error.toString()),
    );
  }
}