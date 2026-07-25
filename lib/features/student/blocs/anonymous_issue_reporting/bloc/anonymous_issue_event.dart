// lib/features/student/blocs/anonymous_issue_reporting/bloc/anonymous_issue_event.dart
import 'package:equatable/equatable.dart';

abstract class AnonymousIssueEvent extends Equatable {
  const AnonymousIssueEvent();
  @override
  List<Object?> get props => [];
}

class AnonymousIssueFeedSubscriptionRequested extends AnonymousIssueEvent {
  const AnonymousIssueFeedSubscriptionRequested({this.category});
  final String? category;
  @override
  List<Object?> get props => [category];
}

class AnonymousIssueMyPostsSubscriptionRequested extends AnonymousIssueEvent {
  const AnonymousIssueMyPostsSubscriptionRequested({required this.authorId});
  final String authorId;
  @override
  List<Object?> get props => [authorId];
}

class AnonymousIssuePostCommentsSubscriptionRequested
    extends AnonymousIssueEvent {
  const AnonymousIssuePostCommentsSubscriptionRequested({
    required this.postId,
  });
  final String postId;
  @override
  List<Object?> get props => [postId];
}

class AnonymousIssueCreatePostRequested extends AnonymousIssueEvent {
  const AnonymousIssueCreatePostRequested({
    required this.authorId,
    required this.title,
    required this.body,
    required this.category,
    this.isAnswer = false,
  });

  final String authorId;
  final String title;
  final String body;
  final String category;
  final bool isAnswer;

  @override
  List<Object?> get props => [authorId, title, body, category, isAnswer];
}

class AnonymousIssueDeletePostRequested extends AnonymousIssueEvent {
  const AnonymousIssueDeletePostRequested({
    required this.postId,
    required this.authorId,
  });
  final String postId;
  final String authorId;
  @override
  List<Object?> get props => [postId, authorId];
}

class AnonymousIssueSetResolvedRequested extends AnonymousIssueEvent {
  const AnonymousIssueSetResolvedRequested({
    required this.postId,
    required this.authorId,
    required this.resolved,
  });
  final String postId;
  final String authorId;
  final bool resolved;
  @override
  List<Object?> get props => [postId, authorId, resolved];
}

class AnonymousIssueToggleUpvotePostRequested extends AnonymousIssueEvent {
  const AnonymousIssueToggleUpvotePostRequested({
    required this.postId,
    required this.studentId,
  });
  final String postId;
  final String studentId;
  @override
  List<Object?> get props => [postId, studentId];
}

class AnonymousIssueCreateCommentRequested extends AnonymousIssueEvent {
  const AnonymousIssueCreateCommentRequested({
    required this.postId,
    required this.authorId,
    required this.body,
  });
  final String postId;
  final String authorId;
  final String body;
  @override
  List<Object?> get props => [postId, authorId, body];
}

class AnonymousIssueDeleteCommentRequested extends AnonymousIssueEvent {
  const AnonymousIssueDeleteCommentRequested({
    required this.commentId,
    required this.authorId,
  });
  final String commentId;
  final String authorId;
  @override
  List<Object?> get props => [commentId, authorId];
}

class AnonymousIssueToggleUpvoteCommentRequested extends AnonymousIssueEvent {
  const AnonymousIssueToggleUpvoteCommentRequested({
    required this.commentId,
    required this.studentId,
  });
  final String commentId;
  final String studentId;
  @override
  List<Object?> get props => [commentId, studentId];
}

class AnonymousIssueActionResultCleared extends AnonymousIssueEvent {
  const AnonymousIssueActionResultCleared();
}
