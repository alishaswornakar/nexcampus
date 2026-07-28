import 'package:equatable/equatable.dart';

import '../models/notification_model.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationModel> notifications;
  final String studentId;
  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.studentId = '',
    this.errorMessage,
  });

  int get unreadCount =>
      notifications.where((n) => !n.isReadBy(studentId)).length;

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    String? studentId,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      studentId: studentId ?? this.studentId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, studentId, errorMessage];
}
