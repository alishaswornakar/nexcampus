import 'package:equatable/equatable.dart';

import '../../../../student/blocs/notification/models/notification_model.dart';

enum TeacherNotificationStatus { initial, loading, loaded, error, sending }

class TeacherNotificationState extends Equatable {
  final TeacherNotificationStatus status;
  final List<NotificationModel> notifications;
  final String teacherId;
  final String? errorMessage;

  const TeacherNotificationState({
    this.status = TeacherNotificationStatus.initial,
    this.notifications = const [],
    this.teacherId = '',
    this.errorMessage,
  });

  int get unreadCount =>
      notifications.where((n) => !n.isReadBy(teacherId)).length;

  TeacherNotificationState copyWith({
    TeacherNotificationStatus? status,
    List<NotificationModel>? notifications,
    String? teacherId,
    String? errorMessage,
  }) {
    return TeacherNotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      teacherId: teacherId ?? this.teacherId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, teacherId, errorMessage];
}
