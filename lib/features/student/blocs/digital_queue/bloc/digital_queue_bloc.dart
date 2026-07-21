// lib/features/student/blocs/digital_queue/bloc/digital_queue_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';

import '../repository/digital_queue_repository.dart';
import 'digital_queue_event.dart';
import 'digital_queue_state.dart';

/// -----------------------------------------------------------------------
/// BLOC
/// -----------------------------------------------------------------------
/// Coordinates three independent, long-lived Firestore streams (queue
/// services, active token, history) plus one-shot join/cancel actions,
/// all backed by [DigitalQueueRepository]. Mirrors the structure used by
/// the Attendance/Assignment BLoCs: `emit.forEach` for stream events so
/// each stream's error handling and state mapping stays local and
/// declarative.
class DigitalQueueBloc extends Bloc<DigitalQueueEvent, DigitalQueueState> {
  DigitalQueueBloc({required DigitalQueueRepository repository})
    : _repository = repository,
      super(const DigitalQueueState()) {
    on<DigitalQueueServicesSubscriptionRequested>(
      _onServicesSubscriptionRequested,
    );
    on<DigitalQueueActiveTokenSubscriptionRequested>(
      _onActiveTokenSubscriptionRequested,
    );
    on<DigitalQueueHistorySubscriptionRequested>(
      _onHistorySubscriptionRequested,
    );
    on<DigitalQueueJoinRequested>(_onJoinRequested);
    on<DigitalQueueCancelRequested>(_onCancelRequested);
    on<DigitalQueueActionResultCleared>(_onActionResultCleared);
  }

  final DigitalQueueRepository _repository;

  // -----------------------------------------------------------------
  // QUEUE SERVICES STREAM
  // -----------------------------------------------------------------

  Future<void> _onServicesSubscriptionRequested(
    DigitalQueueServicesSubscriptionRequested event,
    Emitter<DigitalQueueState> emit,
  ) async {
    emit(state.copyWith(servicesStatus: QueueServicesStatus.loading));

    await emit.forEach(
      _repository.watchQueueServices(),
      onData: (services) => state.copyWith(
        servicesStatus: QueueServicesStatus.loaded,
        services: services,
        servicesError: null,
      ),
      onError: (error, stackTrace) => state.copyWith(
        servicesStatus: QueueServicesStatus.failure,
        servicesError: _describeError(error),
      ),
    );
  }

  // -----------------------------------------------------------------
  // ACTIVE TOKEN STREAM
  // -----------------------------------------------------------------

  Future<void> _onActiveTokenSubscriptionRequested(
    DigitalQueueActiveTokenSubscriptionRequested event,
    Emitter<DigitalQueueState> emit,
  ) async {
    emit(state.copyWith(activeTokenStatus: ActiveTokenStatus.loading));

    await emit.forEach(
      _repository.watchActiveToken(event.studentId),
      onData: (token) => state.copyWith(
        activeTokenStatus: ActiveTokenStatus.loaded,
        activeToken: token,
        clearActiveToken: token == null,
        activeTokenError: null,
      ),
      onError: (error, stackTrace) => state.copyWith(
        activeTokenStatus: ActiveTokenStatus.failure,
        activeTokenError: _describeError(error),
      ),
    );
  }

  // -----------------------------------------------------------------
  // QUEUE HISTORY STREAM
  // -----------------------------------------------------------------

  Future<void> _onHistorySubscriptionRequested(
    DigitalQueueHistorySubscriptionRequested event,
    Emitter<DigitalQueueState> emit,
  ) async {
    emit(state.copyWith(historyStatus: QueueHistoryStatus.loading));

    await emit.forEach(
      _repository.watchQueueHistory(event.studentId, limit: event.limit),
      onData: (history) => state.copyWith(
        historyStatus: QueueHistoryStatus.loaded,
        history: history,
        historyError: null,
      ),
      onError: (error, stackTrace) => state.copyWith(
        historyStatus: QueueHistoryStatus.failure,
        historyError: _describeError(error),
      ),
    );
  }

  // -----------------------------------------------------------------
  // JOIN QUEUE (one-shot action)
  // -----------------------------------------------------------------

  Future<void> _onJoinRequested(
    DigitalQueueJoinRequested event,
    Emitter<DigitalQueueState> emit,
  ) async {
    // Guard: don't let the student fire a second join while one is
    // already in flight (e.g. double-tap on a slow connection).
    if (state.actionStatus == QueueActionStatus.inProgress) return;

    emit(
      state.copyWith(
        actionStatus: QueueActionStatus.inProgress,
        actionError: null,
        clearLastJoinedToken: true,
      ),
    );

    try {
      final token = await _repository.joinQueue(
        JoinQueueRequest(
          studentId: event.studentId,
          studentName: event.studentName,
          studentEmail: event.studentEmail,
          rollNumber: event.rollNumber,
          department: event.department,
          semester: event.semester,
          serviceId: event.serviceId,
          priority: event.priority,
          deviceToken: event.deviceToken,
        ),
      );

      emit(
        state.copyWith(
          actionStatus: QueueActionStatus.success,
          lastJoinedToken: token,
          // The active-token stream (if subscribed) will also pick this up
          // automatically; we set it here too so the UI has it instantly
          // even before the stream's next snapshot arrives.
          activeToken: token,
          activeTokenStatus: ActiveTokenStatus.loaded,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: QueueActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  // -----------------------------------------------------------------
  // CANCEL TOKEN (one-shot action)
  // -----------------------------------------------------------------

  Future<void> _onCancelRequested(
    DigitalQueueCancelRequested event,
    Emitter<DigitalQueueState> emit,
  ) async {
    if (state.actionStatus == QueueActionStatus.inProgress) return;

    emit(
      state.copyWith(
        actionStatus: QueueActionStatus.inProgress,
        actionError: null,
      ),
    );

    try {
      await _repository.cancelToken(
        tokenId: event.tokenId,
        studentId: event.studentId,
      );

      emit(
        state.copyWith(
          actionStatus: QueueActionStatus.success,
          // Clear immediately for responsive UI; the active-token stream
          // will confirm this with its own null emission shortly after.
          clearActiveToken: true,
          activeTokenStatus: ActiveTokenStatus.loaded,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: QueueActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  // -----------------------------------------------------------------
  // CLEAR ACTION RESULT
  // -----------------------------------------------------------------

  void _onActionResultCleared(
    DigitalQueueActionResultCleared event,
    Emitter<DigitalQueueState> emit,
  ) {
    emit(
      state.copyWith(
        actionStatus: QueueActionStatus.none,
        actionError: null,
        clearLastJoinedToken: true,
      ),
    );
  }

  // -----------------------------------------------------------------
  // ERROR FORMATTING
  // -----------------------------------------------------------------

  /// Prefers the repository's own human-readable message when the error
  /// originated from a known `QueueException` (surfaced as
  /// `QueueRepositoryException` with `code == 'queue-error'`), otherwise
  /// falls back to a generic message so raw Firestore internals never
  /// leak into the UI.
  // String _describeError(Object error) {
  //   if (error is QueueRepositoryException) {
  //     if (error.code == 'queue-error') {
  //       return error.message;
  //     }
  //     if (error.code == 'invalid-argument') {
  //       return error.message;
  //     }
  //     return 'Something went wrong. Please try again.';
  //   }
  //   return 'Something went wrong. Please try again.';
  // }
  String _describeError(Object error) {
    return error.toString();
  }
}
