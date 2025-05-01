// // lib/features/authentication/domain/usecases/create_account_usecase.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:wayn/features/authentification/domain/repositories/phone_auth_repository.dart';

// class CreateAccountUseCase {
//   final PhoneAuthRepository repository;

//   CreateAccountUseCase(this.repository);

//   Future<UserCredential> call({
//     // Changé pour retourner UserCredential
//     required String phoneNumber,
//     required String password,
//   }) async {
//     return repository.createAccount(
//       phoneNumber: phoneNumber,
//       password: password,
//     );
//   }
// }
