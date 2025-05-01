import 'package:wayn/features/authentification/domain/repositories/phone_auth_repository.dart';

class SignInIos {
  final PhoneAuthRepository repository;

  SignInIos(this.repository);

  Future<void> call() {
    return repository.signInWithApple();
  }
}
