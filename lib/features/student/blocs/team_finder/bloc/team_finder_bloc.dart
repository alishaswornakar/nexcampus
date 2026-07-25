// lib/features/student/blocs/team_finder/bloc/team_finder_bloc.dart
import 'package:bloc/bloc.dart';

import '../repository/team_finder_repository.dart';
import 'team_finder_event.dart';
import 'team_finder_state.dart';

class TeamFinderBloc extends Bloc<TeamFinderEvent, TeamFinderState> {
  TeamFinderBloc({required TeamFinderRepository repository})
    : _repository = repository,
      super(const TeamFinderState()) {
    on<TeamFinderOpenPostsSubscriptionRequested>(
      _onOpenPostsSubscriptionRequested,
    );
    on<TeamFinderMyPostsSubscriptionRequested>(_onMyPostsSubscriptionRequested);
    on<TeamFinderMyApplicationsSubscriptionRequested>(
      _onMyApplicationsSubscriptionRequested,
    );
    on<TeamFinderPostApplicationsSubscriptionRequested>(
      _onPostApplicationsSubscriptionRequested,
    );
    on<TeamFinderCreatePostRequested>(_onCreatePostRequested);
    on<TeamFinderApplyRequested>(_onApplyRequested);
    on<TeamFinderWithdrawApplicationRequested>(_onWithdrawApplicationRequested);
    on<TeamFinderRespondToApplicationRequested>(
      _onRespondToApplicationRequested,
    );
    on<TeamFinderClosePostRequested>(_onClosePostRequested);
    on<TeamFinderDeletePostRequested>(_onDeletePostRequested);
    on<TeamFinderActionResultCleared>(_onActionResultCleared);
  }

  final TeamFinderRepository _repository;

  Future<void> _onOpenPostsSubscriptionRequested(
    TeamFinderOpenPostsSubscriptionRequested event,
    Emitter<TeamFinderState> emit,
  ) async {
    emit(state.copyWith(openPostsStatus: OpenPostsStatus.loading));
    await emit.forEach(
      _repository.watchOpenPosts(
        department: event.department,
        semester: event.semester,
      ),
      onData: (posts) => state.copyWith(
        openPostsStatus: OpenPostsStatus.loaded,
        openPosts: posts,
        openPostsError: null,
      ),
      onError: (error, stackTrace) => state.copyWith(
        openPostsStatus: OpenPostsStatus.failure,
        openPostsError: _describeError(error),
      ),
    );
  }

