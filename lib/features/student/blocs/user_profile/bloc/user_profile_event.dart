import 'package:equatable/equatable.dart';
import '../model/user_profile_model.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class UserProfileRequested extends UserProfileEvent {
  final String uid;

  const UserProfileRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

class UserProfileSubscriptionRequested extends UserProfileEvent {
  final String uid;

  const UserProfileSubscriptionRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

class UserProfileUpdated extends UserProfileEvent {
  final UserProfileModel profile;

  const UserProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class UserProfileFieldsUpdated extends UserProfileEvent {
  final String uid;
  final Map<String, dynamic> fields;

  const UserProfileFieldsUpdated(this.uid, this.fields);

  @override
  List<Object?> get props => [uid, fields];
}

class UserProfileCleared extends UserProfileEvent {
  const UserProfileCleared();
}
