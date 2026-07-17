part of 'assignment_bloc.dart';

abstract class AssignmentState {}

class AssignmentInitial extends AssignmentState {}

class AssignmentLoading extends AssignmentState {}

class AssignmentCreated extends AssignmentState {}

class AssignmentUpdated extends AssignmentState {}

class AssignmentDeleted extends AssignmentState {}

class AssignmentsLoaded extends AssignmentState {
  final List<AssignmentModel> assignments;

  AssignmentsLoaded(this.assignments);
}

class AssignmentError extends AssignmentState {
  final String message;

  AssignmentError(this.message);
}