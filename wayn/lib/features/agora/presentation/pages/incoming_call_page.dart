import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/agora/presentation/blocs/call_bloc.dart';
import 'package:wayn/features/agora/presentation/blocs/call_event.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callId;
  final String channelName;
  final String callerId;
  final RideRequest rideRequest;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.channelName,
    required this.callerId,
    required this.rideRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Appel entrant'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Accepter l'appel
                    context.read<CallBloc>().add(InitializeAgoraEvent());
                    context.read<CallBloc>().add(JoinCallEvent(channelName));
                    // Mettre à jour le statut dans Firestore
                    FirebaseFirestore.instance
                        .collection('rides')
                        .doc(rideRequest.id.toString())
                        .collection('calls')
                        .doc(callId)
                        .update({'status': 'accepted'});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Accepter'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Rejeter l'appel
                    FirebaseFirestore.instance
                        .collection('rides')
                        .doc(rideRequest.id.toString())
                        .collection('calls')
                        .doc(callId)
                        .update({'status': 'rejected'});
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Rejeter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
