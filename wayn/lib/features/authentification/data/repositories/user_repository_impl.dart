// features/authentication/data/repositories/user_repository_impl.dart

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:wayn/features/authentification/data/datasources/firebase/firebase_auth_service.dart';
import 'package:wayn/features/authentification/data/datasources/local/user_local_storage.dart';
import 'package:wayn/features/authentification/data/models/user_model.dart';
import 'package:wayn/features/authentification/domain/entities/user.dart';
import 'package:wayn/features/authentification/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuthService _firebaseAuthService;
  final UserLocalStorage _localCache;

  UserRepositoryImpl(this._firebaseAuthService, this._localCache);

  @override
  Future<User?> getUser() async {
    try {
      // Vérifier le cache d'abord
      final cachedUser = _localCache.getCachedUser();
      if (_localCache.isUserCacheValid() && cachedUser != null) {
        return cachedUser;
      }

      // Utiliser la méthode pour récupérer à la fois les données utilisateur et les données du profil client
      final userWithClientData =
          await _firebaseAuthService.getUserWithClientModeData();
      final userData = userWithClientData['userData'];
      final clientData = userWithClientData['clientData'];

      if (userData != null) {
        // Convertir la Map en UserModel
        final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          // Utiliser la méthode factory qui combine les données
          final userModel = UserModel.fromFirestoreWithClientMode(
              userData, clientData, userId);

          // Mettre à jour le cache
          await _localCache.cacheUser(userModel);
          return userModel;
        }
      }

      return null;
    } catch (e) {
      log('Error in getUser: $e');
      // En cas d'erreur, essayer de retourner le cache
      return _localCache.getCachedUser();
    }
  }

  @override
  Future<User?> refreshUser() async {
    try {
      // Utiliser la méthode pour récupérer les données combinées
      final userWithClientData =
          await _firebaseAuthService.getUserWithClientModeData();
      final userData = userWithClientData['userData'];
      final clientData = userWithClientData['clientData'];

      if (userData != null) {
        final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          // Utiliser la méthode factory
          final userModel = UserModel.fromFirestoreWithClientMode(
              userData, clientData, userId);
          await _localCache.cacheUser(userModel);
          return userModel;
        }
      }
      return null;
    } catch (e) {
      log('Error in refreshUser: $e');
      throw Exception('Failed to refresh user: $e');
    }
  }

  // Méthode pour vérifier les rôles de l'utilisateur basée sur l'existence des sous-collections
  Future<Map<String, bool>> getUserRoles() async {
    try {
      return await _firebaseAuthService.getUserRoles();
    } catch (e) {
      log('Error getting user roles: $e');
      return {'isClient': false, 'isDriver': false};
    }
  }
}
