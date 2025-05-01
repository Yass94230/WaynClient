import 'package:wayn/features/chat/data/models/message_model.dart';
import 'package:wayn/features/chat/domain/entities/message.dart';

abstract class ChatRepository {
  Future<String> createPrivateChat({
    required String user1Id,
    required String user2Id,
  });
  Stream<List<Message>> getMessages(String chatId);
  Future<void> sendMessage(MessageModel message);
}
