// lib/features/student/blocs/team_finder/bloc/team_finder_event.dart
import 'package:equatable/equatable.dart';

abstract class TeamFinderEvent extends Equatable {
  const TeamFinderEvent();
  @override
  List<Object?> get props => [];
}

class TeamFinderOpenPostsSubscriptionRequested extends TeamFinderEvent {
  const TeamFinderOpenPostsSubscriptionRequested({
    this.department,
    this.semester,
  });
  final String? department;
  final String? semester;
  @override
  List<Object?> get props => [department, semester];
}

class TeamFinderMyPostsSubscriptionRequested extends TeamFinderEvent {
  const TeamFinderMyPostsSubscriptionRequested({required this.ownerId});
  final String ownerId;
  @override
  List<Object?> get props => [ownerId];
}

class TeamFinderMyApplicationsSubscriptionRequested extends TeamFinderEvent {
  const TeamFinderMyApplicationsSubscriptionRequested({
    required this.applicantId,
  });
  final String applicantId;
  @override
  List<Object?> get props => [applicantId];
}

class TeamFinderPostApplicationsSubscriptionRequested extends TeamFinderEvent {
  const TeamFinderPostApplicationsSubscriptionRequested({required this.postId});
  final String postId;
  @override
  List<Object?> get props => [postId];
}

class TeamFinderCreatePostRequested extends TeamFinderEvent {
  const TeamFinderCreatePostRequested({
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
    required this.title,
    required this.description,
    required this.projectType,
    required this.skillsNeeded,
    required this.slotsTotal,
  });

  final String ownerId, ownerName, ownerEmail, rollNumber, department, semester;
  final String title, description, projectType;
  final List<String> skillsNeeded;
  final int slotsTotal;

  @override
  List<Object?> get props => [
    ownerId,
    ownerName,
    ownerEmail,
    rollNumber,
    department,
    semester,
    title,
    description,
    projectType,
    skillsNeeded,
    slotsTotal,
  ];
}

class TeamFinderApplyRequested extends TeamFinderEvent {
  const TeamFinderApplyRequested({
    required this.postId,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
    this.message = '',
  });

  final String postId,
      applicantId,
      applicantName,
      applicantEmail,
      rollNumber,
      department,
      semester,
      message;

  @override
  List<Object?> get props => [
    postId,
    applicantId,
    applicantName,
    applicantEmail,
    rollNumber,
    department,
    semester,
    message,
  ];
}

class TeamFinderWithdrawApplicationRequested extends TeamFinderEvent {
  const TeamFinderWithdrawApplicationRequested({
    required this.applicationId,
    required this.applicantId,
  });
  final String applicationId;
  final String applicantId;
  @override
  List<Object?> get props => [applicationId, applicantId];
}

class TeamFinderRespondToApplicationRequested extends TeamFinderEvent {
  const TeamFinderRespondToApplicationRequested({
    required this.applicationId,
    required this.ownerId,
    required this.accept,
  });
  final String applicationId;
  final String ownerId;
  final bool accept;
  @override
  List<Object?> get props => [applicationId, ownerId, accept];
}

class TeamFinderClosePostRequested extends TeamFinderEvent {
  const TeamFinderClosePostRequested({
    required this.postId,
    required this.ownerId,
  });
  final String postId;
  final String ownerId;
  @override
  List<Object?> get props => [postId, ownerId];
}

class TeamFinderDeletePostRequested extends TeamFinderEvent {
  const TeamFinderDeletePostRequested({
    required this.postId,
    required this.ownerId,
  });
  final String postId;
  final String ownerId;
  @override
  List<Object?> get props => [postId, ownerId];
}

class TeamFinderActionResultCleared extends TeamFinderEvent {
  const TeamFinderActionResultCleared();
}
