import '../model/user_profile_model.dart';
import '../services/user_profile_firestore_service.dart';

class UserProfileRepository {
  final UserProfileFirestoreService _firestoreService;

  UserProfileRepository({UserProfileFirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? UserProfileFirestoreService();

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
}
