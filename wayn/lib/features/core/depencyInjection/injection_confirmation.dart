// injection.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';
import 'package:wayn/features/notification/data/datasources/notification_local_datasource.dart';
import 'package:wayn/features/notification/data/datasources/notification_local_datesource_impl.dart';
import 'package:wayn/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:wayn/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:wayn/features/notification/domain/repositories/notification_repository.dart';
import 'package:wayn/features/notification/domain/usescases/handle_incoming_notification.dart';
import 'package:wayn/features/notification/domain/usescases/initialize_notification.dart';
import 'package:wayn/features/notification/domain/usescases/notify_driver_arrival_usecase.dart';
import 'package:wayn/features/notification/domain/usescases/send_ride_request.dart';
import 'package:wayn/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:wayn/features/ride/data/repositories/ride_repository_impl.dart';
import 'package:wayn/features/ride/domain/repositories/ride_repository.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_bloc.dart';

final injectionConfirmation = GetIt.instance;

Future<void> initConfirmationDependencies() async {
  // External Services
  injectionConfirmation.registerLazySingleton(
    () => FlutterLocalNotificationsPlugin(),
  );

  injectionConfirmation.registerLazySingleton(
    () => FirebaseMessaging.instance,
  );

  // DataSources
  injectionConfirmation.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSourceImpl(
      localNotifications:
          injectionConfirmation<FlutterLocalNotificationsPlugin>(),
      firebaseMessaging: injectionConfirmation<FirebaseMessaging>(),
    ),
  );

  injectionConfirmation.registerLazySingleton<INotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(
      Dio(),
      baseUrl: 'https://us-central1-wayn-vtc.cloudfunctions.net',
    ),
  );

  // Repositories
  injectionConfirmation.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      injectionConfirmation<INotificationRemoteDataSource>(),
      injectionConfirmation<NotificationLocalDataSource>(),
    ),
  );

  injectionConfirmation.registerLazySingleton<IRideRepository>(
    () => RideRepositoryImpl(FirebaseFirestore.instance),
  );

  // Use Cases
  injectionConfirmation.registerLazySingleton(
    () => InitializeNotificationUseCase(
      injectionConfirmation<INotificationRepository>(),
    ),
  );

  injectionConfirmation.registerLazySingleton(
    () => HandleIncomingNotificationUseCase(
      injectionConfirmation<INotificationRepository>(),
    ),
  );

  injectionConfirmation.registerLazySingleton(
    () => SendRideRequestNotification(
      injectionConfirmation<INotificationRepository>(),
    ),
  );

  injectionConfirmation.registerLazySingleton(
    () => NotifyDriverArrivalUseCase(
      injectionConfirmation<INotificationRepository>(),
    ),
  );

  // Blocs
  injectionConfirmation.registerFactory(
    () => NotificationBloc(
      initializeNotification:
          injectionConfirmation<InitializeNotificationUseCase>(),
      handleIncomingNotification:
          injectionConfirmation<HandleIncomingNotificationUseCase>(),
    ),
  );

  injectionConfirmation.registerFactory(
    () => RideConfirmationBloc(
      mapBloc: injectionConfirmation<MapBloc>(),
      notificationRepository: injectionConfirmation<INotificationRepository>(),
      rideRepository: injectionConfirmation<IRideRepository>(),
      notifyDriverArrival: injectionConfirmation<NotifyDriverArrivalUseCase>(),
    ),
  );
}
