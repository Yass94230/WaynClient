import 'package:wayn/features/authentification/domain/repositories/phone_auth_repository.dart';

class SendCodeUseCase {
  final PhoneAuthRepository repository;

  SendCodeUseCase(this.repository);

  Future<void> call(String phoneNumber) {
    return repository.sendVerificationCode(phoneNumber);
  }
}
