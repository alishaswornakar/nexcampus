import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class CourseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference get courseCollection =>
      firestore.collection("courses");

  /// ============================
  /// Add Course
  /// ============================
  Future<void> addCourse({
    required CourseModel course,
  }) async {
    await courseCollection.doc(course.id).set(
          course.toMap(),
        );
  }

  /// ============================
  /// Update Course
  /// ============================
  Future<void> updateCourse({
    required CourseModel course,
  }) async {
    await courseCollection.doc(course.id).update(
          course.toMap(),
        );
  }

  /// ============================
  /// Delete Course
  /// ============================
  Future<void> deleteCourse(
    String courseId,
  ) async {
    await courseCollection.doc(courseId).delete();
  }

  /// ============================
  /// Load Courses
  /// ============================
  Stream<List<CourseModel>> getCourses({
    required String department,
    required String semester,
  }) {
    return courseCollection
        .where(
          "department",
          isEqualTo: department,
        )
        .where(
          "semester",
          isEqualTo: semester,
        )
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CourseModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }
}