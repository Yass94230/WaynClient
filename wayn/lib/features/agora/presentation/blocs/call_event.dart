import 'package:wayn/features/agora/domain/entities/call_session.dart';

abstract class CallEvent {}

class InitializeAgoraEvent extends CallEvent {}

class JoinCallEvent extends CallEvent {
  final String channelName;
  JoinCallEvent(this.channelName);
}

class LeaveCallEvent extends CallEvent {}

class ToggleMuteEvent extends CallEvent {}

class UpdateCallSessionEvent extends CallEvent {
  final CallSession session;
  UpdateCallSessionEvent(this.session);
}
