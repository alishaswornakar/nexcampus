// lib/features/student/blocs/anonymous_issue_reporting/bloc/anonymous_issue_bloc.dart
import 'package:bloc/bloc.dart';

import '../repository/anonymous_issue_repository.dart';
import 'anonymous_issue_event.dart';
import 'anonymous_issue_state.dart';

class AnonymousIssueBloc
    extends Bloc<AnonymousIssueEvent, AnonymousIssueState> {
  AnonymousIssueBloc({required AnonymousIssueRepository repository})
    : _repository = repository,
      super(const AnonymousIssueState()) {
    on<AnonymousIssueFeedSubscriptionRequested>(_onFeedSubscriptionRequested);
    on<AnonymousIssueMyPostsSubscriptionRequested>(
      _onMyPostsSubscriptionRequested,
    );
    on<AnonymousIssuePostCommentsSubscriptionRequested>(
      _onPostCommentsSubscriptionRequested,
    );
    on<AnonymousIssueCreatePostRequested>(_onCreatePostRequested);
    on<AnonymousIssueDeletePostRequested>(_onDeletePostRequested);
    on<AnonymousIssueSetResolvedRequested>(_onSetResolvedRequested);
    on<AnonymousIssueToggleUpvotePostRequested>(
      _onToggleUpvotePostRequested,
    );
    on<AnonymousIssueCreateCommentRequested>(_onCreateCommentRequested);
    on<AnonymousIssueDeleteCommentRequested>(_onDeleteCommentRequested);
    on<AnonymousIssueToggleUpvoteCommentRequested>(
      _onToggleUpvoteCommentRequested,
    );
    on<AnonymousIssueActionResultCleared>(_onActionResultCleared);
  }

  final AnonymousIssueRepository _repository;

  Future<void> _onFeedSubscriptionRequested(
    AnonymousIssueFeedSubscriptionRequested event,
    Emitter<AnonymousIssueState> emit,
  ) async {
    emit(state.copyWith(feedStatus: FeedStatus.loading));
    await emit.forEach(
      _repository.watchFeed(category: event.category),
      onData: (posts) => state.copyWith(
        feedStatus: FeedStatus.loaded,
        feedPosts: posts,
        feedError: null,
      ),
      onError: (error, stackTrace) => state.copyWith(
        feedStatus: FeedStatus.failure,
        feedError: _describeError(error),
      ),
    );
  }

  Future<void> _onMyPostsSubscriptionRequested(
    AnonymousIssueMyPostsSubscriptionRequested event,
    Emitter<AnonymousIssueState> emit,
  ) async {
    emit(state.copyWith(myPostsStatus: MyPostsStatus.loading));
    await emit.forEach(
      _repository.watchMyPosts(event.authorId),
      onData: (posts) => state.copyWith(
        myPostsStatus: MyPostsStatus.loaded,
        myPosts: posts,
        myPostsError: null,
      ),
      onError: (error, stackTrace) => state.copyWith(
        myPostsStatus: MyPostsStatus.failure,
        myPostsError: _describeError(error),
      ),
    );
  }

  Future<void> _onPostCommentsSubscriptionRequested(
    AnonymousIssuePostCommentsSubscriptionRequested event,
    Emitter<AnonymousIssueState> emit,
  ) async {
    emit(state.copyWith(postCommentsStatus: PostCommentsStatus.loading));
    await emit.forEach(
      _repository.watchPostComments(event.postId),
      onData: (comments) => state.copyWith(
        postCommentsStatus: PostCommentsStatus.loaded,
        postComments: comments,
        postCommentsError: null,
      ),
      onError: (error, stackTrace) => state.copyWith(
        postCommentsStatus: PostCommentsStatus.failure,
        postCommentsError: _describeError(error),
      ),
    );
  }

  Future<void> _onCreatePostRequested(
    AnonymousIssueCreatePostRequested event,
    Emitter<AnonymousIssueState> emit,
  ) async {
    if (state.actionStatus == AnonymousIssueActionStatus.inProgress) return;
    emit(
      state.copyWith(
        actionStatus: AnonymousIssueActionStatus.inProgress,
        actionError: null,
        clearLastCreatedPost: true,
      ),
    );
    try {
      final post = await _repository.createPost(
        CreateIssuePostRequest(
          authorId: event.authorId,
          title: event.title,
          body: event.body,
          category: event.category,
          isAnswer: event.isAnswer,
        ),
      );
      emit(
        state.copyWith(
          actionStatus: AnonymousIssueActionStatus.success,
          lastCreatedPost: post,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: AnonymousIssueActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  Future<void> _onDeletePostRequested(
    AnonymousIssueDeletePostRequested event,
    Emitter<AnonymousIssueState> emit,
  ) async {
    if (state.actionStatus == AnonymousIssueActionStatus.inProgress) return;
    emit(
      state.copyWith(
        actionStatus: AnonymousIssueActionStatus.inProgress,
        actionError: null,
      ),
    );
    try {
      await _repository.deletePost(
        postId: event.postId,
        authorId: event.authorId,
      );
      emit(state.copyWith(actionStatus: AnonymousIssueActionStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: AnonymousIssueActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  Future<void> _onSetResolvedRequested(
    AnonymousIssueSetResolvedRequested event,
    Emitter<AnonymousIssueState> emit,
  ) async {
    if (state.actionStatus == AnonymousIssueActionStatus.inProgress) return;
    emit(
      state.copyWith(
        actionStatus: AnonymousIssueActionStatus.inProgress,
        actionError: null,
      ),
    );
    try {
      await _repository.setResolved(
        postId: event.postId,
        authorId: event.authorId,
        resolved: event.resolved,
      );
      emit(state.copyWith(actionStatus: AnonymousIssueActionStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: AnonymousIssueActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  Future<void> _onToggleUpvotePostRequested(
    AnonymousIssueToggleUpvotePostRequested event,
    Emitter<AnonymousIssueState> emit,
  ) async {
    try {
      await _repository.toggleUpvotePost(
        postId: event.postId,
        studentId: event.studentId,
      );
    } catch (_) {
      // Upvotes are optimistic/low-stakes; the live stream will re-sync the
      // real count, so we swallow errors here rather than blocking the UI.
    }
  }

  Future<void> _onCreateCommentRequested(
    AnonymousIssueCreateCommentRequested event,
    Emitter<AnonymousIssueState> emit,
  ) async {
    if (state.actionStatus == AnonymousIssueActionStatus.inProgress) return;
    emit(
      state.copyWith(
        actionStatus: AnonymousIssueActionStatus.inProgress,
        actionError: null,
      ),
    );
    try {
      await _repository.createComment(
        postId: event.postId,
        authorId: event.authorId,
        body: event.body,
      );
      emit(state.copyWith(actionStatus: AnonymousIssueActionStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: AnonymousIssueActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  Future<void> _onDeleteCommentRequested(
    AnonymousIssueDeleteCommentRequested event,
    Emitter<AnonymousIssueState> emit,
  ) async {
    if (state.actionStatus == AnonymousIssueActionStatus.inProgress) return;
    emit(
      state.copyWith(
        actionStatus: AnonymousIssueActionStatus.inProgress,
        actionError: null,
      ),
    );
    try {
      await _repository.deleteComment(
        commentId: event.commentId,
        authorId: event.authorId,
      );
      emit(state.copyWith(actionStatus: AnonymousIssueActionStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: AnonymousIssueActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  Future<void> _onToggleUpvoteCommentRequested(
    AnonymousIssueToggleUpvoteCommentRequested event,
    Emitter<AnonymousIssueState> emit,
  ) async {
    try {
      await _repository.toggleUpvoteComment(
        commentId: event.commentId,
        studentId: event.studentId,
      );
    } catch (_) {
      // Same reasoning as post upvotes above.
    }
  }

  void _onActionResultCleared(
    AnonymousIssueActionResultCleared event,
    Emitter<AnonymousIssueState> emit,
  ) {
    emit(
      state.copyWith(
        actionStatus: AnonymousIssueActionStatus.none,
        actionError: null,
      ),
    );
  }

  String _describeError(Object error) => error.toString();
}
