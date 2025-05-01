import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:wayn/features/authentification/data/datasources/firebase/firebase_auth_service.dart';
import 'package:wayn/features/authentification/data/datasources/local/user_local_storage.dart';
import 'package:wayn/features/authentification/data/repositories/phone_auth_repository_impl.dart';
import 'package:wayn/features/authentification/data/repositories/user_repository_impl.dart';
import 'package:wayn/features/authentification/domain/repositories/phone_auth_repository.dart';
import 'package:wayn/features/authentification/domain/repositories/user_repository.dart';
import 'package:wayn/features/authentification/domain/usecases/complete_user_profile_usecase.dart';
import 'package:wayn/features/authentification/domain/usecases/get_user_usecase.dart';
import 'package:wayn/features/authentification/domain/usecases/refresh_user_usecase.dart';
import 'package:wayn/features/authentification/domain/usecases/send_code_usecase.dart';
import 'package:wayn/features/authentification/domain/usecases/sign_in_with_apple.dart';
import 'package:wayn/features/authentification/domain/usecases/verif_code_usecase.dart';
import 'package:wayn/features/authentification/presentation/blocs/auth_bloc.dart';
import 'package:wayn/features/authentification/presentation/cubits/user_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs & Cubits
  sl.registerFactory(
    () => AuthBloc(
      sl<SendCodeUseCase>(),
      sl<VerifyCodeUseCase>(),
      sl<FirebaseAuth>(),
      sl<CompleteUserProfileUseCase>(),
      sl<SignInIos>(),
    ),
  );

  sl.registerFactory(
    () => UserCubit(
      sl<GetUserUseCase>(),
      sl<RefreshUserUseCase>(),
      sl<FirebaseAuthService>(),
      sl<UserLocalStorage>(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => SendCodeUseCase(sl()));
  sl.registerLazySingleton(() => VerifyCodeUseCase(sl()));
  sl.registerLazySingleton(() => CompleteUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetUserUseCase(sl()));
  sl.registerLazySingleton(() => RefreshUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInIos(sl()));

  // Repositories
  sl.registerLazySingleton<PhoneAuthRepository>(
    () => PhoneAuthRepositoryImpl(
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl(), sl()),
  );

  // Local Cache
  final userCache = UserLocalStorage();
  await userCache.init();
  sl.registerSingleton<UserLocalStorage>(userCache);

  // Firebase Services
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuthService(sl(), sl()));
}
