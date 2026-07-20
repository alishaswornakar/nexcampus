import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/assignments/models/assignment_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/models/assignment_submission_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_submission_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/assignment_submission_service.dart';

import '../../models/assignment_model.dart';
import 'assignment_event.dart';
import 'assignment_state.dart';

/// Internal event: fired whenever the underlying assignment stream
/// (Firestore "assignments" collection, filtered by department + semester)
/// emits a new snapshot. Never dispatched from the UI.
class _AssignmentsUpdated extends AssignmentEvent {
  final List<AssignmentModel> assignments;

  const _AssignmentsUpdated(this.assignments);

  @override
  List<Object?> get props => [assignments];
}

/// Internal event: fired whenever the underlying submission stream
/// (Firestore "assignment_submissions" collection, filtered by studentId)
/// emits a new snapshot. Never dispatched from the UI.
class _SubmissionsUpdated extends AssignmentEvent {
  final List<AssignmentSubmissionModel> submissions;

  const _SubmissionsUpdated(this.submissions);

  @override
  List<Object?> get props => [submissions];
}

/// Internal event: fired when either Firestore stream errors out.
class _StreamFailed extends AssignmentEvent {
  final String message;

  const _StreamFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Manages the student-facing assignment feed.
///
/// It merges two independent Firestore streams:
/// - [AssignmentRepository.getStudentAssignments] — assignments visible
///   to a student's department + semester.
/// - [AssignmentSubmissionRepository.getStudentSubmissions] — everything
///   that student has personally submitted (including grading info).
///
/// Every time either stream emits, the two latest snapshots are merged
/// into a list of [StudentAssignmentModel], each carrying a derived
/// [StudentAssignmentStatus] (pending / overdue / submitted / graded).
///
/// Repositories are instantiated internally — no dependency injection.
class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final AssignmentRepository _assignmentRepository;
  final AssignmentSubmissionRepository _submissionRepository;

  StreamSubscription<List<AssignmentModel>>? _assignmentSubscription;
  StreamSubscription<List<AssignmentSubmissionModel>>? _submissionSubscription;

  List<AssignmentModel> _latestAssignments = const [];
  List<AssignmentSubmissionModel> _latestSubmissions = const [];
  bool _hasReceivedAssignments = false;

  AssignmentBloc()
    : _assignmentRepository = AssignmentRepository(AssignmentService()),
      _submissionRepository = AssignmentSubmissionRepository(
        AssignmentSubmissionService(),
      ),
      super(const AssignmentInitial()) {
    on<LoadAssignments>(_onLoadAssignments);
    on<RefreshAssignments>(_onRefreshAssignments);
    on<WatchAssignments>(_onWatchAssignments);
    on<AssignmentSubmitted>(_onAssignmentSubmitted);

    on<_AssignmentsUpdated>(_onAssignmentsUpdated);
    on<_SubmissionsUpdated>(_onSubmissionsUpdated);
    on<_StreamFailed>(_onStreamFailed);
  }

  // ---------------------------------------------------------------------------
  // Public event handlers
  // ---------------------------------------------------------------------------

  void _onLoadAssignments(
    LoadAssignments event,
    Emitter<AssignmentState> emit,
  ) {
    emit(const AssignmentLoading());
    _watch(
      department: event.department,
      semester: event.semester,
      studentId: event.studentId,
    );
  }

  void _onWatchAssignments(
    WatchAssignments event,
    Emitter<AssignmentState> emit,
  ) {
    emit(const AssignmentLoading());
    _watch(
      department: event.department,
      semester: event.semester,
      studentId: event.studentId,
    );
  }

  void _onRefreshAssignments(
    RefreshAssignments event,
    Emitter<AssignmentState> emit,
  ) {
    // Deliberately no AssignmentLoading emission here — a pull-to-refresh
    // shouldn't blank out the currently visible list. The existing
    // AssignmentLoaded state stays on screen until the streams resettle.
    _watch(
      department: event.department,
      semester: event.semester,
      studentId: event.studentId,
    );
  }

  void _onAssignmentSubmitted(
    AssignmentSubmitted event,
    Emitter<AssignmentState> emit,
  ) {
    // No-op by design: the submission write already happened wherever this
    // event was dispatched from (e.g. the submit flow calling the
    // AssignmentSubmissionRepository directly). The live Firestore listener
    // on _submissionSubscription will pick up that write on its own and
    // push a fresh AssignmentLoaded through _onSubmissionsUpdated.
  }

  // ---------------------------------------------------------------------------
  // Internal stream-driven handlers
  // ---------------------------------------------------------------------------

  void _onAssignmentsUpdated(
    _AssignmentsUpdated event,
    Emitter<AssignmentState> emit,
  ) {
    _latestAssignments = event.assignments;
    _hasReceivedAssignments = true;
    emit(AssignmentLoaded(assignments: _mergeAssignments()));
  }

  void _onSubmissionsUpdated(
    _SubmissionsUpdated event,
    Emitter<AssignmentState> emit,
  ) {
    _latestSubmissions = event.submissions;

    // Wait for the first assignments snapshot before emitting, so we don't
    // flash an "empty" loaded state while assignments are still in flight.
    if (_hasReceivedAssignments) {
      emit(AssignmentLoaded(assignments: _mergeAssignments()));
    }
  }

  void _onStreamFailed(_StreamFailed event, Emitter<AssignmentState> emit) {
    emit(AssignmentError(message: event.message));
  }

  // ---------------------------------------------------------------------------
  // Subscription management
  // ---------------------------------------------------------------------------

  void _watch({
    required String department,
    required String semester,
    required String studentId,
  }) {
    _assignmentSubscription?.cancel();
    _submissionSubscription?.cancel();

    _latestAssignments = const [];
    _latestSubmissions = const [];
    _hasReceivedAssignments = false;

    _assignmentSubscription = _assignmentRepository
        .getStudentAssignments(department: department, semester: semester)
        .listen(
          (assignments) => add(_AssignmentsUpdated(assignments)),
          onError: (Object error, StackTrace stackTrace) {
            add(_StreamFailed(error.toString()));
          },
        );

    _submissionSubscription = _submissionRepository
        .getStudentSubmissions(studentId: studentId)
        .listen(
          (submissions) => add(_SubmissionsUpdated(submissions)),
          onError: (Object error, StackTrace stackTrace) {
            add(_StreamFailed(error.toString()));
          },
        );
  }

  // ---------------------------------------------------------------------------
  // Merge logic
  // ---------------------------------------------------------------------------

  /// Combines the latest assignment snapshot with the latest submission
  /// snapshot, keyed by [AssignmentSubmissionModel.assignmentId], and wraps
  /// each pairing into a [StudentAssignmentModel]. Result is sorted by
  /// due date, soonest first.
  List<StudentAssignmentModel> _mergeAssignments() {
    final Map<String, AssignmentSubmissionModel> submissionsByAssignmentId = {
      for (final submission in _latestSubmissions)
        submission.assignmentId: submission,
    };

    final List<StudentAssignmentModel> merged = _latestAssignments
        .map(
          (assignment) => StudentAssignmentModel.fromAssignment(
            assignment: assignment,
            submission: submissionsByAssignmentId[assignment.id],
          ),
        )
        .toList();

    merged.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return merged;
  }

  @override
  Future<void> close() {
    _assignmentSubscription?.cancel();
    _submissionSubscription?.cancel();
    return super.close();
  }
}
