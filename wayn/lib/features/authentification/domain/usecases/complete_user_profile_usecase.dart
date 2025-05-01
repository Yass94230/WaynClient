import 'package:wayn/features/authentification/domain/repositories/phone_auth_repository.dart';

class CompleteUserProfileUseCase {
  final PhoneAuthRepository repository;

  CompleteUserProfileUseCase(this.repository);

  Future<void> call({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required List<String> choices,
  }) async {
    return await repository.completeUserProfile(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      gender: gender,
      choices: choices,
    );
  }
}
