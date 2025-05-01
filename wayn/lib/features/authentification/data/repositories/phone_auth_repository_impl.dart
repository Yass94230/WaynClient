import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wayn/features/authentification/data/datasources/firebase/firebase_auth_service.dart';
import 'package:wayn/features/authentification/domain/repositories/phone_auth_repository.dart';

class PhoneAuthRepositoryImpl implements PhoneAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseAuthService _firebaseAuthService;
  String? _verificationId;
  int? _resendToken;

  PhoneAuthRepositoryImpl(
      this._auth, this._firestore, this._firebaseAuthService);

  @override
  Future<void> sendVerificationCode(String phoneNumber) async {
    try {
      log('Initiating phone verification for: $phoneNumber');

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Cette callback est appelée automatiquement sur Android
          // quand la vérification est automatique
          log('Auto-verification completed on Android');
          try {
            final userCredential = await _auth.signInWithCredential(credential);

            // Vérifier si l'utilisateur existe déjà dans Firestore
            final userDoc = await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

            if (!userDoc.exists) {
              String fcmToken = '';
              await _firebaseAuthService.getFCMToken().then((value) {
                fcmToken = value!;
              });

              // Créer le document utilisateur s'il n'existe pas
              await _firestore
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .set({
                'phoneNumber': phoneNumber,
                'createdAt': FieldValue.serverTimestamp(),
                'firebaseToken': fcmToken,
              });

              // Créer le profil client
              await _firestore
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .collection('clientMode')
                  .doc('profile')
                  .set({
                'isProfileCompleted': false,
                'createdAt': FieldValue.serverTimestamp(),
              });
            } else {
              // Vérifier si le mode client existe déjà pour cet utilisateur
              final clientDoc = await _firestore
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .collection('clientMode')
                  .doc('profile')
                  .get();

              if (!clientDoc.exists) {
                // Créer le profil client s'il n'existe pas
                await _firestore
                    .collection('users')
                    .doc(userCredential.user!.uid)
                    .collection('clientMode')
                    .doc('profile')
                    .set({
                  'isProfileCompleted': false,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }
            }

            log('Auto-verification and authentication successful');
          } catch (e) {
            log('Error in auto-verification: $e');
            throw Exception('Erreur lors de l\'auto-vérification: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          log('Phone verification failed: ${e.code} - ${e.message}');
          throw Exception(_getErrorMessage(e.code));
        },
        codeSent: (String verificationId, int? resendToken) {
          log('SMS code sent successfully');
          _verificationId = verificationId;
          _resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log('Auto-retrieval timeout - updating verification ID');
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      log('Error in sendVerificationCode: $e');
      rethrow;
    }
  }

  @override
  Future<bool> verifyCode(String code, String phoneNumber) async {
    try {
      log('Starting manual code verification process');

      if (_verificationId == null) {
        throw Exception(
            'Session de vérification expirée. Veuillez recommencer.');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Erreur d\'authentification inattendue');
      }

      // Vérifier si l'utilisateur existe dans Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        String fcmToken = '';
        await _firebaseAuthService.getFCMToken().then((value) {
          fcmToken = value!;
        });

        // Créer le document utilisateur principal s'il n'existe pas
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'firebaseToken': fcmToken,
          'uid': userCredential.user!.uid
        });

        // Créer le profil client
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .collection('clientMode')
            .doc('profile')
            .set({
          'isProfileCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Vérifier si le mode client existe déjà
        final clientDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .collection('clientMode')
            .doc('profile')
            .get();

        if (!clientDoc.exists) {
          // Créer le profil client s'il n'existe pas encore
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .collection('clientMode')
              .doc('profile')
              .set({
            'isProfileCompleted': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      log('Manual verification successful');
      return true;
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException in verifyCode: ${e.code} - ${e.message}');
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      log('Unexpected error in verifyCode: $e');
      throw Exception('Une erreur est survenue lors de la vérification');
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-verification-code':
        return 'Le code entré est invalide';
      case 'invalid-verification-id':
        return 'Session de vérification expirée';
      case 'too-many-requests':
        return 'Trop de tentatives, veuillez réessayer plus tard';
      case 'invalid-phone-number':
        return 'Numéro de téléphone invalide';
      case 'credential-already-in-use':
        return 'Un compte existe déjà avec ce numéro';
      default:
        return 'Une erreur est survenue';
    }
  }

  @override
  Future<void> completeUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required List<String> choices,
  }) async {
    try {
      log('Starting profile completion');

      final user = _auth.currentUser;
      if (user == null) {
        log('No authenticated user found');
        throw Exception('Aucun utilisateur connecté');
      }

      if (email != user.email) {
        log('Updating email in Firebase Auth');
        await user.verifyBeforeUpdateEmail(email);
      }

      // Ne plus mettre à jour les informations personnelles dans le document principal
      // Mettre toutes les informations personnelles dans la sous-collection clientMode
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('clientMode')
          .doc('profile')
          .set({
        'uid': uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'gender': gender,
        'choices': choices,
        'isProfileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      log('Profile completion successful');
    } catch (e) {
      log('Error in completeUserProfile: $e');
      throw Exception('Erreur lors de la mise à jour du profil');
    }
  }

  @override
  Future<void> signInWithApple() async {
    try {
      log('Starting Apple Sign In process');

      final appleProvider = AppleAuthProvider();
      final userCredential = await _auth.signInWithProvider(appleProvider);

      if (userCredential.user == null) {
        throw Exception('Erreur d\'authentification Apple inattendue');
      }

      // Récupérer les informations de l'utilisateur
      final user = userCredential.user!;
      final displayName = user.displayName;
      final email = user.email;

      // Vérifier si l'utilisateur existe dans Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        String fcmToken = '';
        await _firebaseAuthService.getFCMToken().then((value) {
          fcmToken = value!;
        });

        // Créer le document utilisateur principal avec des infos minimales
        await _firestore.collection('users').doc(user.uid).set({
          'createdAt': FieldValue.serverTimestamp(),
          'firebaseToken': fcmToken,
          'authProvider': 'apple',
        });

        // Créer le profil client avec les informations personnelles
        final clientProfileData = {
          'email': email,
          'isProfileCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Si nous avons le nom complet de Apple, l'ajouter au profil client
        if (displayName != null) {
          final names = displayName.split(' ');
          clientProfileData['firstName'] = names.first;
          clientProfileData['lastName'] = names.length > 1 ? names.last : '';
        }

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('clientMode')
            .doc('profile')
            .set(clientProfileData);
      } else {
        // Vérifier si le mode client existe déjà
        final clientDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('clientMode')
            .doc('profile')
            .get();

        if (!clientDoc.exists) {
          // Créer le profil client s'il n'existe pas encore
          final clientProfileData = {
            'email': email,
            'isProfileCompleted': false,
            'createdAt': FieldValue.serverTimestamp(),
          };

          // Si nous avons le nom complet de Apple, l'ajouter au profil client
          if (displayName != null) {
            final names = displayName.split(' ');
            clientProfileData['firstName'] = names.first;
            clientProfileData['lastName'] = names.length > 1 ? names.last : '';
          }

          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('clientMode')
              .doc('profile')
              .set(clientProfileData);
        }
      }

      log('Apple Sign In successful');
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException in signInWithApple: ${e.code} - ${e.message}');
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      log('Unexpected error in signInWithApple: $e');
      throw Exception(
          'Une erreur est survenue lors de la connexion avec Apple');
    }
  }
}
