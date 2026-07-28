import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _service;
  StreamSubscription<List<NotificationModel>>? _subscription;

  NotificationBloc({NotificationService? service})
    : _service = service ?? NotificationService(),
      super(const NotificationState()) {
    on<NotificationSubscribeRequested>(_onSubscribeRequested);
    on<NotificationListUpdated>(_onListUpdated);
    on<NotificationMarkAsReadRequested>(_onMarkAsReadRequested);
    on<NotificationMarkAllAsReadRequested>(_onMarkAllAsReadRequested);
  }

  Future<void> _onSubscribeRequested(
    NotificationSubscribeRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: NotificationStatus.loading,
        studentId: event.studentId,
      ),
    );

    await _subscription?.cancel();

    try {
      final enrolledCourseIds = await _service.getEnrolledCourseIds(
        event.studentId,
      );

      // Sets up FCM token + foreground local-notification listener.
      unawaited(_service.initialize(studentId: event.studentId));

      _subscription = _service
          .watchNotifications(
            studentId: event.studentId,
            enrolledCourseIds: enrolledCourseIds,
          )
          .listen(
            (notifications) => add(NotificationListUpdated(notifications)),
            onError: (_) => add(const NotificationListUpdated([])),
          );
    } catch (_) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: 'Could not load notifications.',
        ),
      );
    }
  }

  void _onListUpdated(
    NotificationListUpdated event,
    Emitter<NotificationState> emit,
  ) {
    emit(
      state.copyWith(
        status: NotificationStatus.loaded,
        notifications: event.notifications,
      ),
    );
  }

  Future<void> _onMarkAsReadRequested(
    NotificationMarkAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _service.markAsRead(event.notificationId, state.studentId);
  }

  Future<void> _onMarkAllAsReadRequested(
    NotificationMarkAllAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _service.markAllAsRead(state.notifications, state.studentId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
