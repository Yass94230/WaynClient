import 'package:wayn/features/agora/domain/entities/call_session.dart';
import 'package:wayn/features/agora/domain/repositories/call_repository.dart';

class JoinCallUseCase {
  final CallRepository repository;

  JoinCallUseCase(this.repository);

  Future<CallSession> execute(String channelName) {
    return repository.joinCall(channelName);
  }
}
