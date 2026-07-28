import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notification_model.dart';

/// Everything notification-related that touches Firebase:
/// - reading/writing the `notifications` collection in Firestore
/// - registering the device's FCM token against the student
/// - showing a local heads-up notification when a push arrives
///   while the app is in the foreground (FCM stays silent then).
///
/// Actually *sending* the push when a teacher adds a course/assignment/
/// notice is server-side work — see functions/index.js in this package.
/// This service only writes the Firestore doc; a Cloud Function watches
/// that collection and calls FCM.
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'nexcampus_notifications';
  static const String _channelName = 'NexCampus Notifications';

  bool _localNotifInitialized = false;

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection('notifications').withConverter<Map<String, dynamic>>(
            fromFirestore: (snap, _) => snap.data() ?? {},
            toFirestore: (data, _) => data,
          );

  /// Call once per session (e.g. right after login, or in
  /// StudentAppBar/dashboard init) to:
  /// - request notification permission
  /// - set up the local notification channel
  /// - save/refresh this device's FCM token on the student's user doc
  /// - start listening for foreground pushes
  Future<void> initialize({required String studentId}) async {
    await _initLocalNotifications();
    await _requestPermission();
    await _saveFcmToken(studentId);

    _messaging.onTokenRefresh.listen((token) {
      _firestore.collection('users').doc(studentId).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
    });

    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  Future<void> _initLocalNotifications() async {
    if (_localNotifInitialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(settings: initSettings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Course, assignment and notice alerts',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _localNotifInitialized = true;
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> _saveFcmToken(String studentId) async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await _firestore.collection('users').doc(studentId).set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Course, assignment and notice alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
    );
  }

  /// The courseIds this student is enrolled in, used to filter
  /// course-targeted notifications. Adjust the field name below to
  /// match wherever enrolment actually lives in your `users` schema.
  Future<List<String>> getEnrolledCourseIds(String studentId) async {
    final doc = await _firestore.collection('users').doc(studentId).get();
    final data = doc.data();
    if (data == null) return [];
    return List<String>.from(data['enrolledCourses'] ?? const []);
  }

  /// Live stream of notifications relevant to this student: broadcast to
  /// everyone, targeted at one of their enrolled courses, or targeted at
  /// them directly.
  Stream<List<NotificationModel>> watchNotifications({
    required String studentId,
    required List<String> enrolledCourseIds,
  }) {
    return _notificationsRef
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((d) => NotificationModel.fromMap(d.id, d.data()))
          .where((n) {
        switch (n.targetType) {
          case NotificationTargetType.all:
            return true;
          case NotificationTargetType.course:
            return n.targetId != null &&
                enrolledCourseIds.contains(n.targetId);
          case NotificationTargetType.student:
            return n.targetId == studentId;
        }
      }).toList();
    });
  }

  Future<void> markAsRead(String notificationId, String studentId) async {
    if (studentId.isEmpty) return;
    await _notificationsRef.doc(notificationId).update({
      'readBy': FieldValue.arrayUnion([studentId]),
    });
  }

  Future<void> markAllAsRead(
    List<NotificationModel> notifications,
    String studentId,
  ) async {
    if (studentId.isEmpty) return;
    final batch = _firestore.batch();
    for (final n in notifications) {
      if (!n.isReadBy(studentId)) {
        batch.update(_notificationsRef.doc(n.id), {
          'readBy': FieldValue.arrayUnion([studentId]),
        });
      }
    }
    await batch.commit();
  }

  // ---------------------------------------------------------------------
  // Teacher-side helper. Not used by the student app, but this is the
  // call your (future) teacher/admin app makes to create a notification
  // when a course/assignment/notice is added. Included here so both
  // sides agree on the same Firestore shape.
  // ---------------------------------------------------------------------
  Future<void> createNotification(NotificationModel notification) async {
    await _notificationsRef.add(notification.toMap());
  }
}
