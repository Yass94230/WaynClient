import 'package:wayn/features/chat/domain/entities/message.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatCreating extends ChatState {
  final String chatId;
  ChatCreating(this.chatId);
}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  ChatLoaded(this.messages);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
