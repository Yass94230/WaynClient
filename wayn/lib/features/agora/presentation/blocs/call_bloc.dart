import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/agora/domain/entities/call_session.dart';
import 'package:wayn/features/agora/domain/repositories/call_repository.dart';
import 'package:wayn/features/agora/domain/usecases/join_call_usecase.dart';
import 'package:wayn/features/agora/presentation/blocs/call_event.dart';
import 'package:wayn/features/agora/presentation/blocs/call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final JoinCallUseCase _joinCallUseCase;
  final CallRepository _callRepository;
  CallSession? _currentSession;

  CallBloc(this._joinCallUseCase, this._callRepository) : super(CallInitial()) {
    // Configuration des callbacks du repository
    _callRepository.setCallbacks(
      onRemoteUserJoined: (int remoteUid) {
        if (_currentSession != null) {
          _currentSession = _currentSession!.copyWith(remoteUid: remoteUid);
          add(UpdateCallSessionEvent(_currentSession!));
        }
      },
      onRemoteUserLeft: (int remoteUid) {
        if (_currentSession != null) {
          _currentSession = _currentSession!.copyWith(remoteUid: null);
          add(UpdateCallSessionEvent(_currentSession!));
        }
      },
    );

    on<InitializeAgoraEvent>((event, emit) async {
      try {
        emit(CallLoading());
        await _callRepository.initializeAgora();
        emit(CallInitial());
      } catch (e) {
        emit(CallError(e.toString()));
      }
    });

    on<JoinCallEvent>((event, emit) async {
      try {
        emit(CallLoading());
        final session = await _joinCallUseCase.execute(event.channelName);
        _currentSession = session;
        emit(CallConnected(session));
      } catch (e) {
        emit(CallError(e.toString()));
      }
    });

    on<LeaveCallEvent>((event, emit) async {
      try {
        await _callRepository.leaveCall();
        _currentSession = null;
        emit(CallDisconnected());
      } catch (e) {
        emit(CallError(e.toString()));
      }
    });

    on<ToggleMuteEvent>((event, emit) async {
      try {
        await _callRepository.toggleMute();
        if (state is CallConnected && _currentSession != null) {
          emit(CallConnected(_currentSession!));
        }
      } catch (e) {
        emit(CallError(e.toString()));
      }
    });

    on<UpdateCallSessionEvent>((event, emit) {
      if (state is CallConnected) {
        emit(CallConnected(event.session));
      }
    });
  }
}
