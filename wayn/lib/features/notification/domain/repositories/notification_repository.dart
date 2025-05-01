import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';

abstract class INotificationRepository {
  /// Envoie une notification de demande de course à un chauffeur spécifique
  Future<void> sendRideRequestNotification({
    required String driverToken,
    required RideRequest rideRequest,
  });

  /// Optionnel : Envoie une notification à plusieurs chauffeurs
  Future<void> sendBatchRideRequestNotification({
    required List<String> driverTokens,
    required RideRequest rideRequest,
  });

  Future<void> initialize();
  Future<void> handleIncomingNotification(RemoteMessage message);
  Future<String?> getDeviceToken();
  Stream<RemoteMessage> get notificationStream;

  Future<void> notifyDriverArrival();
}
