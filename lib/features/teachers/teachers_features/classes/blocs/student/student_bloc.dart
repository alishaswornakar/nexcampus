// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';
// import 'package:nexcampus_app/features/teachers/teachers_features/classes/repository/classes_repository.dart';

// part 'student_event.dart';
// part 'student_state.dart';

// class StudentBloc extends Bloc<StudentEvent, StudentState> {
//   final ClassesRepository repository;

//   StudentBloc(this.repository) : super(StudentInitial()) {
//     on<LoadStudents>(_onLoadStudents);
//   }

//   Future<void> _onLoadStudents(
//   LoadStudents event,
//   Emitter<StudentState> emit,
// ) async {
//   emit(StudentLoading());

//   // await emit.forEach<List<StudentModel>>(
//     repository.getStudents(),
//     onData: (students) => StudentLoaded(students),
//     onError: (error, stackTrace) =>
//         StudentError(error.toString()),
//   );
// }
// }