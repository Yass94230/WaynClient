// lib/features/notification/domain/usecases/send_ride_request_notification.dart

import 'package:wayn/features/notification/domain/repositories/notification_repository.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';

class SendRideRequestNotification {
  final INotificationRepository _notificationRepository;

  SendRideRequestNotification(this._notificationRepository);

  Future<void> call({
    required String driverToken,
    required RideRequest rideRequest,
  }) async {
    try {
      await _notificationRepository.sendRideRequestNotification(
        driverToken: driverToken,
        rideRequest: rideRequest,
      );
    } catch (e) {
      //throw NotificationException('Erreur lors de l\'envoi de la notification: $e');
    }
  }
}
