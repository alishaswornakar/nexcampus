import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
      _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request notification permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(settings);

    // Save FCM token
    await saveToken();

    // Update token automatically
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) async {
        await saveToken(token: token);
      },
    );

    // Foreground notification
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint(
          "Foreground Notification: ${message.notification?.title}");

      debugPrint(
          "Body: ${message.notification?.body}");

      await _showNotification(message);
    });

    // Notification clicked
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("Notification Clicked");
    });
  }

  static Future<void> _showNotification(
      RemoteMessage message) async {
    const android = AndroidNotificationDetails(
      'nexcampus_channel',
      'NexCampus Notifications',
      channelDescription: 'General notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: android,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      details,
    );
  }

  static Future<void> saveToken({
    String? token,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    token ??= await _messaging.getToken();

    if (token == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({
      "fcmToken": token,
    });

    debugPrint("FCM Token Saved");
    debugPrint(token);
  }
}