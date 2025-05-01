import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:wayn/features/chat/presentation/blocs/chat_event.dart';
import 'package:wayn/features/chat/presentation/blocs/chat_state.dart';
import 'package:wayn/features/chat/presentation/widgets/message_input.dart';
import 'package:wayn/features/chat/presentation/widgets/message_list.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // Déclencher le chargement des messages au démarrage
    context.read<ChatBloc>().add(LoadMessages(widget.chatId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: MessageList(chatId: widget.chatId),
            ),
            MessageInput(chatId: widget.chatId),
          ],
        ),
      ),
    );
  }
}
