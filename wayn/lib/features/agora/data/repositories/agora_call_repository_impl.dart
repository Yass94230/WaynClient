import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:wayn/features/agora/domain/entities/call_session.dart';
import 'package:wayn/features/agora/domain/repositories/call_repository.dart';

class AgoraCallRepositoryImpl implements CallRepository {
  late final RtcEngine _engine;
  bool _isInitialized = false;
  static const String appId = '7e3d7ee1928446c1aefeb61e5bc7bed5';

  // Callbacks pour les événements
  late Function(int) _onRemoteUserJoined;
  late Function(int) _onRemoteUserLeft;

  @override
  void setCallbacks({
    required Function(int) onRemoteUserJoined,
    required Function(int) onRemoteUserLeft,
  }) {
    _onRemoteUserJoined = onRemoteUserJoined;
    _onRemoteUserLeft = onRemoteUserLeft;
  }

  @override
  Future<void> initializeAgora() async {
    if (_isInitialized) return;

    try {
      _engine = createAgoraRtcEngine();

      await _engine.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      await _engine.enableAudio();
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      _setupEventHandlers();

      _isInitialized = true;
    } catch (e) {
      log("[Agora] Initialization error: $e");
      throw Exception('Failed to initialize Agora: $e');
    }
  }

  void _setupEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          log("[Agora] Local user ${connection.localUid} joined");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          log("[Agora] Remote user $remoteUid joined");
          _onRemoteUserJoined(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          log("[Agora] Remote user $remoteUid left channel");
          _onRemoteUserLeft(remoteUid);
        },
        onError: (ErrorCodeType err, String msg) {
          log("[Agora Error] Code: $err, Message: $msg");
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          log("[Agora] Token will expire");
          // Ici vous pouvez implémenter la logique de renouvellement du token
        },
      ),
    );
  }

  @override
  Future<CallSession> joinCall(String channelName) async {
    if (!_isInitialized) {
      throw Exception('Agora engine not initialized');
    }

    try {
      final uid = DateTime.now().millisecondsSinceEpoch % 100000;
      log("[Agora] Attempting to join channel: $channelName with uid: $uid");

      // Pour les tests, utilisez un token vide si l'authentification est désactivée
      // Pour la production, générez un token via votre backend
      await _engine.joinChannel(
        token:
            '007eJxTYMh4rL47Kv1M1d21Xg83bZze/3+qfM3qx0eKvG3+NalsVjZXYDBPNU4xT001tDSyMDExSzZMTE1LTTIzTDVNSjZPSk0xtQzYkN4QyMiQ4u7GyMgAgSA+C0NJanEJAwMACg0hZg==', // Remplacez par votre token en production
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          autoSubscribeAudio: true,
          autoSubscribeVideo: false,
          publishMicrophoneTrack: true,
          publishCustomAudioTrack: false,
          enableAudioRecordingOrPlayout: true,
        ),
      );

      return CallSession(
        channelName: channelName,
        uid: uid,
        isJoined: true,
        remoteUid: null, // Sera mis à jour via les callbacks
      );
    } catch (e) {
      log("[Agora] Join channel error: $e");
      throw Exception('Failed to join call: $e');
    }
  }

  @override
  Future<void> leaveCall() async {
    if (!_isInitialized) return;

    try {
      await _engine.leaveChannel();
    } catch (e) {
      log("[Agora] Leave channel error: $e");
      throw Exception('Failed to leave call: $e');
    }
  }

  @override
  Future<void> toggleMute() async {
    if (!_isInitialized) return;

    try {
      bool muted = await _engine.isSpeakerphoneEnabled();
      await _engine.muteLocalAudioStream(!muted);
    } catch (e) {
      log("[Agora] Toggle mute error: $e");
      throw Exception('Failed to toggle mute: $e');
    }
  }

  // Méthode pour libérer les ressources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _engine.release();
      _isInitialized = false;
    }
  }
}
