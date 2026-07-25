import 'package:equatable/equatable.dart';
import '../model/user_profile_model.dart';

enum UserProfileStatus { initial, loading, success, failure }

enum ProfileImageUploadStatus { initial, uploading, success, failure }

class UserProfileState extends Equatable {
  final UserProfileStatus status;
  final UserProfileModel? profile;
  final String? errorMessage;

  final ProfileImageUploadStatus imageUploadStatus;
  final String? imageUploadError;

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.imageUploadStatus = ProfileImageUploadStatus.initial,
    this.imageUploadError,
  });

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserProfileModel? profile,
    String? errorMessage,
    ProfileImageUploadStatus? imageUploadStatus,
    String? imageUploadError,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      imageUploadStatus: imageUploadStatus ?? this.imageUploadStatus,
      imageUploadError: imageUploadError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    errorMessage,
    imageUploadStatus,
    imageUploadError,
  ];
}
