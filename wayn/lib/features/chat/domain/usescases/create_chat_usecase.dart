import 'package:wayn/features/chat/domain/repositories/chat_repositoy.dart';

class CreateChatUseCase {
  final ChatRepository repository;

  CreateChatUseCase(this.repository);

  Future<String> execute(String user1Id, String user2Id) {
    return repository.createPrivateChat(user1Id: user1Id, user2Id: user2Id);
  }
}
