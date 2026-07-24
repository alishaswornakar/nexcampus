import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/repository/course_repository.dart';

import '../../models/course_model.dart';


part 'course_event.dart';
part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository repository;

  CourseBloc(this.repository) : super(CourseInitial()) {

    on<LoadCoursesEvent>(_loadCourses);
    on<AddCourseEvent>(_addCourse);
    on<UpdateCourseEvent>(_updateCourse);
    on<DeleteCourseEvent>(_deleteCourse);

  }


  Future<void> _loadCourses(
  LoadCoursesEvent event,
  Emitter<CourseState> emit,
) async {

  emit(CourseLoading());

  try {

    await emit.forEach<List<CourseModel>>(
      repository.getCourses(
        department: event.department,
        semester: event.semester,
      ),
      onData: (courses) {
        return CoursesLoaded(courses);
      },
      onError: (error, stackTrace) {
        return CourseError(error.toString());
      },
    );

  } catch (e) {
    emit(CourseError(e.toString()));
  }
}


  Future<void> _addCourse(
    AddCourseEvent event,
    Emitter<CourseState> emit,
  ) async {

    emit(CourseLoading());

    try {
      await repository.addCourse(event.course);
      emit(CourseAdded());

    } catch(e) {
      emit(CourseError(e.toString()));
    }
  }


  Future<void> _updateCourse(
    UpdateCourseEvent event,
    Emitter<CourseState> emit,
  ) async {

    emit(CourseLoading());

    try {
      await repository.updateCourse(event.course);
      emit(CourseUpdated());

    } catch(e) {
      emit(CourseError(e.toString()));
    }
  }


  Future<void> _deleteCourse(
    DeleteCourseEvent event,
    Emitter<CourseState> emit,
  ) async {

    emit(CourseLoading());

    try {
      await repository.deleteCourse(event.courseId);
      emit(CourseDeleted());

    } catch(e) {
      emit(CourseError(e.toString()));
    }
  }
}