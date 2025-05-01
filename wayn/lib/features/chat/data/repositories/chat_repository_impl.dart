import 'package:wayn/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:wayn/features/chat/data/models/message_model.dart';
import 'package:wayn/features/chat/domain/entities/message.dart';
import 'package:wayn/features/chat/domain/repositories/chat_repositoy.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Stream<List<Message>> getMessages(String chatId) {
    return remoteDataSource.getMessages(chatId);
  }

  @override
  Future<void> sendMessage(MessageModel message) {
    return remoteDataSource.sendMessage(message);
  }

  @override
  Future<String> createPrivateChat(
      {required String user1Id, required String user2Id}) {
    return remoteDataSource.createPrivateChat(
        user1Id: user1Id, user2Id: user2Id);
  }
}
