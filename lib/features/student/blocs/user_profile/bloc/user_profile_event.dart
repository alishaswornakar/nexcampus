import 'dart:io';

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

/// Triggers a profile image upload. Carries the picked [imageFile],
/// the current user's [uid], and the existing [oldImageUrl] (if any)
/// so the repository can clean it up after a successful upload.
class UploadProfileImage extends UserProfileEvent {
  final String uid;
  final File imageFile;
  final String? oldImageUrl;

  const UploadProfileImage({
    required this.uid,
    required this.imageFile,
    this.oldImageUrl,
  });

  @override
  List<Object?> get props => [uid, imageFile.path, oldImageUrl];
}

/// Dispatched internally by the Bloc once the upload completes
/// successfully, carrying the new download URL.
class ProfileImageUploaded extends UserProfileEvent {
  final String imageUrl;

  const ProfileImageUploaded(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}
