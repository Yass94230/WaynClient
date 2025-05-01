import 'package:get_it/get_it.dart';
import 'package:wayn/features/agora/data/repositories/agora_call_repository_impl.dart';
import 'package:wayn/features/agora/domain/repositories/call_repository.dart';
import 'package:wayn/features/agora/domain/usecases/join_call_usecase.dart';
import 'package:wayn/features/agora/presentation/blocs/call_bloc.dart';

final agoraInjection = GetIt.instance;

Future<void> injectionAgora() async {
  // Engine Agora
  final engine = createAgoraRtcEngine();
  await engine.initialize(const RtcEngineContext(
    appId: '7e3d7ee1928446c1aefeb61e5bc7bed5',
    channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
  ));
  agoraInjection.registerSingleton<RtcEngine>(engine);

  // Repository
  agoraInjection.registerSingleton<CallRepository>(AgoraCallRepositoryImpl());

  // Use Cases
  agoraInjection
      .registerFactory(() => JoinCallUseCase(agoraInjection<CallRepository>()));

  // Bloc
  agoraInjection.registerFactory(() => CallBloc(
        agoraInjection<JoinCallUseCase>(),
        agoraInjection<CallRepository>(),
      ));
}
