import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {}

class NotificationInitialized extends NotificationState {}

class NotificationDisplayed extends NotificationState {
  final RemoteMessage message; // On peut garder le message aussi si nécessaire

  const NotificationDisplayed(this.message);
}

class NotificationError extends NotificationState {
  final String error;

  const NotificationError(this.error);
}
