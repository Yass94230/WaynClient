import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/chat/data/models/message_model.dart';
import 'package:wayn/features/chat/domain/entities/message.dart';
import 'package:wayn/features/chat/domain/usescases/create_chat_usecase.dart';
import 'package:wayn/features/chat/domain/usescases/get_messages_usecase.dart';
import 'package:wayn/features/chat/domain/usescases/send_message_usecase.dart';
import 'package:wayn/features/chat/presentation/blocs/chat_event.dart';
import 'package:wayn/features/chat/presentation/blocs/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final CreateChatUseCase createChatUseCase;
  StreamSubscription<List<Message>>? _messagesSubscription;

  ChatBloc(
      {required this.getMessagesUseCase,
      required this.sendMessageUseCase,
      required this.createChatUseCase})
      : super(ChatInitial()) {
    on<CreatePrivateChat>(_onCreatePrivateChat);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onCreatePrivateChat(
      CreatePrivateChat event, Emitter<ChatState> emit) async {
    try {
      final chatId = await createChatUseCase.execute(
        event.currentUserId,
        event.otherUserId,
      );
      emit(ChatCreating(chatId));
    } catch (error) {
      emit(ChatError(error.toString()));
    }
  }

  Future<void> _onLoadMessages(
      LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    await _messagesSubscription?.cancel();

    // Utiliser await pour s'assurer que l'émission est faite avant la fin de l'event handler
    await emit.forEach<List<Message>>(
      getMessagesUseCase.execute(event.chatId),
      onData: (messages) => ChatLoaded(messages),
      onError: (error, stackTrace) => ChatError(error.toString()),
    );
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    try {
      final message = MessageModel(
        senderId: 'currentUserId', // Get from auth service
        content: event.content,
        timestamp: DateTime.now(),
        chatId: event.chatId,
      );
      await sendMessageUseCase.execute(message);
    } catch (error) {
      emit(ChatError(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
