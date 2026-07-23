import 'dart:io';

import '../model/user_profile_model.dart';
import '../services/user_profile_firestore_service.dart';
import '../services/user_profile_storage_service.dart';

class UserProfileRepository {
  final UserProfileFirestoreService _firestoreService;
  final UserProfileStorageService _storageService;

  UserProfileRepository({
    UserProfileFirestoreService? firestoreService,
    UserProfileStorageService? storageService,
  }) : _firestoreService = firestoreService ?? UserProfileFirestoreService(),
       _storageService = storageService ?? UserProfileStorageService();

  Future<UserProfileModel?> fetchProfile(String uid) {
    return _firestoreService.getUserProfile(uid);
  }

  Stream<UserProfileModel?> watchProfile(String uid) {
    return _firestoreService.watchUserProfile(uid);
  }

  Future<void> saveProfile(UserProfileModel profile) {
    return _firestoreService.updateUserProfile(profile);
  }

  Future<void> updateProfileFields(String uid, Map<String, dynamic> fields) {
    return _firestoreService.updateFields(uid, fields);
  }

  Future<void> deleteProfile(String uid) {
    return _firestoreService.deleteUserProfile(uid);
  }

  /// Uploads a new profile image, updates Firestore's `photoUrl` field,
  /// and returns the new URL so the Bloc can update its state.
  ///
  /// A cache-busting version query param is appended before saving,
  /// because Cloudinary returns the SAME url each time (overwrite mode)
  /// — without this, CachedNetworkImage would keep showing the old
  /// cached photo since the URL string wouldn't change.
  Future<String> uploadImage({
    required String uid,
    required File imageFile,
    String? oldImageUrl,
  }) async {
    final String rawUrl = await _storageService.uploadProfileImage(
      uid: uid,
      imageFile: imageFile,
    );

    final String versionedUrl =
        '$rawUrl?v=${DateTime.now().millisecondsSinceEpoch}';

    await _firestoreService.updateFields(uid, <String, dynamic>{
      'photoUrl': versionedUrl,
    });

    // No-op currently — Cloudinary overwrite handles cleanup implicitly.
    await _storageService.deleteOldImage(oldImageUrl);

    return versionedUrl;
  }
}
