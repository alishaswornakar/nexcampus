import 'package:equatable/equatable.dart';

abstract class AssignmentEvent extends Equatable {
  const AssignmentEvent();

  @override
  List<Object?> get props => [];
}

/// Load assignments for the logged-in student.
class LoadAssignments extends AssignmentEvent {
  final String department;
  final String semester;
  final String studentId;

  const LoadAssignments({
    required this.department,
    required this.semester,
    required this.studentId,
  });

  @override
  List<Object?> get props => [department, semester, studentId];
}

/// Refresh assignments.
class RefreshAssignments extends AssignmentEvent {
  final String department;
  final String semester;
  final String studentId;

  const RefreshAssignments({
    required this.department,
    required this.semester,
    required this.studentId,
  });

  @override
  List<Object?> get props => [department, semester, studentId];
}

/// Start listening to live assignment updates.
class WatchAssignments extends AssignmentEvent {
  final String department;
  final String semester;
  final String studentId;

  const WatchAssignments({
    required this.department,
    required this.semester,
    required this.studentId,
  });

  @override
  List<Object?> get props => [department, semester, studentId];
}

/// Called after a student successfully submits an assignment.
class AssignmentSubmitted extends AssignmentEvent {
  final String assignmentId;

  const AssignmentSubmitted(this.assignmentId);

  @override
  List<Object?> get props => [assignmentId];
}
