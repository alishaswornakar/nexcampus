import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/student_model.dart';

class ClassesService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<StudentModel>> studentsBySemester({
    required String department,
    int? semester,
  }) {
    Query<Map<String, dynamic>> query = firestore
        .collection("users")
        .where("role", isEqualTo: "student")
        .where("department", isEqualTo: department);

    if (semester != null) {
      query = query.where(
        "semester",
        isEqualTo: semester.toString(),
      );
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
               (doc) => StudentModel.fromMap(
          doc.data(),
          doc.id,
        ),
              )
              .toList(),
        );
  }

  Future<int> totalStudents(
    String department,
  ) async {
    final data = await firestore
        .collection("users")
        .where("role", isEqualTo: "student")
        .where("department", isEqualTo: department)
        .get();

    return data.docs.length;
  }
}