import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';
import 'package:wayn/features/agora/domain/entities/call_request.dart';
import 'package:wayn/features/agora/domain/utils/call_util.dart';

class CallService {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _fcm;

  CallService(this._firestore, this._fcm);

  // Initiateur de l'appel
  Future<void> initiateCall(String receiverId, String rideId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final channelName =
        CallUtils.generateChannelName(currentUserId, receiverId);
    final callId = const Uuid().v4();

    // Créer la demande d'appel dans Firestore
    final callRequest = CallRequest(
      callId: callId,
      callerId: currentUserId,
      receiverId: receiverId,
      channelName: channelName,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await _firestore.collection('rides').doc(rideId).set(callRequest.toMap());

    // Envoyer la notification FCM
    final receiverDoc =
        await _firestore.collection('users').doc(receiverId).get();

    final fcmToken = receiverDoc.data()?['firebaseToken'];

    if (fcmToken != null) {
      await _sendCallNotification(
        fcmToken,
        callId,
        channelName,
        currentUserId,
      );
    }
  }

  Future<void> _sendCallNotification(
    String fcmToken,
    String callId,
    String channelName,
    String callerId,
  ) async {
    final dio = Dio();
    const functionUrl =
        'https://us-central1-wayn-vtc.cloudfunctions.net/sendCallNotification';

    // Obtenir le token d'authentification Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final authToken = await user.getIdToken();

    try {
      await dio.post(
        functionUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ),
        data: {
          'data': {
            'token': fcmToken,
            'callId': callId,
            'channelName': channelName,
            'callerId': callerId,
          }
        },
      );
    } catch (e) {
      log('Error sending FCM: $e');
      rethrow;
    }
  }
}
