abstract class ChatEvent {}

class CreatePrivateChat extends ChatEvent {
  final String currentUserId;
  final String otherUserId;

  CreatePrivateChat(this.currentUserId, this.otherUserId);
}

class LoadMessages extends ChatEvent {
  final String chatId;

  LoadMessages(this.chatId);
}

class SendMessage extends ChatEvent {
  final String content;
  final String chatId;
  SendMessage(
    this.chatId,
    this.content,
  );
}
