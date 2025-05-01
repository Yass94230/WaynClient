import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService(this._firebaseAuth, this._firestore) {
    listenToTokenRefresh();
  }

  // Méthode pour récupérer les données utilisateur
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.data();
      } catch (e) {
        log('Error fetching user data: $e');
        return null;
      }
    }
    return null;
  }

  // Méthode pour récupérer à la fois les données utilisateur et les données du profil client
  Future<Map<String, Map<String, dynamic>?>> getUserWithClientModeData() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        // Récupérer les données utilisateur principales
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        // Récupérer les données du profil client
        final clientDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('clientMode')
            .doc('profile')
            .get();

        return {
          'userData': userDoc.exists ? userDoc.data() : null,
          'clientData': clientDoc.exists ? clientDoc.data() : null,
        };
      } catch (e) {
        log('Error fetching user with client mode data: $e');
        return {'userData': null, 'clientData': null};
      }
    }
    return {'userData': null, 'clientData': null};
  }

  // Méthode pour récupérer les rôles de l'utilisateur (client, chauffeur ou les deux)
  // Basée uniquement sur l'existence des sous-collections
  Future<Map<String, bool>> getUserRoles() async {
    final user = _firebaseAuth.currentUser;
    Map<String, bool> roles = {'isClient': false, 'isDriver': false};

    if (user != null) {
      try {
        // Vérifier si l'utilisateur a un profil client
        final clientDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('clientMode')
            .doc('profile')
            .get();

        // Vérifier si l'utilisateur a un profil chauffeur
        final driverDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('driverMode')
            .doc('profile')
            .get();

        roles['isClient'] = clientDoc.exists;
        roles['isDriver'] = driverDoc.exists;
      } catch (e) {
        log('Error fetching user roles: $e');
      }
    }

    return roles;
  }

  // Méthode pour mettre à jour les données utilisateur principales
  Future<void> updateUserData(Map<String, dynamic> userData) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        // S'assurer que le token FCM n'est pas écrasé pendant la mise à jour
        final currentFcmToken = userData['firebaseToken'];
        if (currentFcmToken == null) {
          final token = await getFCMToken();
          userData['firebaseToken'] = token;
        }

        await _firestore.collection('users').doc(user.uid).update(userData);
        log('User data updated successfully');
      } catch (e) {
        log('Error updating user data: $e');
        throw Exception(
            'Erreur lors de la mise à jour des données utilisateur: $e');
      }
    } else {
      throw Exception('Aucun utilisateur connecté');
    }
  }

  // Méthode pour mettre à jour les données du profil client
  Future<void> updateClientModeData(Map<String, dynamic> clientData) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('clientMode')
            .doc('profile')
            .set(clientData, SetOptions(merge: true));

        log('Client profile data updated successfully');
      } catch (e) {
        log('Error updating client profile data: $e');
        throw Exception(
            'Erreur lors de la mise à jour des données du profil client: $e');
      }
    } else {
      throw Exception('Aucun utilisateur connecté');
    }
  }

  // Méthode pour récupérer le token FCM
  Future<String?> getFCMToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      log('FCM token retrieved: $token');
      return token;
    } catch (e) {
      log('Error getting FCM token: $e');
      throw Exception('Erreur lors de la récupération du token FCM: $e');
    }
  }

  // Méthode pour mettre à jour le token FCM
  Future<void> updateFCMToken() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        final fcmToken = await getFCMToken();
        await _firestore.collection('users').doc(user.uid).update({
          'firebaseToken': fcmToken,
        });
        log('FCM token updated successfully');
      } catch (e) {
        log('Error updating FCM token: $e');
        throw Exception('Erreur lors de la mise à jour du token FCM: $e');
      }
    }
  }

  void listenToTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      log('FCM token refreshed: $newToken');
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        try {
          await _firestore.collection('users').doc(user.uid).update({
            'firebaseToken': newToken,
          });
          log('FCM token updated in Firestore after refresh');
        } catch (e) {
          log('Error updating refreshed FCM token: $e');
        }
      }
    });
  }
}
