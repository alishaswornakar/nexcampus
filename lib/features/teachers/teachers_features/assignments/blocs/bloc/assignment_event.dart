part of 'assignment_bloc.dart';

abstract class AssignmentEvent {}

/// Create Assignment
class CreateAssignment extends AssignmentEvent {
  final AssignmentModel assignment;

  CreateAssignment(this.assignment);
}

/// Update Assignment
class UpdateAssignment extends AssignmentEvent {
  final AssignmentModel assignment;

  UpdateAssignment(this.assignment);
}

/// Delete Assignment
class DeleteAssignment extends AssignmentEvent {
  final String assignmentId;

  DeleteAssignment(this.assignmentId);
}

/// Load Assignments
class LoadAssignments extends AssignmentEvent {
  final String department;
  final String semester;
  final String subject;

  LoadAssignments({
    required this.department,
    required this.semester,
    required this.subject,
  });
}