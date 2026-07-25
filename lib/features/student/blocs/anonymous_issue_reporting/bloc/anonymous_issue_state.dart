// lib/features/student/blocs/anonymous_issue_reporting/bloc/anonymous_issue_state.dart
import 'package:equatable/equatable.dart';

import '../models/issue_comment_model.dart';
import '../models/issue_post_model.dart';

enum FeedStatus { initial, loading, loaded, failure }

enum MyPostsStatus { initial, loading, loaded, failure }

enum PostCommentsStatus { initial, loading, loaded, failure }

enum AnonymousIssueActionStatus { none, inProgress, success, failure }

class AnonymousIssueState extends Equatable {
  const AnonymousIssueState({
    this.feedStatus = FeedStatus.initial,
    this.feedPosts = const [],
    this.feedError,
    this.myPostsStatus = MyPostsStatus.initial,
    this.myPosts = const [],
    this.myPostsError,
    this.postCommentsStatus = PostCommentsStatus.initial,
    this.postComments = const [],
    this.postCommentsError,
    this.actionStatus = AnonymousIssueActionStatus.none,
    this.actionError,
    this.lastCreatedPost,
  });

  final FeedStatus feedStatus;
  final List<IssuePostModel> feedPosts;
  final String? feedError;

  final MyPostsStatus myPostsStatus;
  final List<IssuePostModel> myPosts;
  final String? myPostsError;

  final PostCommentsStatus postCommentsStatus;
  final List<IssueCommentModel> postComments;
  final String? postCommentsError;

  final AnonymousIssueActionStatus actionStatus;
  final String? actionError;
  final IssuePostModel? lastCreatedPost;

  AnonymousIssueState copyWith({
    FeedStatus? feedStatus,
    List<IssuePostModel>? feedPosts,
    String? feedError,
    MyPostsStatus? myPostsStatus,
    List<IssuePostModel>? myPosts,
    String? myPostsError,
    PostCommentsStatus? postCommentsStatus,
    List<IssueCommentModel>? postComments,
    String? postCommentsError,
    AnonymousIssueActionStatus? actionStatus,
    String? actionError,
    IssuePostModel? lastCreatedPost,
    bool clearLastCreatedPost = false,
  }) {
    return AnonymousIssueState(
      feedStatus: feedStatus ?? this.feedStatus,
      feedPosts: feedPosts ?? this.feedPosts,
      feedError: feedError,
      myPostsStatus: myPostsStatus ?? this.myPostsStatus,
      myPosts: myPosts ?? this.myPosts,
      myPostsError: myPostsError,
      postCommentsStatus: postCommentsStatus ?? this.postCommentsStatus,
      postComments: postComments ?? this.postComments,
      postCommentsError: postCommentsError,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError,
      lastCreatedPost: clearLastCreatedPost
          ? null
          : (lastCreatedPost ?? this.lastCreatedPost),
    );
  }

  @override
  List<Object?> get props => [
    feedStatus,
    feedPosts,
    feedError,
    myPostsStatus,
    myPosts,
    myPostsError,
    postCommentsStatus,
    postComments,
    postCommentsError,
    actionStatus,
    actionError,
    lastCreatedPost,
  ];
}
