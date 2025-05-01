// lib/features/notification/data/repositories/notification_repository_impl.dart

import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wayn/features/notification/data/datasources/notification_local_datasource.dart';
import 'package:wayn/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:wayn/features/notification/domain/repositories/notification_repository.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final INotificationRemoteDataSource _remoteDataSource;
  final NotificationLocalDataSource _localDataSource;

  NotificationRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<void> initialize() async {
    await _localDataSource.initialize();
  }

  @override
  Future<void> handleIncomingNotification(RemoteMessage message) async {
    await _localDataSource.showNotification(
      message.notification?.title ?? 'Nouvelle notification',
      message.notification?.body ?? '',
    );
  }

  @override
  Future<void> notifyDriverArrival() async {
    await _localDataSource.showDriverArrivalNotification();
  }

  @override
  Future<String?> getDeviceToken() async {
    return await _localDataSource.getFirebaseToken();
  }

  @override
  Stream<RemoteMessage> get notificationStream =>
      _localDataSource.onMessageStream;

  @override
  Future<void> sendRideRequestNotification({
    required String driverToken,
    required RideRequest rideRequest,
  }) async {
    try {
      await _remoteDataSource.sendRideRequestNotification(
        driverToken: driverToken,
        rideRequest: rideRequest,
      );
    } catch (e) {
      //throw NotificationException('Erreur repository notification: ${e.toString()}');
    }
  }

  @override
  Future<void> sendBatchRideRequestNotification({
    required List<String> driverTokens,
    required RideRequest rideRequest,
  }) async {
    // Envoie séquentiellement à chaque chauffeur
    for (final token in driverTokens) {
      try {
        await sendRideRequestNotification(
          driverToken: token,
          rideRequest: rideRequest,
        );
      } catch (e) {
        log('Erreur envoi notification au token $token: ${e.toString()}');
        // Continue avec le prochain token même en cas d'erreur
        continue;
      }
    }
  }
}
