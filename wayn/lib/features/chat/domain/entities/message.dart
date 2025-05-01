class Message {
  final String senderId;
  final String content;
  final DateTime timestamp;
  final String chatId;

  Message({
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.chatId,
  });
}
