// lib/features/student/blocs/digital_queue/bloc/digital_queue_state.dart

import 'package:equatable/equatable.dart';

import '../models/queue_history_model.dart';
import '../models/queue_service_model.dart';
import '../models/queue_token_model.dart';

/// -----------------------------------------------------------------------
/// STATUS ENUMS
/// -----------------------------------------------------------------------
/// Status of the `queue_services` list stream.
enum QueueServicesStatus { initial, loading, loaded, failure }

/// Status of the student's active-token stream.
enum ActiveTokenStatus { initial, loading, loaded, failure }

/// Status of the queue-history stream.
enum QueueHistoryStatus { initial, loading, loaded, failure }

/// Status of the last join/cancel action, surfaced once to the UI.
enum QueueActionStatus { none, inProgress, success, failure }

/// -----------------------------------------------------------------------
/// STATE
/// -----------------------------------------------------------------------
/// Single, flat state object holding all four independent slices
/// (services / active token / history / last action) so the BLoC can
/// run multiple live subscriptions concurrently — exactly like the
/// Attendance and Assignment BLoCs already do — without needing four
/// separate BLoCs.
class DigitalQueueState extends Equatable {
  const DigitalQueueState({
    this.servicesStatus = QueueServicesStatus.initial,
    this.services = const [],
    this.servicesError,
    this.activeTokenStatus = ActiveTokenStatus.initial,
    this.activeToken,
    this.activeTokenError,
    this.historyStatus = QueueHistoryStatus.initial,
    this.history = const [],
    this.historyError,
    this.actionStatus = QueueActionStatus.none,
    this.actionError,
    this.lastJoinedToken,
  });

  // --- Queue services list ---
  final QueueServicesStatus servicesStatus;
  final List<QueueServiceModel> services;
  final String? servicesError;

  // --- Student's active token ---
  final ActiveTokenStatus activeTokenStatus;
  final QueueTokenModel? activeToken;
  final String? activeTokenError;

  // --- Queue history ---
  final QueueHistoryStatus historyStatus;
  final List<QueueHistoryModel> history;
  final String? historyError;

  // --- Last join/cancel action (one-shot, cleared by the UI) ---
  final QueueActionStatus actionStatus;
  final String? actionError;

  /// Populated on a successful join, so the UI can navigate straight to
  /// a "your token" confirmation screen without waiting on the active
  /// token stream to catch up.
  final QueueTokenModel? lastJoinedToken;

  /// Convenience getter: true when the student currently holds a token
  /// (waiting or serving) for any service.
  bool get hasActiveToken => activeToken != null;

  DigitalQueueState copyWith({
    QueueServicesStatus? servicesStatus,
    List<QueueServiceModel>? services,
    String? servicesError,
    ActiveTokenStatus? activeTokenStatus,
    QueueTokenModel? activeToken,
    bool clearActiveToken = false,
    String? activeTokenError,
    QueueHistoryStatus? historyStatus,
    List<QueueHistoryModel>? history,
    String? historyError,
    QueueActionStatus? actionStatus,
    String? actionError,
    QueueTokenModel? lastJoinedToken,
    bool clearLastJoinedToken = false,
  }) {
    return DigitalQueueState(
      servicesStatus: servicesStatus ?? this.servicesStatus,
      services: services ?? this.services,
      servicesError: servicesError,
      activeTokenStatus: activeTokenStatus ?? this.activeTokenStatus,
      activeToken: clearActiveToken ? null : (activeToken ?? this.activeToken),
      activeTokenError: activeTokenError,
      historyStatus: historyStatus ?? this.historyStatus,
      history: history ?? this.history,
      historyError: historyError,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError,
      lastJoinedToken: clearLastJoinedToken
          ? null
          : (lastJoinedToken ?? this.lastJoinedToken),
    );
  }

  @override
  List<Object?> get props => [
    servicesStatus,
    services,
    servicesError,
    activeTokenStatus,
    activeToken,
    activeTokenError,
    historyStatus,
    history,
    historyError,
    actionStatus,
    actionError,
    lastJoinedToken,
  ];
}
