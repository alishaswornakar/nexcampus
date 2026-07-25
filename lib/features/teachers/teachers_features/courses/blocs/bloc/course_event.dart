part of 'course_bloc.dart';

abstract class CourseEvent {}

/// Load Courses
class LoadCoursesEvent extends CourseEvent {
  final String department;
  final String semester;

  LoadCoursesEvent({
    required this.department,
    required this.semester,
  });
}

/// Add Course
class AddCourseEvent extends CourseEvent {
  final CourseModel course;

  AddCourseEvent(this.course);
}

/// Update Course
class UpdateCourseEvent extends CourseEvent {
  final CourseModel course;

  UpdateCourseEvent(this.course);
}

/// Delete Course
class DeleteCourseEvent extends CourseEvent {
  final String courseId;

  DeleteCourseEvent(this.courseId);
}