import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:wayn/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:wayn/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:wayn/features/chat/domain/repositories/chat_repositoy.dart';
import 'package:wayn/features/chat/domain/usescases/create_chat_usecase.dart';
import 'package:wayn/features/chat/domain/usescases/get_messages_usecase.dart';
import 'package:wayn/features/chat/domain/usescases/send_message_usecase.dart';
import 'package:wayn/features/chat/presentation/blocs/chat_bloc.dart';

final chatInjection = GetIt.instance;

Future<void> injectionChatDepency() async {
  // // External - Firebase
  // chatInjection.registerLazySingleton<FirebaseFirestore>(
  //   () => FirebaseFirestore.instance,
  // );

  // DataSources
  chatInjection.registerLazySingleton<ChatRemoteDataSource>(
    () => FirebaseChatDataSource(
      chatInjection<FirebaseFirestore>(),
    ),
  );

  // Repositories
  chatInjection.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: chatInjection<ChatRemoteDataSource>(),
    ),
  );

  // Use Cases
  chatInjection.registerLazySingleton(
    () => GetMessagesUseCase(
      chatInjection<ChatRepository>(),
    ),
  );

  chatInjection.registerLazySingleton(
    () => SendMessageUseCase(
      chatInjection<ChatRepository>(),
    ),
  );

  chatInjection.registerLazySingleton(
    () => CreateChatUseCase(
      chatInjection<ChatRepository>(),
    ),
  );

  // Blocs
  chatInjection.registerFactory(
    () => ChatBloc(
      getMessagesUseCase: chatInjection<GetMessagesUseCase>(),
      sendMessageUseCase: chatInjection<SendMessageUseCase>(),
      createChatUseCase: chatInjection<CreateChatUseCase>(),
    ),
  );
}