  Future<void> _onMyPostsSubscriptionRequested(
    TeamFinderMyPostsSubscriptionRequested event,
    Emitter<TeamFinderState> emit,
  ) async {
    emit(state.copyWith(myPostsStatus: MyPostsStatus.loading));
    await emit.forEach(
      _repository.watchMyPosts(event.ownerId),
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

  Future<void> _onMyApplicationsSubscriptionRequested(
    TeamFinderMyApplicationsSubscriptionRequested event,
    Emitter<TeamFinderState> emit,
  ) async {
    emit(state.copyWith(myApplicationsStatus: MyApplicationsStatus.loading));
    await emit.forEach(
      _repository.watchMyApplications(event.applicantId),
      onData: (apps) => state.copyWith(
        myApplicationsStatus: MyApplicationsStatus.loaded,
        myApplications: apps,
        myApplicationsError: null,
      ),
      onError: (error, stackTrace) => state.copyWith(
        myApplicationsStatus: MyApplicationsStatus.failure,
        myApplicationsError: _describeError(error),
      ),
    );
  }

  Future<void> _onPostApplicationsSubscriptionRequested(
    TeamFinderPostApplicationsSubscriptionRequested event,
    Emitter<TeamFinderState> emit,
  ) async {
    emit(
      state.copyWith(postApplicationsStatus: PostApplicationsStatus.loading),
    );
    await emit.forEach(
      _repository.watchPostApplications(event.postId),
      onData: (apps) => state.copyWith(
        postApplicationsStatus: PostApplicationsStatus.loaded,
        postApplications: apps,
        postApplicationsError: null,
      ),
      onError: (error, stackTrace) => state.copyWith(
        postApplicationsStatus: PostApplicationsStatus.failure,
        postApplicationsError: _describeError(error),
      ),
    );
  }

  Future<void> _onCreatePostRequested(
    TeamFinderCreatePostRequested event,
    Emitter<TeamFinderState> emit,
  ) async {
    if (state.actionStatus == TeamFinderActionStatus.inProgress) return;
    emit(
      state.copyWith(
        actionStatus: TeamFinderActionStatus.inProgress,
        actionError: null,
        clearLastCreatedPost: true,
      ),
    );
    try {
      final post = await _repository.createPost(
        CreatePostRequest(
          ownerId: event.ownerId,
          ownerName: event.ownerName,
          ownerEmail: event.ownerEmail,
          rollNumber: event.rollNumber,
          department: event.department,
          semester: event.semester,
          title: event.title,
          description: event.description,
          projectType: event.projectType,
          skillsNeeded: event.skillsNeeded,
          slotsTotal: event.slotsTotal,
        ),
      );
      emit(
        state.copyWith(
          actionStatus: TeamFinderActionStatus.success,
          lastCreatedPost: post,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: TeamFinderActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  Future<void> _onApplyRequested(
    TeamFinderApplyRequested event,
    Emitter<TeamFinderState> emit,
  ) async {
    if (state.actionStatus == TeamFinderActionStatus.inProgress) return;
    emit(
      state.copyWith(
        actionStatus: TeamFinderActionStatus.inProgress,
        actionError: null,
      ),
    );
    try {
      await _repository.applyToPost(
        ApplyToPostRequest(
          postId: event.postId,
          applicantId: event.applicantId,
          applicantName: event.applicantName,
          applicantEmail: event.applicantEmail,
          rollNumber: event.rollNumber,
          department: event.department,
          semester: event.semester,
          message: event.message,
        ),
      );
      emit(state.copyWith(actionStatus: TeamFinderActionStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: TeamFinderActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  Future<void> _onWithdrawApplicationRequested(
    TeamFinderWithdrawApplicationRequested event,
    Emitter<TeamFinderState> emit,
  ) async {
    if (state.actionStatus == TeamFinderActionStatus.inProgress) return;
    emit(
      state.copyWith(
        actionStatus: TeamFinderActionStatus.inProgress,
        actionError: null,
      ),
    );
    try {
      await _repository.withdrawApplication(
        applicationId: event.applicationId,
        applicantId: event.applicantId,
      );
      emit(state.copyWith(actionStatus: TeamFinderActionStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: TeamFinderActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  Future<void> _onRespondToApplicationRequested(
    TeamFinderRespondToApplicationRequested event,
    Emitter<TeamFinderState> emit,
  ) async {
    if (state.actionStatus == TeamFinderActionStatus.inProgress) return;
    emit(
      state.copyWith(
        actionStatus: TeamFinderActionStatus.inProgress,
        actionError: null,
      ),
    );
    try {
      await _repository.respondToApplication(
        applicationId: event.applicationId,
        ownerId: event.ownerId,
        accept: event.accept,
      );
      emit(state.copyWith(actionStatus: TeamFinderActionStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: TeamFinderActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  Future<void> _onClosePostRequested(
    TeamFinderClosePostRequested event,
    Emitter<TeamFinderState> emit,
  ) async {
    if (state.actionStatus == TeamFinderActionStatus.inProgress) return;
    emit(
      state.copyWith(
        actionStatus: TeamFinderActionStatus.inProgress,
        actionError: null,
      ),
    );
    try {
      await _repository.closePost(postId: event.postId, ownerId: event.ownerId);
      emit(state.copyWith(actionStatus: TeamFinderActionStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: TeamFinderActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  Future<void> _onDeletePostRequested(
    TeamFinderDeletePostRequested event,
    Emitter<TeamFinderState> emit,
  ) async {
    if (state.actionStatus == TeamFinderActionStatus.inProgress) return;
    emit(
      state.copyWith(
        actionStatus: TeamFinderActionStatus.inProgress,
        actionError: null,
      ),
    );
    try {
      await _repository.deletePost(
        postId: event.postId,
        ownerId: event.ownerId,
      );
      emit(state.copyWith(actionStatus: TeamFinderActionStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: TeamFinderActionStatus.failure,
          actionError: _describeError(error),
        ),
      );
    }
  }

  void _onActionResultCleared(
    TeamFinderActionResultCleared event,
    Emitter<TeamFinderState> emit,
  ) {
    emit(
      state.copyWith(
        actionStatus: TeamFinderActionStatus.none,
        actionError: null,
      ),
    );
  }

  String _describeError(Object error) => error.toString();
}
