import 'package:wayn/features/authentification/domain/entities/user.dart';

abstract class UserRepository {
  Future<User?> getUser();
  Future<User?> refreshUser();
}
