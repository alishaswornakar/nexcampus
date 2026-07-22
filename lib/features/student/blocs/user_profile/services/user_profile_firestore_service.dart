import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_profile_model.dart';

class UserProfileFirestoreService {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'users';

  UserProfileFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionPath);

  Future<UserProfileModel?> getUserProfile(String uid) async {
    final doc = await _collection.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfileModel.fromMap(uid, doc.data()!);
  }

  Stream<UserProfileModel?> watchUserProfile(String uid) {
    return _collection.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserProfileModel.fromMap(uid, doc.data()!);
    });
  }

  Future<void> updateUserProfile(UserProfileModel profile) async {
    await _collection
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> updateFields(String uid, Map<String, dynamic> fields) async {
    await _collection.doc(uid).update(fields);
  }

  Future<void> deleteUserProfile(String uid) async {
    await _collection.doc(uid).delete();
  }
}
