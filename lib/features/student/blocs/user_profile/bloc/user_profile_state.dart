import 'package:equatable/equatable.dart';
import '../model/user_profile_model.dart';

enum UserProfileStatus { initial, loading, success, failure }

class UserProfileState extends Equatable {
  final UserProfileStatus status;
  final UserProfileModel? profile;
  final String? errorMessage;

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserProfileModel? profile,
    String? errorMessage,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
