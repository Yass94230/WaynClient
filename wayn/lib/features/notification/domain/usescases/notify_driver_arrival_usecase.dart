import 'package:wayn/features/notification/domain/repositories/notification_repository.dart';

class NotifyDriverArrivalUseCase {
  final INotificationRepository _notificationRepository;

  NotifyDriverArrivalUseCase(this._notificationRepository);

  Future<void> execute() async {
    await _notificationRepository.notifyDriverArrival();
  }
}
