import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/agora/domain/entities/call_session.dart';
import 'package:wayn/features/agora/presentation/blocs/call_bloc.dart';
import 'package:wayn/features/agora/presentation/blocs/call_event.dart';

class CallScreen extends StatelessWidget {
  final CallSession session;

  const CallScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appel en cours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end),
            color: Colors.red,
            onPressed: () {
              context.read<CallBloc>().add(LeaveCallEvent());
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Canal: ${session.channelName}'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.mic_off),
                  onPressed: () {
                    context.read<CallBloc>().add(ToggleMuteEvent());
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.call_end),
                  color: Colors.red,
                  onPressed: () {
                    context.read<CallBloc>().add(LeaveCallEvent());
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
