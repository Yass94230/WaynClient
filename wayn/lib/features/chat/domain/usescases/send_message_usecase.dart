import 'package:wayn/features/chat/data/models/message_model.dart';

import 'package:wayn/features/chat/domain/repositories/chat_repositoy.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> execute(MessageModel message) {
    return repository.sendMessage(message);
  }
}
