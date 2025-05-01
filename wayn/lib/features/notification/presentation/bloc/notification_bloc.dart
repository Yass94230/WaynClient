import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/notification/domain/usescases/handle_incoming_notification.dart';
import 'package:wayn/features/notification/domain/usescases/initialize_notification.dart';
import 'package:wayn/features/notification/presentation/bloc/notification_event.dart';
import 'package:wayn/features/notification/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final InitializeNotificationUseCase _initializeNotification;
  final HandleIncomingNotificationUseCase _handleIncomingNotification;
  StreamSubscription<RemoteMessage>? _notificationSubscription;

  NotificationBloc({
    required InitializeNotificationUseCase initializeNotification,
    required HandleIncomingNotificationUseCase handleIncomingNotification,
  })  : _initializeNotification = initializeNotification,
        _handleIncomingNotification = handleIncomingNotification,
        super(NotificationInitial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<NotificationReceived>(_onNotificationReceived);
  }

  Future<void> _onInitializeNotifications(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _initializeNotification();
      _setupNotificationListener();
      emit(NotificationInitialized());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  void _setupNotificationListener() {
    log("=== SETTING UP NOTIFICATION LISTENER ===");
    _notificationSubscription?.cancel();
    _notificationSubscription = FirebaseMessaging.onMessage.listen((message) {
      log("Message reçu dans le listener: ${message.data}");
      add(NotificationReceived(message));
    });
  }

  Future<void> _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final message = event.message;

      // Vérifier si c'est une notification de course
      // if (message.data['type'] == 'new_ride') {
      // Créer un objet Ride à partir des données de la notification
      // final timeToPickup = int.parse(message.data['timeToPickup'] ?? '0');
      // final totalRideTime = int.parse(message.data['totalRideTime'] ?? '0');

      // final ride = RideModel(
      //   rideId: message.data['rideId'] ?? '',
      //   pickupAddress: message.data['pickupAddress'] ?? '',
      //   dropoffAddress: message.data['destinationAddress'] ?? '',
      //   grossPrice: double.parse(message.data['grossPrice']),
      //   netPrice: double.parse(message.data['netPrice']),
      //   timeToPickup:
      //       Duration(seconds: int.parse(message.data['timeToPickup'])),
      //   totalRideTime:
      //       Duration(seconds: int.parse(message.data['totalRideTime'])),
      //   status: RideStatus.values.firstWhere(
      //     (e) => e.toString() == message.data['status'],
      //     orElse: () => RideStatus.proposed,
      //   ),
      //   origin: message.data['origin'] ?? '',
      //   destination: message.data['destination'] ?? '',
      //   createdAt: DateTime.fromMillisecondsSinceEpoch(
      //       int.parse(message.data['createdAt'])),
      //   client: ClientModel.fromNotification(message.data),
      // );

      // Afficher la notification locale
      await _handleIncomingNotification(event.message);

      // Émettre l'état avec la nouvelle course
      //emit(NotificationDisplayed(ride, message));
      log('Notification received: $message');
      log(state.toString());

      // Déclencher l'événement de réception de course dans le RideBloc
      // }
    } catch (e) {
      log('Error handling notification: $e');
      emit(NotificationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
