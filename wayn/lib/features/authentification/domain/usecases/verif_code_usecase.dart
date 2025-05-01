import 'package:wayn/features/authentification/domain/repositories/phone_auth_repository.dart';

class VerifyCodeUseCase {
  final PhoneAuthRepository repository;

  VerifyCodeUseCase(this.repository);

  Future<bool> call({required String code, required String phoneNumber}) {
    return repository.verifyCode(code, phoneNumber);
  }
}
