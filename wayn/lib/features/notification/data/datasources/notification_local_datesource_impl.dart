import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wayn/features/notification/data/datasources/notification_local_datasource.dart';

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseMessaging _firebaseMessaging;

  NotificationLocalDataSourceImpl({
    required FlutterLocalNotificationsPlugin localNotifications,
    required FirebaseMessaging firebaseMessaging,
  })  : _localNotifications = localNotifications,
        _firebaseMessaging = firebaseMessaging;

  @override
  Future<void> initialize() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Permissions iOS plus détaillées
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
        provisional: false,
        announcement: false,
        carPlay: false,
      );
    }
    // Configuration des notifications locales
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(settings);

    // Configuration des permissions Firebase
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'ride_requests',
      'Driver Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      0,
      title,
      body,
      details,
    );
  }

  @override
  Future<void> showDriverArrivalNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'driver_arrival',
      'Driver Arrival Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      1, // ID différent des autres notifications
      'Votre chauffeur est arrivé',
      'Votre chauffeur vous attend au point de ramassage',
      details,
    );
  }

  @override
  Future<String?> getFirebaseToken() async {
    return await _firebaseMessaging.getToken();
  }

  @override
  Stream<RemoteMessage> get onMessageStream => FirebaseMessaging.onMessage;
}
