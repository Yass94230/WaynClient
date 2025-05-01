import 'package:wayn/features/notification/domain/repositories/notification_repository.dart';

class InitializeNotificationUseCase {
  final INotificationRepository _repository;

  InitializeNotificationUseCase(this._repository);

  Future<void> call() async {
    await _repository.initialize();
  }
}
