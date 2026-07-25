import 'package:equatable/equatable.dart';

import '../models/assignment_model.dart';

abstract class AssignmentState extends Equatable {
  const AssignmentState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AssignmentInitial extends AssignmentState {
  const AssignmentInitial();
}

/// Loading assignments
class AssignmentLoading extends AssignmentState {
  const AssignmentLoading();
}

/// Loaded successfully
class AssignmentLoaded extends AssignmentState {
  final List<StudentAssignmentModel> assignments;

  const AssignmentLoaded({required this.assignments});

  /// Pending assignments
  List<StudentAssignmentModel> get pendingAssignments =>
      assignments.where((assignment) {
        return assignment.status == StudentAssignmentStatus.pending;
      }).toList();

  /// Submitted assignments
  List<StudentAssignmentModel> get submittedAssignments =>
      assignments.where((assignment) {
        return assignment.status == StudentAssignmentStatus.submitted;
      }).toList();

  /// Graded assignments
  List<StudentAssignmentModel> get gradedAssignments =>
      assignments.where((assignment) {
        return assignment.status == StudentAssignmentStatus.graded;
      }).toList();

  /// Overdue assignments
  List<StudentAssignmentModel> get overdueAssignments =>
      assignments.where((assignment) {
        return assignment.status == StudentAssignmentStatus.overdue;
      }).toList();

  int get totalAssignments => assignments.length;

  int get pendingCount => pendingAssignments.length;

  int get submittedCount => submittedAssignments.length;

  int get gradedCount => gradedAssignments.length;

  int get overdueCount => overdueAssignments.length;

  bool get isEmpty => assignments.isEmpty;

  AssignmentLoaded copyWith({List<StudentAssignmentModel>? assignments}) {
    return AssignmentLoaded(assignments: assignments ?? this.assignments);
  }

  @override
  List<Object?> get props => [assignments];
}

/// Error state
class AssignmentError extends AssignmentState {
  final String message;

  const AssignmentError({required this.message});

  @override
  List<Object?> get props => [message];
}
