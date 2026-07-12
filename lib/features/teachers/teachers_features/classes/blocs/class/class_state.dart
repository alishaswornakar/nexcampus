import 'package:nexcampus_app/features/teachers/teachers_features/classes/models/student_model.dart';




abstract class ClassesState {}

class ClassesInitial extends ClassesState {}

class ClassesLoading extends ClassesState {}

class ClassesLoaded extends ClassesState {
  final List<StudentModel> students;

  ClassesLoaded(this.students);
}

class ClassesError extends ClassesState {
  final String message;

  ClassesError(this.message);
}