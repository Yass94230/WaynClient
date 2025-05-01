import 'package:wayn/features/authentification/domain/entities/user.dart';
import 'package:wayn/features/authentification/domain/repositories/user_repository.dart';

class GetUserUseCase {
  final UserRepository userRepository;

  GetUserUseCase(this.userRepository);

  Future<User?> execute() async {
    return await userRepository.getUser();
  }
}
