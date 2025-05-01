import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:wayn/features/chat/presentation/blocs/chat_state.dart';
import 'package:wayn/features/chat/presentation/widgets/message_bubble.dart';

class MessageList extends StatelessWidget {
  final String chatId;

  const MessageList({
    super.key,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ChatLoaded) {
          if (state.messages.isEmpty) {
            return const Center(
              child: Text('Aucun message'),
            );
          }

          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(8.0),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              return MessageBubble(message: message);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
