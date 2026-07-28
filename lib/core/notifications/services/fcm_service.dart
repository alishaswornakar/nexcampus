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
}
