import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wayn/features/notification/domain/repositories/notification_repository.dart';

class HandleIncomingNotificationUseCase {
  final INotificationRepository _repository;

  HandleIncomingNotificationUseCase(this._repository);

  Future<void> call(RemoteMessage message) async {
    await _repository.handleIncomingNotification(message);
  }
}
