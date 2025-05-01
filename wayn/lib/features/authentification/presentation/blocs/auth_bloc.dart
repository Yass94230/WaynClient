import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/domain/usecases/complete_user_profile_usecase.dart';
import 'package:wayn/features/authentification/domain/usecases/send_code_usecase.dart';
import 'package:wayn/features/authentification/domain/usecases/sign_in_with_apple.dart';
import 'package:wayn/features/authentification/domain/usecases/verif_code_usecase.dart';

abstract class AuthEvent {}

class SendVerificationCode extends AuthEvent {
  final String phoneNumber;
  SendVerificationCode(this.phoneNumber);
}

class VerifyCode extends AuthEvent {
  final String code;
  final String phoneNumber;
  VerifyCode(this.code, this.phoneNumber);
}

class CreateAccount extends AuthEvent {
  final String phoneNumber;
  final String password;
  CreateAccount({required this.phoneNumber, required this.password});
}

class SignInExistingUser extends AuthEvent {
  final String phoneNumber;
  final String password;

  SignInExistingUser({
    required this.phoneNumber,
    required this.password,
  });
}

class SignInWithApple extends AuthEvent {}

class AddPhoneToAppleAccount extends AuthEvent {
  final String phoneNumber;
  AddPhoneToAppleAccount(this.phoneNumber);
}

class CheckAuthStatus extends AuthEvent {}

class LogoutUser extends AuthEvent {}

class CompleteUserProfile extends AuthEvent {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final List<String> choices;

  CompleteUserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.choices,
  });
}

class AutoVerificationSuccess extends AuthState {}

class ManualVerificationRequired extends AuthState {}

// Nouveaux états
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class CodeSent extends AuthState {}

class VerificationSuccess extends AuthState {
  final bool isExistingUser;

  VerificationSuccess({required this.isExistingUser});
}

class AppleSignInComplete extends AuthState {
  final String email;
  final String? firstName;
  final String? lastName;
  AppleSignInComplete({
    required this.email,
    this.firstName,
    this.lastName,
  });
}

class AccountCreated extends AuthState {}

class LoginSuccess extends AuthState {}

class ProfileCompleted extends AuthState {}

class ProfileIncomplete extends AuthState {
  final String phoneNumber;
  ProfileIncomplete(this.phoneNumber);
}

class Authenticated extends AuthState {
  final String phoneNumber;
  Authenticated(this.phoneNumber);
}

class Unauthenticated extends AuthState {}

class UserDoesNotExist extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Bloc modifié
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendCodeUseCase _sendCodeUseCase;
  final VerifyCodeUseCase _verifyCodeUseCase;
  final CompleteUserProfileUseCase _completeUserProfileUseCase;
  final SignInIos _signInWithApple;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc(
    this._sendCodeUseCase,
    this._verifyCodeUseCase,
    this._firebaseAuth,
    this._completeUserProfileUseCase,
    this._signInWithApple,
  ) : super(AuthInitial()) {
    on<SendVerificationCode>((event, emit) async {
      emit(AuthLoading());
      try {
        await _sendCodeUseCase(event.phoneNumber);
        if (!emit.isDone) {
          emit(ManualVerificationRequired());
        }
      } catch (e) {
        log('Error in SendVerificationCode: $e');
        if (!emit.isDone) {
          emit(AuthError(e.toString()));
        }
      }
    });

    on<VerifyCode>((event, emit) async {
      emit(AuthLoading());
      try {
        final verified = await _verifyCodeUseCase(
          code: event.code,
          phoneNumber: event.phoneNumber,
        );

        if (verified) {
          final user = _firebaseAuth.currentUser;
          if (user != null) {
            // Vérifier si le profil client existe et s'il est complet
            final clientProfileDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('clientMode')
                .doc('profile')
                .get();

            if (clientProfileDoc.exists) {
              final clientData = clientProfileDoc.data();
              final bool isProfileComplete =
                  clientData?['isProfileCompleted'] ?? false;

              if (isProfileComplete) {
                emit(Authenticated(event.phoneNumber));
              } else {
                emit(ProfileIncomplete(event.phoneNumber));
              }
            } else {
              // Si le profil client n'existe pas, on le crée
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('clientMode')
                  .doc('profile')
                  .set({
                'isProfileCompleted': false,
                'createdAt': FieldValue.serverTimestamp(),
              });
              emit(ProfileIncomplete(event.phoneNumber));
            }
          }
        } else {
          emit(AuthError('Code de vérification invalide'));
        }
      } catch (e) {
        if (!emit.isDone) {
          emit(AuthError(e.toString()));
        }
      }
    });

    on<SignInWithApple>((event, emit) async {
      emit(AuthLoading());
      try {
        await _signInWithApple.call();

        final user = _firebaseAuth.currentUser;
        if (user != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data();
            final String? phoneNumber = userData?['phoneNumber'];
            final String? firstName = userData?['firstName'];
            final String? lastName = userData?['lastName'];

            // Vérifier si le profil client existe
            final clientProfileDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('clientMode')
                .doc('profile')
                .get();

            if (phoneNumber == null) {
              // Rediriger vers la saisie du numéro
              emit(AppleSignInComplete(
                email: user.email ?? '',
                firstName: firstName,
                lastName: lastName,
              ));
            } else if (clientProfileDoc.exists &&
                (clientProfileDoc.data()?['isProfileCompleted'] ?? false)) {
              emit(Authenticated(phoneNumber));
            } else {
              // Créer le profil client s'il n'existe pas
              if (!clientProfileDoc.exists) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('clientMode')
                    .doc('profile')
                    .set({
                  'isProfileCompleted': false,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }
              emit(ProfileIncomplete(phoneNumber));
            }
          }
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<CheckAuthStatus>((event, emit) async {
      try {
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data();
            final String phoneNumber = userData?['phoneNumber'] ?? '';

            // Vérifier si le profil client existe
            final clientProfileDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .collection('clientMode')
                .doc('profile')
                .get();

            // Si le profil client n'existe pas, le créer
            if (!clientProfileDoc.exists) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('clientMode')
                  .doc('profile')
                  .set({
                'isProfileCompleted': false,
                'createdAt': FieldValue.serverTimestamp(),
              });

              if (state is! ProfileIncomplete) {
                emit(ProfileIncomplete(phoneNumber));
              }
            } else {
              final clientData = clientProfileDoc.data();
              final bool isProfileComplete =
                  clientData?['isProfileCompleted'] ?? false;

              // Ne pas émettre si on est déjà dans le bon état
              if (isProfileComplete && state is! Authenticated) {
                emit(Authenticated(phoneNumber));
              } else if (!isProfileComplete && state is! ProfileIncomplete) {
                emit(ProfileIncomplete(phoneNumber));
              }
            }
          }
        } else if (state is! Unauthenticated) {
          emit(Unauthenticated());
        }
      } catch (e) {
        log('Error checking auth status: $e');
        // Ne pas émettre d'erreur pour cette vérification silencieuse
      }
    });

    on<LogoutUser>((event, emit) async {
      emit(AuthLoading());
      try {
        await _firebaseAuth.signOut();
        emit(Unauthenticated());
      } catch (e) {
        log(e.toString());
        emit(AuthError(e.toString()));
      }
    });

    on<CompleteUserProfile>((event, emit) async {
      emit(AuthLoading());
      try {
        await _completeUserProfileUseCase(
          uid: event.uid,
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          gender: event.gender,
          choices: event.choices,
        );
        emit(ProfileCompleted());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
