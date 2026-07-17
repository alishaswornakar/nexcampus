// import '../models/assignment_model.dart';
// import '../services/assignment_service.dart';

// class AssignmentRepository {
//   final AssignmentService service;

//   AssignmentRepository(this.service);

//   /// Create Assignment
//   Future<void> createAssignment(
//     AssignmentModel assignment,
//   ) {
//     return service.createAssignment(
//       assignment: assignment,
//     );
//   }

//   /// Update Assignment
//   Future<void> updateAssignment(
//     AssignmentModel assignment,
//   ) {
//     return service.updateAssignment(
//       assignment: assignment,
//     );
//   }

//   /// Delete Assignment
//   Future<void> deleteAssignment(
//     String assignmentId,
//   ) {
//     return service.deleteAssignment(
//       assignmentId,
//     );
//   }

//   /// Assignment List
//   Stream<List<AssignmentModel>> getAssignments({
//     required String department,
//     required String semester,
//   }) {
//     return service.getAssignments(
//       department: department,
//       semester: semester,
//     );
//   }

//   /// Get Single Assignment
//   Future<AssignmentModel?> getAssignment(
//     String assignmentId,
//   ) {
//     return service.getAssignment(
//       assignmentId,
//     );
//   }
// }
import '../models/assignment_model.dart';
import '../services/assignment_service.dart';


class AssignmentRepository {

  final AssignmentService service;


  AssignmentRepository(
    this.service,
  );



  /// Create Assignment
  Future<void> createAssignment(
    AssignmentModel assignment,
  ) {

    return service.createAssignment(
      assignment: assignment,
    );

  }





  /// Update Assignment
  Future<void> updateAssignment(
    AssignmentModel assignment,
  ) {

    return service.updateAssignment(
      assignment: assignment,
    );

  }





  /// Delete Assignment
  Future<void> deleteAssignment(
  String id,
) {
  return service.deleteAssignment(id);
}





  /// Get Assignments
Stream<List<AssignmentModel>> getAssignments({
  required String department,
  required String semester,
  required String subject,
}) {
  return service.getAssignments(
    department: department,
    semester: semester,
    subject: subject,
  );
}




  /// Get Teacher Assignments
  Stream<List<AssignmentModel>> getTeacherAssignments({

    required String teacherId,

  }) {


    return service.getTeacherAssignments(
      teacherId: teacherId,
    );

  }





  /// Get Single Assignment
  Future<AssignmentModel?> getAssignment(

    String assignmentId,

  ) {


    return service.getAssignment(
      assignmentId,
    );

  }





  /// Update Submission Count
  Future<void> updateSubmissionCount({

    required String assignmentId,

    required int count,

  }) {


    return service.updateSubmissionCount(
      assignmentId: assignmentId,
      count: count,
    );

  }


}