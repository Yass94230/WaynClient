import 'package:wayn/features/authentification/domain/entities/user.dart';
import 'package:wayn/features/authentification/domain/repositories/user_repository.dart';

class RefreshUserUseCase {
  final UserRepository userRepository;

  RefreshUserUseCase(this.userRepository);

  Future<User?> execute() async {
    return await userRepository.refreshUser();
  }
}
