import '../models/course_model.dart';
import '../services/course_service.dart';

class CourseRepository {
  final CourseService service;

  CourseRepository(this.service);

  /// ============================
  /// Add Course
  /// ============================
  Future<void> addCourse(
    CourseModel course,
  ) {
    return service.addCourse(
      course: course,
    );
  }

  /// ============================
  /// Update Course
  /// ============================
  Future<void> updateCourse(
    CourseModel course,
  ) {
    return service.updateCourse(
      course: course,
    );
  }

  /// ============================
  /// Delete Course
  /// ============================
  Future<void> deleteCourse(
    String courseId,
  ) {
    return service.deleteCourse(
      courseId,
    );
  }

  /// ============================
  /// Load Courses
  /// ============================
  Stream<List<CourseModel>> getCourses({
    required String department,
    required String semester,
  }) {
    return service.getCourses(
      department: department,
      semester: semester,
    );
  }
}