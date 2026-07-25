part of 'course_bloc.dart';

abstract class CourseState {}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseAdded extends CourseState {}

class CourseUpdated extends CourseState {}

class CourseDeleted extends CourseState {}

class CourseError extends CourseState {
  final String message;

  CourseError(this.message);
}

class CoursesLoaded extends CourseState {
  final List<CourseModel> courses;

  CoursesLoaded(this.courses);
}