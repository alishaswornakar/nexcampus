import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../student/blocs/notification/models/notification_model.dart';
import '../services/teacher_notification_service.dart';
import 'teacher_notification_event.dart';
import 'teacher_notification_state.dart';

class TeacherNotificationBloc
    extends Bloc<TeacherNotificationEvent, TeacherNotificationState> {
  final TeacherNotificationService _service;
  StreamSubscription<List<NotificationModel>>? _subscription;
  String _teacherName = 'Teacher';

  TeacherNotificationBloc({TeacherNotificationService? service})
    : _service = service ?? TeacherNotificationService(),
      super(const TeacherNotificationState()) {
    on<TeacherNotificationSubscribeRequested>(_onSubscribeRequested);
    on<TeacherNotificationListUpdated>(_onListUpdated);
    on<TeacherNotificationMarkAsReadRequested>(_onMarkAsReadRequested);
    on<TeacherNotificationMarkAllAsReadRequested>(_onMarkAllAsReadRequested);
    on<TeacherNotificationNoticeSendRequested>(_onNoticeSendRequested);
  }

  /// Optional: set once the teacher's profile has loaded, so outgoing
  /// notices are stamped with a real name instead of "Teacher".
  void setTeacherName(String name) {
    if (name.trim().isNotEmpty) _teacherName = name;
  }

  Future<void> _onSubscribeRequested(
    TeacherNotificationSubscribeRequested event,
    Emitter<TeacherNotificationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TeacherNotificationStatus.loading,
        teacherId: event.teacherId,
      ),
    );

    await _subscription?.cancel();

    try {
      // Sets up FCM token + foreground local-notification listener.
      unawaited(_service.initialize(teacherId: event.teacherId));

      _subscription = _service
          .watchNotifications(teacherId: event.teacherId)
          .listen(
            (notifications) =>
                add(TeacherNotificationListUpdated(notifications)),
            onError: (_) => add(const TeacherNotificationListUpdated([])),
          );
    } catch (_) {
      emit(
        state.copyWith(
          status: TeacherNotificationStatus.error,
          errorMessage: 'Could not load notifications.',
        ),
      );
    }
  }

  void _onListUpdated(
    TeacherNotificationListUpdated event,
    Emitter<TeacherNotificationState> emit,
  ) {
    emit(
      state.copyWith(
        status: TeacherNotificationStatus.loaded,
        notifications: event.notifications,
      ),
    );
  }

  Future<void> _onMarkAsReadRequested(
    TeacherNotificationMarkAsReadRequested event,
    Emitter<TeacherNotificationState> emit,
  ) async {
    await _service.markAsRead(event.notificationId, state.teacherId);
  }

  Future<void> _onMarkAllAsReadRequested(
    TeacherNotificationMarkAllAsReadRequested event,
    Emitter<TeacherNotificationState> emit,
  ) async {
    await _service.markAllAsRead(state.notifications, state.teacherId);
  }

  Future<void> _onNoticeSendRequested(
    TeacherNotificationNoticeSendRequested event,
    Emitter<TeacherNotificationState> emit,
  ) async {
    await _service.sendNotice(
      teacherId: state.teacherId,
      teacherName: _teacherName,
      title: event.title,
      body: event.body,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
