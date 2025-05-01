import 'package:wayn/features/chat/domain/entities/message.dart';
import 'package:wayn/features/chat/domain/repositories/chat_repositoy.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Stream<List<Message>> execute(String chatId) {
    return repository.getMessages(chatId);
  }
}
