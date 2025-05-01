// features/authentication/data/datasources/local/user_local_cache.dart

import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:wayn/features/authentification/domain/entities/user.dart';

class UserLocalStorage {
  static const String userBoxName = 'userBox';
  static const String currentUserKey = 'currentUser';
  static const Duration cacheExpiration = Duration(hours: 24);

  late Box<User> _userBox;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    _userBox = await Hive.openBox<User>(userBoxName);
  }

  Future<void> cacheUser(User user) async {
    try {
      log('Tentative de mise en cache de l\'utilisateur: ${user.id}');
      await _userBox.put(currentUserKey, user);
      log('Utilisateur mis en cache avec succès');
    } catch (e) {
      log('Erreur lors de la mise en cache: $e');
    }
  }

  User? getCachedUser() {
    try {
      final user = _userBox.get(currentUserKey);
      log('Lecture du cache: ${user?.id ?? 'aucun utilisateur trouvé'}');
      return user;
    } catch (e) {
      log('Erreur lors de la lecture du cache: $e');
      return null;
    }
  }

  bool isUserCacheValid() {
    final user = _userBox.get(currentUserKey);
    if (user == null || user.createdAt == null) return false;

    final lastUpdate = DateTime.parse(user.createdAt!);
    return DateTime.now().difference(lastUpdate) < cacheExpiration;
  }

  Future<void> clearCache() async {
    await _userBox.clear();
  }
}
