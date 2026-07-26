import 'package:equatable/equatable.dart';

import '../models/notification_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening for this student's notifications. Fire this once,
/// e.g. from StudentAppBar/dashboard right after the bloc is created.
class NotificationSubscribeRequested extends NotificationEvent {
  final String studentId;

  const NotificationSubscribeRequested(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

/// Internal event: pushed by the bloc whenever the Firestore stream
/// emits a new list. Public (not underscore-prefixed) so it's usable
/// from notification_bloc.dart, but you shouldn't dispatch it yourself.
class NotificationListUpdated extends NotificationEvent {
  final List<NotificationModel> notifications;

  const NotificationListUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationMarkAsReadRequested extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsReadRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationMarkAllAsReadRequested extends NotificationEvent {
  const NotificationMarkAllAsReadRequested();
}
