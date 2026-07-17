import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/models/assignment_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_repository.dart';



part 'assignment_event.dart';
part 'assignment_state.dart';

class AssignmentBloc
    extends Bloc<AssignmentEvent, AssignmentState> {
  final AssignmentRepository repository;

  StreamSubscription? _subscription;

  AssignmentBloc(this.repository)
      : super(AssignmentInitial()) {
    on<CreateAssignment>(_createAssignment);
    on<UpdateAssignment>(_updateAssignment);
    on<DeleteAssignment>(_deleteAssignment);
    on<LoadAssignments>(_loadAssignments);
  }

  Future<void> _createAssignment(
    CreateAssignment event,
    Emitter<AssignmentState> emit,
  ) async {
    emit(AssignmentLoading());

    try {
      await repository.createAssignment(
        event.assignment,
      );

      emit(AssignmentCreated());
    } catch (e) {
      emit(
        AssignmentError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> _updateAssignment(
    UpdateAssignment event,
    Emitter<AssignmentState> emit,
  ) async {
    emit(AssignmentLoading());

    try {
      await repository.updateAssignment(
        event.assignment,
      );

      emit(AssignmentUpdated());
    } catch (e) {
      emit(
        AssignmentError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> _deleteAssignment(
    DeleteAssignment event,
    Emitter<AssignmentState> emit,
  ) async {
    emit(AssignmentLoading());

    try {
      await repository.deleteAssignment(
        event.assignmentId,
      );

      emit(AssignmentDeleted());
    } catch (e) {
      emit(
        AssignmentError(
          e.toString(),
        ),
      );
    }
  }

  void _loadAssignments(
    LoadAssignments event,
    Emitter<AssignmentState> emit,
  ) {
    emit(AssignmentLoading());

   _subscription?.cancel();

_subscription = repository
    .getAssignments(
      department: event.department,
      semester: event.semester,
      subject: event.subject,
    )
    .listen(
      (assignments) {
        emit(
          AssignmentsLoaded(assignments),
        );
      },
      onError: (e) {
        emit(
          AssignmentError(e.toString()),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}