import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationLocalDataSource {
  Future<void> initialize();
  Future<void> showNotification(String title, String body);
  Future<String?> getFirebaseToken();
  Stream<RemoteMessage> get onMessageStream;
  Future<void> showDriverArrivalNotification();
}
