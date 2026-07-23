// lib/features/student/blocs/team_finder/bloc/team_finder_state.dart
import 'package:equatable/equatable.dart';

import '../models/team_application_model.dart';
import '../models/team_post_model.dart';

enum OpenPostsStatus { initial, loading, loaded, failure }

enum MyPostsStatus { initial, loading, loaded, failure }

enum MyApplicationsStatus { initial, loading, loaded, failure }

enum PostApplicationsStatus { initial, loading, loaded, failure }

enum TeamFinderActionStatus { none, inProgress, success, failure }

class TeamFinderState extends Equatable {
  const TeamFinderState({
    this.openPostsStatus = OpenPostsStatus.initial,
    this.openPosts = const [],
    this.openPostsError,
    this.myPostsStatus = MyPostsStatus.initial,
    this.myPosts = const [],
    this.myPostsError,
    this.myApplicationsStatus = MyApplicationsStatus.initial,
    this.myApplications = const [],
    this.myApplicationsError,
    this.postApplicationsStatus = PostApplicationsStatus.initial,
    this.postApplications = const [],
    this.postApplicationsError,
    this.actionStatus = TeamFinderActionStatus.none,
    this.actionError,
    this.lastCreatedPost,
  });

  final OpenPostsStatus openPostsStatus;
  final List<TeamPostModel> openPosts;
  final String? openPostsError;

  final MyPostsStatus myPostsStatus;
  final List<TeamPostModel> myPosts;
  final String? myPostsError;

  final MyApplicationsStatus myApplicationsStatus;
  final List<TeamApplicationModel> myApplications;
  final String? myApplicationsError;

  final PostApplicationsStatus postApplicationsStatus;
  final List<TeamApplicationModel> postApplications;
  final String? postApplicationsError;

  final TeamFinderActionStatus actionStatus;
  final String? actionError;
  final TeamPostModel? lastCreatedPost;

  TeamFinderState copyWith({
    OpenPostsStatus? openPostsStatus,
    List<TeamPostModel>? openPosts,
    String? openPostsError,
    MyPostsStatus? myPostsStatus,
    List<TeamPostModel>? myPosts,
    String? myPostsError,
    MyApplicationsStatus? myApplicationsStatus,
    List<TeamApplicationModel>? myApplications,
    String? myApplicationsError,
    PostApplicationsStatus? postApplicationsStatus,
    List<TeamApplicationModel>? postApplications,
    String? postApplicationsError,
    TeamFinderActionStatus? actionStatus,
    String? actionError,
    TeamPostModel? lastCreatedPost,
    bool clearLastCreatedPost = false,
  }) {
    return TeamFinderState(
      openPostsStatus: openPostsStatus ?? this.openPostsStatus,
      openPosts: openPosts ?? this.openPosts,
      openPostsError: openPostsError,
      myPostsStatus: myPostsStatus ?? this.myPostsStatus,
      myPosts: myPosts ?? this.myPosts,
      myPostsError: myPostsError,
      myApplicationsStatus: myApplicationsStatus ?? this.myApplicationsStatus,
      myApplications: myApplications ?? this.myApplications,
      myApplicationsError: myApplicationsError,
      postApplicationsStatus:
          postApplicationsStatus ?? this.postApplicationsStatus,
      postApplications: postApplications ?? this.postApplications,
      postApplicationsError: postApplicationsError,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError,
      lastCreatedPost: clearLastCreatedPost
          ? null
          : (lastCreatedPost ?? this.lastCreatedPost),
    );
  }

  @override
  List<Object?> get props => [
    openPostsStatus,
    openPosts,
    openPostsError,
    myPostsStatus,
    myPosts,
    myPostsError,
    myApplicationsStatus,
    myApplications,
    myApplicationsError,
    postApplicationsStatus,
    postApplications,
    postApplicationsError,
    actionStatus,
    actionError,
    lastCreatedPost,
  ];
}
