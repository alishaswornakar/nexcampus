import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/user_profile_repository.dart';
import 'user_profile_event.dart';
import 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileRepository _repository;
  StreamSubscription? _profileSubscription;

  UserProfileBloc({UserProfileRepository? repository})
    : _repository = repository ?? UserProfileRepository(),
      super(const UserProfileState()) {
    on<UserProfileRequested>(_onProfileRequested);
    on<UserProfileSubscriptionRequested>(_onProfileSubscriptionRequested);
    on<UserProfileUpdated>(_onProfileUpdated);
    on<UserProfileFieldsUpdated>(_onProfileFieldsUpdated);
    on<UserProfileCleared>(_onProfileCleared);
    on<UploadProfileImage>(_onUploadProfileImage);
    on<ProfileImageUploaded>(_onProfileImageUploaded);
  }

  Future<void> _onProfileRequested(
    UserProfileRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(status: UserProfileStatus.loading));
    try {
      final profile = await _repository.fetchProfile(event.uid);
      emit(state.copyWith(status: UserProfileStatus.success, profile: profile));
    } catch (e) {
      emit(
        state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onProfileSubscriptionRequested(
    UserProfileSubscriptionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(status: UserProfileStatus.loading));
    await _profileSubscription?.cancel();
    await emit.forEach<dynamic>(
      _repository.watchProfile(event.uid),
      onData: (profile) =>
          state.copyWith(status: UserProfileStatus.success, profile: profile),
      onError: (error, stackTrace) => state.copyWith(
        status: UserProfileStatus.failure,
        errorMessage: error.toString(),
      ),
    );
  }

  Future<void> _onProfileUpdated(
    UserProfileUpdated event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(status: UserProfileStatus.loading));
    try {
      await _repository.saveProfile(event.profile);
      emit(
        state.copyWith(
          status: UserProfileStatus.success,
          profile: event.profile,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onProfileFieldsUpdated(
    UserProfileFieldsUpdated event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      await _repository.updateProfileFields(event.uid, event.fields);
      final refreshed = await _repository.fetchProfile(event.uid);
      emit(
        state.copyWith(status: UserProfileStatus.success, profile: refreshed),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onProfileCleared(
    UserProfileCleared event,
    Emitter<UserProfileState> emit,
  ) {
    emit(const UserProfileState());
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImage event,
    Emitter<UserProfileState> emit,
  ) async {
    // Preserve existing profile-load state/error while the image
    // upload runs — this is a separate concern from profile status.
    emit(
      state.copyWith(
        imageUploadStatus: ProfileImageUploadStatus.uploading,
        errorMessage: state.errorMessage,
        imageUploadError: null,
      ),
    );
    try {
      final newImageUrl = await _repository.uploadImage(
        uid: event.uid,
        imageFile: event.imageFile,
        oldImageUrl: event.oldImageUrl,
      );
      // Dispatch the follow-up event rather than emitting profile
      // changes directly here, so the "upload succeeded" transition
      // and the "profile.imageUrl updated" transition are handled by
      // a single, testable event handler (_onProfileImageUploaded).
      add(ProfileImageUploaded(newImageUrl));
    } catch (e) {
      emit(
        state.copyWith(
          imageUploadStatus: ProfileImageUploadStatus.failure,
          errorMessage: state.errorMessage,
          imageUploadError: e.toString(),
        ),
      );
    }
  }

  void _onProfileImageUploaded(
    ProfileImageUploaded event,
    Emitter<UserProfileState> emit,
  ) {
    final currentProfile = state.profile;
    final updatedProfile = currentProfile?.copyWith(photoUrl: event.imageUrl);

    emit(
      state.copyWith(
        imageUploadStatus: ProfileImageUploadStatus.success,
        errorMessage: state.errorMessage,
        imageUploadError: null,
        profile: updatedProfile ?? currentProfile,
      ),
    );
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
