// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../models/assignment_model.dart';

// class AssignmentService {
//   final FirebaseFirestore firestore =
//       FirebaseFirestore.instance;

//   CollectionReference get assignmentCollection =>
//       firestore.collection("assignments");

//   /// Create Assignment
//   Future<void> createAssignment({
//     required AssignmentModel assignment,
//   }) async {
//     await assignmentCollection
//         .doc(assignment.id)
//         .set(assignment.toMap());
//   }

//   /// Update Assignment
//   Future<void> updateAssignment({
//     required AssignmentModel assignment,
//   }) async {
//     await assignmentCollection
//         .doc(assignment.id)
//         .update(assignment.toMap());
//   }

//   /// Delete Assignment
//   Future<void> deleteAssignment(
//     String assignmentId,
//   ) async {
//     await assignmentCollection
//         .doc(assignmentId)
//         .delete();
//   }

//   /// Assignment List
//   Stream<List<AssignmentModel>> getAssignments({
//     required String department,
//     required String semester,
//   }) {
//     return assignmentCollection
//         .where(
//           "department",
//           isEqualTo: department,
//         )
//         .where(
//           "semester",
//           isEqualTo: semester,
//         )
//         .orderBy(
//           "createdAt",
//           descending: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map(
//                 (doc) => AssignmentModel.fromMap(
//                   doc.data()
//                       as Map<String, dynamic>,
//                   doc.id,
//                 ),
//               )
//               .toList(),
//         );
//   }

//   /// Single Assignment
//   Future<AssignmentModel?> getAssignment(
//     String assignmentId,
//   ) async {
//     final doc = await assignmentCollection
//         .doc(assignmentId)
//         .get();

//     if (!doc.exists) return null;

//     return AssignmentModel.fromMap(
//       doc.data() as Map<String, dynamic>,
//       doc.id,
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/assignment_model.dart';


class AssignmentService {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;


  CollectionReference get assignmentCollection =>
      firestore.collection("assignments");



  /// Create Assignment
  Future<void> createAssignment({
    required AssignmentModel assignment,
  }) async {

    try {

      await assignmentCollection
          .doc(assignment.id)
          .set(
            assignment.toMap(),
          );

    } catch (e) {

      throw Exception(
        "Failed to create assignment: $e",
      );

    }
  }




  /// Update Assignment
  Future<void> updateAssignment({
    required AssignmentModel assignment,
  }) async {

    try {

      await assignmentCollection
          .doc(assignment.id)
          .update(
            assignment.toMap(),
          );

    } catch (e) {

      throw Exception(
        "Failed to update assignment: $e",
      );

    }
  }





  /// Delete Assignment
  Future<void> deleteAssignment(
  String id,
) async {
  await firestore
      .collection("assignments")
      .doc(id)
      .delete();
}






  /// Get Assignments By Department + Semester
 Stream<List<AssignmentModel>> getAssignments({
  required String department,
  required String semester,
  required String subject,
}) {
  return assignmentCollection
      .where("department", isEqualTo: department)
      .where("semester", isEqualTo: semester)
      .where("subject", isEqualTo: subject)
      .orderBy("createdAt", descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => AssignmentModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,

              ),
            )
            .toList(),
      );
}




  /// Get Teacher Assignments
  Stream<List<AssignmentModel>> getTeacherAssignments({
    required String teacherId,
  }) {


    return assignmentCollection

        .where(
          "teacherId",
          isEqualTo: teacherId,
        )

        .orderBy(
          "createdAt",
          descending: true,
        )

        .snapshots()


        .map(
          (snapshot) {

            return snapshot.docs
                .map(
                  (doc) =>
                      AssignmentModel.fromMap(
                        doc.data()
                            as Map<String,dynamic>,
                        doc.id,
                      ),
                )
                .toList();

          },
        );
  }






  /// Get Single Assignment
  Future<AssignmentModel?> getAssignment(
      String assignmentId,
      ) async {


    final doc =
        await assignmentCollection
            .doc(assignmentId)
            .get();


    if (!doc.exists) {
      return null;
    }


    return AssignmentModel.fromMap(
      doc.data()
          as Map<String,dynamic>,
      doc.id,
    );

  }





  /// Update Submission Count
  Future<void> updateSubmissionCount({
    required String assignmentId,
    required int count,
  }) async {


    await assignmentCollection
        .doc(assignmentId)
        .update({

      "submissionCount": count,

    });

  }


}