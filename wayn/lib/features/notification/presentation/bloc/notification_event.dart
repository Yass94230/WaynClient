import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationEvent {}

class InitializeNotifications extends NotificationEvent {}

class NotificationReceived extends NotificationEvent {
  final RemoteMessage message;

  NotificationReceived(this.message);
}
