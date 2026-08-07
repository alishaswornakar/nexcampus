import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> saveToken() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final token = await _messaging.getToken();

    if (token == null) return;

    await _firestore.collection("users").doc(user.uid).update({
      "fcmToken": token,
    });

    debugPrint("FCM Token Saved");
  }

  static void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      final user = _auth.currentUser;

      if (user == null) return;

      await _firestore.collection("users").doc(user.uid).update({
        "fcmToken": token,
      });

      debugPrint("FCM Token Updated");
    });
  }

  /// Removes the FCM token from this user's doc and drops the token
  /// from the local device cache, so it doesn't get reused for /
  /// associated with whichever account logs in next on this device.
  ///
  /// Pass [uid] explicitly (captured before signOut()) rather than
  /// relying on `_auth.currentUser`, since by the time this runs
  /// during logout the current user may already be null.
  static Future<void> clearToken(String uid) async {
    try {
      await _firestore.collection("users").doc(uid).update({
        "fcmToken": FieldValue.delete(),
      });
    } catch (e) {
      debugPrint("FCM Token clear (Firestore) failed: $e");
    }

    try {
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint("FCM Token clear (local) failed: $e");
    }

    debugPrint("FCM Token Cleared");
  }
}
