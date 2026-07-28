import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../firebase_options.dart';
import '../notifications/services/notifications_services.dart';

Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    "Background Notification: ${message.notification?.title}",
  );
}

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    await NotificationService.initialize();

    final settings =
        await FirebaseMessaging.instance.requestPermission();

    debugPrint(
      "Notification Permission: ${settings.authorizationStatus}",
    );

    final token =
        await FirebaseMessaging.instance.getToken();

    debugPrint("FCM Token:");
    debugPrint(token);
  }
}