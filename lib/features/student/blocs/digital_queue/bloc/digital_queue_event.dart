// lib/features/student/blocs/digital_queue/bloc/digital_queue_event.dart

import 'package:equatable/equatable.dart';

import '../repository/digital_queue_repository.dart';

/// -----------------------------------------------------------------------
/// EVENTS
/// -----------------------------------------------------------------------
abstract class DigitalQueueEvent extends Equatable {
  const DigitalQueueEvent();

  @override
  List<Object?> get props => [];
}

/// Starts watching the list of queue services (e.g. on screen init).
/// Subscribes to [DigitalQueueRepository.watchQueueServices] internally.
class DigitalQueueServicesSubscriptionRequested extends DigitalQueueEvent {
  const DigitalQueueServicesSubscriptionRequested();
}

/// Starts watching the current student's active token (waiting/serving),
/// across all services. Should be dispatched once, e.g. right after
/// login or when the queue screen first mounts.
class DigitalQueueActiveTokenSubscriptionRequested extends DigitalQueueEvent {
  const DigitalQueueActiveTokenSubscriptionRequested({required this.studentId});

  final String studentId;

  @override
  List<Object?> get props => [studentId];
}

/// Starts watching the current student's queue history.
class DigitalQueueHistorySubscriptionRequested extends DigitalQueueEvent {
  const DigitalQueueHistorySubscriptionRequested({
    required this.studentId,
    this.limit = 50,
  });

  final String studentId;
  final int limit;

  @override
  List<Object?> get props => [studentId, limit];
}

/// Requests joining a queue for a given service. Carries every field the
/// repository's [JoinQueueRequest] needs.
class DigitalQueueJoinRequested extends DigitalQueueEvent {
  const DigitalQueueJoinRequested({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
    required this.serviceId,
    this.priority = 0,
    this.deviceToken = '',
  });

  final String studentId;
  final String studentName;
  final String studentEmail;
  final String rollNumber;
  final String department;
  final String semester;
  final String serviceId;
  final int priority;
  final String deviceToken;

  @override
  List<Object?> get props => [
    studentId,
    studentName,
    studentEmail,
    rollNumber,
    department,
    semester,
    serviceId,
    priority,
    deviceToken,
  ];
}

/// Requests cancelling the student's own token.
class DigitalQueueCancelRequested extends DigitalQueueEvent {
  const DigitalQueueCancelRequested({
    required this.tokenId,
    required this.studentId,
  });

  final String tokenId;
  final String studentId;

  @override
  List<Object?> get props => [tokenId, studentId];
}

/// Clears a one-shot join/cancel result (success or failure) after the
/// UI has consumed it (e.g. shown a SnackBar), so it doesn't re-trigger
/// on rebuild.
class DigitalQueueActionResultCleared extends DigitalQueueEvent {
  const DigitalQueueActionResultCleared();
}
