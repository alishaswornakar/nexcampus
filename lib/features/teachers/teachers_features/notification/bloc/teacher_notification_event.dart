import 'package:equatable/equatable.dart';

import '../../../../student/blocs/notification/models/notification_model.dart';

abstract class TeacherNotificationEvent extends Equatable {
  const TeacherNotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening for this teacher's notifications (submissions targeted
/// at them + every notice published by any teacher). Fire once, right
/// after the bloc is created on the dashboard.
class TeacherNotificationSubscribeRequested extends TeacherNotificationEvent {
  final String teacherId;

  const TeacherNotificationSubscribeRequested(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

/// Internal: pushed whenever the Firestore stream emits a new list.
class TeacherNotificationListUpdated extends TeacherNotificationEvent {
  final List<NotificationModel> notifications;

  const TeacherNotificationListUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class TeacherNotificationMarkAsReadRequested extends TeacherNotificationEvent {
  final String notificationId;

  const TeacherNotificationMarkAsReadRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class TeacherNotificationMarkAllAsReadRequested
    extends TeacherNotificationEvent {
  const TeacherNotificationMarkAllAsReadRequested();
}

/// Teacher composing and publishing a notice (goes out to all students,
/// and shows up for every teacher too, since notices are broadcast).
class TeacherNotificationNoticeSendRequested extends TeacherNotificationEvent {
  final String title;
  final String body;

  const TeacherNotificationNoticeSendRequested({
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [title, body];
}
