import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:nexcampus_app/features/student/blocs/notification/models/notification_model.dart';

class TeacherNotificationService {
  TeacherNotificationService._internal();
  static final TeacherNotificationService _instance =
      TeacherNotificationService._internal();
  factory TeacherNotificationService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'nexcampus_teacher_notifications';
  static const String _channelName = 'NexCampus Teacher Notifications';

  bool _localNotifInitialized = false;

  CollectionReference<Map<String, dynamic>> get _notificationsRef => _firestore
      .collection('notifications')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? {},
        toFirestore: (data, _) => data,
      );

  Future<void> initialize({required String teacherId}) async {
    await _initLocalNotifications();
    await _requestPermission();
    await _saveFcmToken(teacherId);

    _messaging.onTokenRefresh.listen((token) {
      _firestore.collection('users').doc(teacherId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    });

    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  Future<void> _initLocalNotifications() async {
    if (_localNotifInitialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(settings: initSettings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Teacher course, assignment and notice alerts',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _localNotifInitialized = true;
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> _saveFcmToken(String teacherId) async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await _firestore.collection('users').doc(teacherId).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Teacher course, assignment and notice alerts',
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

  Stream<List<NotificationModel>> watchNotifications({
    required String teacherId,
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
                    return true;
                  case NotificationTargetType.teacher:
                    return n.targetId == teacherId;
                  case NotificationTargetType.student:
                    return false;
                }
              })
              .toList();
        });
  }

  Future<void> markAsRead(String notificationId, String teacherId) async {
    if (teacherId.isEmpty) return;
    await _notificationsRef.doc(notificationId).update({
      'readBy': FieldValue.arrayUnion([teacherId]),
    });
  }

  Future<void> markAllAsRead(
    List<NotificationModel> notifications,
    String teacherId,
  ) async {
    if (teacherId.isEmpty) return;
    final batch = _firestore.batch();
    for (final n in notifications) {
      if (!n.isReadBy(teacherId)) {
        batch.update(_notificationsRef.doc(n.id), {
          'readBy': FieldValue.arrayUnion([teacherId]),
        });
      }
    }
    await batch.commit();
  }

  // Send a notice to all students
  Future<void> sendNotice({
    required String teacherId,
    required String teacherName,
    required String title,
    required String body,
  }) async {
    final notification = NotificationModel(
      id: '',
      title: title,
      body: body,
      type: NotificationType.notice,
      targetType: NotificationTargetType.all,
      targetId: null,
      courseId: null,
      courseName: null,
      senderId: teacherId,
      senderName: teacherName,
      createdAt: DateTime.now(),
      readBy: [],
    );

    await _notificationsRef.add(notification.toMap());
  }

  // Send a course creation notification
  Future<void> sendCourseNotification({
    required String teacherId,
    required String teacherName,
    required String title,
    required String body,
    required String courseId,
    required String courseName,
  }) async {
    final notification = NotificationModel(
      id: '',
      title: title,
      body: body,
      type: NotificationType.course,
      targetType: NotificationTargetType.all,
      targetId: null,
      courseId: courseId,
      courseName: courseName,
      senderId: teacherId,
      senderName: teacherName,
      createdAt: DateTime.now(),
      readBy: [],
    );

    await _notificationsRef.add(notification.toMap());
  }
}
