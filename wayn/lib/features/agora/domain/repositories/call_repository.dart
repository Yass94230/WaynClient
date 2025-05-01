import 'package:wayn/features/agora/domain/entities/call_session.dart';

abstract class CallRepository {
  Future<void> initializeAgora();
  Future<CallSession> joinCall(String channelName);
  Future<void> leaveCall();
  Future<void> toggleMute();

  void setCallbacks({
    required Function(int) onRemoteUserJoined,
    required Function(int) onRemoteUserLeft,
  });
}
