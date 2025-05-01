import 'package:wayn/features/agora/domain/entities/call_session.dart';

abstract class CallState {}

class CallInitial extends CallState {}

class CallLoading extends CallState {}

class CallConnected extends CallState {
  final CallSession session;
  CallConnected(this.session);
}

class CallDisconnected extends CallState {}

class CallError extends CallState {
  final String message;
  CallError(this.message);
}
